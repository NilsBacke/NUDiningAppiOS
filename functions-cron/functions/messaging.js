// NU Dining App
// 24-hr push notification cron job for food preferences.
//
// Author: Sam Xifaras

module.exports = {
  execute: cronjob
};

// DRY and DEBUG flags
const DRY = false;
const DEBUG = true;

// Imports
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault()
});
const db = admin.firestore();
db.settings({timestampsInSnapshots: true}); // to suppress warning

const axios = require("axios");

/*
const {
  db,
} = require('./admin.js');
*/

// Utility Functions
function argmin(arr) {
  return arr.map((x, i) => [x, i]).reduce((r, a) => (a[0] < r[0] ? a : r))[1];
}

// Utility definitions
const nu_site_id = "5751fd2b90975b60e048929a";

const locations = [
  {
    id:"5b9bd1c41178e90d4774210e",
    name:"Stetson West"
  },
  {
    id:"5b9bd1c41178e90d4774210e",
    name:"IV"
  },
  {
    id:"586d05e4ee596f6e6c04b527",
    name:"Stetson East"
  }
]

const periods = [
  {
    name:"Breakfast",
    hour:7
  },
  {
    name:"Lunch",
    hour:11
  },
  {
    name:"Dinner",
    hour: 16
  }
]

async function cronjob(message, context, period) {
  console.log("This job is run every 24 hours!");

  var date = new Date();

  // Determine the period for which to produce notifications
  //var hours = date.getHours();
  var target_period = period; //periods[argmin(periods.map((p) => { return Math.abs(p.hour - hours); }))].name;

  if (DEBUG) console.log("TARGET PERIOD:", target_period);

  var yr = date.getFullYear();
  var mnth = date.getMonth() + 1;
  var day = date.getDate();
  var date_string = yr + "-" + ("00" + mnth).substr(-2,2) + "-" + ("00" + day).substr(-2,2);
  if (DEBUG) console.log("date_string =", date_string);

  // Get devices
  return db.collection('devices')
  .get()
  .then(async (snapshot) => {

    for (var i = 0; i < locations.length; i++) {
      var location = locations[i];
      // Get all foods at each location

      await fetchFoodsAndSendMessages(location, date_string, snapshot, target_period);
    }
    if (DEBUG) console.log("FINISHED with database");
    if (DEBUG) console.log("EXITING worker");
  })
  .catch((err) => {
    console.log('Error getting documents', err);
  });
}

async function fetchFoodsAndSendMessages(location, date_string, snapshot, target_period) {
  return new Promise((resolve, reject) => {
    getAllFoodsAtLocationInPeriod(nu_site_id, location.id, location.name, date_string, target_period)
    .then(async (foods_from_menu) => {
      doc_arr = [];
      snapshot.forEach((item) => {
        doc_arr.push(item);
      });

      for (var j = 0; j < doc_arr.length; j++) {
        var doc = doc_arr[j];
        await sendMessagesToDevice(doc, location, foods_from_menu, target_period);
      }
      if (DEBUG) console.log("FINISHED at", location.name);
      resolve();
    })
    .catch((err) => {
      console.log("ERROR getting foods at location", location.id, location.name);
      console.log(err);
      reject();
    });
  });
}

function sendMessagesToDevice(doc, location, foods_from_menu, target_period) {
  return new Promise((resolve, reject) => {
    db.collection('devices').doc(doc.id).collection('preferredFoods')
    .get()
    .then((preferredFoods_snap) => {
      var foodPrefs = preferredFoods_snap.docs
            .map((preferredFood_entry) => preferredFood_entry.data().food);
      foodPrefs.forEach((foodPref) => {
        // Check for matches
        if (DEBUG) console.log("Checking if", foodPref, "is being served at", location.name);
        var matches = foods_from_menu.filter((food_from_menu) => foodPref == food_from_menu.name);

        matches.forEach((match) => {
          if (DEBUG) console.log("sending message to device", doc.data().deviceID);
          sendMessageToDevice(doc.data().deviceID, foodPref + " is being served at " + location.name + " for " + target_period + " today!");
        });

        if (DEBUG) console.log("CHECKING at", location.name);
      });
      resolve();
    })
    .catch((err) => {
      console.log("Error", err);
      reject();
    });
  });
}

function sendMessageToDevice(deviceID, msg) {
  if (!DRY) {
    var message = {
      notification: {
        title: "NU Dining",
        body: msg
      },
      apns: {
        payload: {
          aps: {
            badge: 0,
          }
        }
      },
      token: deviceID
    };

    admin.messaging().send(message)
    .then((response) => {
      // Response is a message ID string.
      console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
  }
}

function getAllLocations(site_id) {
  return new Promise(function(resolve, reject) {
    getLocationsJSON(site_id)
    .then((data) => {
      var foods = [];
      resolve(data.locations);
    })
  });
}

/*
 * Returns a list of foods at a site
 */
function getAllFoods(site_id, date) {
  return new Promise(function(resolve, reject) {
    getAllLocations(site_id)
    .then((locations) => {
      var foods = [];
      data.locations.forEach(location => {
        getAllFoodsAtLocation(site_id, location.id, location.name, date).then((foods_at_loc) => {
          foods.concat(foods_at_loc);
        });
      });
      resolve(foods);
    })
    .catch((err) => {
      reject('error');
    });
  });
}


// TODO: Perhaps create an abstraction of the following two functions
//  that takes an array of target_periods

function getAllFoodsAtLocation(site_id, location_id, location_name, date) {
  return new Promise(function(resolve, reject) {
    getMenuJSON(site_id, location_id, date).then((data) => {
      var foods = [];
      data.menu.periods.forEach(period => {
        period.categories.forEach(category => {
          category.items.forEach(item => {
            foods.push({"name":item.name, "period":period.name, "location":location_name});
          });
        });
      });
      resolve(foods);
    })
    .catch((err) => {
      reject("Error getting foods at:", location_id, location_name);
    });
  });
}

function getAllFoodsAtLocationInPeriod(site_id, location_id, location_name, date, target_period) {
  return new Promise(function(resolve, reject) {
    getMenuJSON(site_id, location_id, date).then((data) => {
      var foods = [];
      data.menu.periods.forEach(period => {
        if (DEBUG) console.log("CHECKING", period.name, "against target", target_period);
        if (period.name == target_period) {
          period.categories.forEach(category => {
            category.items.forEach(item => {
              foods.push({"name":item.name, "period":period.name, "location":location_name});
            });
          });
        }
      });
      resolve(foods);
    })
    .catch((err) => {
      reject("Error getting foods at:", location_id, location_name);
    });
  });
}

function getLocationsJSON(site_id) {
  return new Promise(function(resolve) {
    axios
      .get(
        "https://api.dineoncampus.com/v1/locations/all_locations?site_id="
          + site_id
      )
      .then(response => {
        var stringData = JSON.stringify(response.data);
        var data = response.data;
        console.log("data1: " + stringData);
        resolve(data);
      })
      .catch(error => {
        console.log(error);
        reject("error");
      });
  });
}

function getMenuJSON(site_id, location_id, date) {
  return new Promise(function(resolve) {
    axios
      .get(
        "https://api.dineoncampus.com/v1/location/menu?site_id="
        + site_id
        + "&location_id="
        + location_id
        + "&platform=0&date="
        + date
      )
      .then(response => {
        var stringData = JSON.stringify(response.data);
        var data = response.data;
        // TODO: Maybe check for 400 Bad Request or malformed responses here
        if (data.status == "success") {
          resolve(data);
        }
      })
      .catch(error => {
        console.log(error);
        reject("error");
      })
  })
}

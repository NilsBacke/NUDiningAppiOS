// NU Dining App
// 24-hr push notification cron job for food preferences.
//
// Author: Sam Xifaras

const DRY = true;
const DEBUG = true;

const axios = require("axios");

const {
  db,
} = require('./admin.js');

module.exports = {
  execute: cronjob
};

function cronjob(message, context) {
  const nu_site_id = "5751fd2b90975b60e048929a";
  //try {
    console.log("This job is run every 24 hours!");
    db.settings({timestampsInSnapshots: true}); // to suppress warning

    var date = new Date();
    var yr = date.getFullYear();
    var mnth = date.getMonth() + 1;
    var day = date.getDate();
    var date_string = yr + "-" + ("00" + mnth).substr(-2,2) + "-" + ("00" + day).substr(-2,2);
    if (DEBUG) console.log("date_string =", date_string);

    // Get devices
    db.collection('devices')
    .get()
    .then((snapshot) => {

      // Get all dining locations
      getAllLocations(nu_site_id)
      .then((locations) => {
        console.log(locations.map((loc) => loc.name));
        
        locations.forEach((location) => {

          // Get all foods at each location
          getAllFoodsAtLocation(nu_site_id, location.id, location.name, date_string)
          .then((foods_from_menu) => {
            snapshot.forEach((doc) => {

              // Get preferredFoods for each device
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
                    console.log("sending message to device", doc.data().deviceID);
                    sendMessageToDevice(doc.data().deviceID, "msg");
                  });
                  console.log("CHECKING at", location.name);
                });
              })
              .catch((err) => {
                console.log("Error", err);
              });

            });
          });
        });
      })

    })
    .catch((err) => {
      console.log('Error getting documents', err);
    });

    return true;
  //}
  //catch (err) {
  //  console.log("A fatal error occured and the job could not finish execution");
  //  return false;
  //}
}

function sendMessageToDevice(deviceID, msg) {
  if (!DRY) {
    var message = {
      data: msg,
      token: deviceID
    }

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
      resolve('error');
    });
  });
}

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
      // err
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
        resolve("error");
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
        resolve("error");
      })
  })
}

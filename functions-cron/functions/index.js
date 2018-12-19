// Copyright 2017 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

const app = admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

var nu_site_id = "5751fd2b90975b60e048929a";

exports.daily_job = functions.pubsub.topic("daily-tick").onPublish(message => {
  console.log("This job is run every 24 hours!");
  console.log(process.env.FIREBASE_CONFIG);
  var db = admin.firestore();
  db.settings({timestampsInSnapshots: true}); // to suppress warning

  // code goes here
  db.collection('devices').get()
  .then((snapshot) => {
    snapshot.forEach((doc) => {
      console.log(doc.id, '=>', doc.data());
    });
  })
  .catch((err) => {
    console.log('Error getting documents', err);
  });
  /*
  var devices = devices_ref.get().then(snapshot => {
    snapshot.forEach(doc => {
      var deviceID = doc.deviceID;
      var preferredFoods = doc.preferredFoods;
      console.log(deviceID + "=>" + preferredFoods);
    });
  });*/

  return true;
});

/*
 * Returns a list of foods at a site
 */
function getAllFoods(site_id, date) {
  var foods = [];
  var locations_obj = getLocationsJSON(site_id).then(data => { return data; });
  locations_obj.locations.forEach(location => {
    foods.concat(getAllFoodsAtLocation(site_id, location.id, location.name, date));
  });
  return foods;
}

function getAllFoodsAtLocation(site_id, location_id, location_name, date) {
  var foods = [];
  var menu_obj = getMenuJSON(site_id, location_id, date).then(data => { return data; });
  menu_obj.menu.periods.forEach(period => {
    period.categories.forEach(category => {
      category.items.forEach(item => {
        foods.push({"name":item.name, "period":period.name, "location":location_name});
      })
    })
  });
  return foods;
}

function sendMessageToDevice(deviceID, msg) {
  // Implement me!
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

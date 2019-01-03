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

// Production steps of ECMA-262, Edition 5, 15.4.4.19
// Reference: http://es5.github.io/#x15.4.4.19
if (!Array.prototype.map) {

  Array.prototype.map = function(callback/*, thisArg*/) {

    var T, A, k;

    if (this == null) {
      throw new TypeError('this is null or not defined');
    }

    // 1. Let O be the result of calling ToObject passing the |this|
    //    value as the argument.
    var O = Object(this);

    // 2. Let lenValue be the result of calling the Get internal
    //    method of O with the argument "length".
    // 3. Let len be ToUint32(lenValue).
    var len = O.length >>> 0;

    // 4. If IsCallable(callback) is false, throw a TypeError exception.
    // See: http://es5.github.com/#x9.11
    if (typeof callback !== 'function') {
      throw new TypeError(callback + ' is not a function');
    }

    // 5. If thisArg was supplied, let T be thisArg; else let T be undefined.
    if (arguments.length > 1) {
      T = arguments[1];
    }

    // 6. Let A be a new array created as if by the expression new Array(len)
    //    where Array is the standard built-in constructor with that name and
    //    len is the value of len.
    A = new Array(len);

    // 7. Let k be 0
    k = 0;

    // 8. Repeat, while k < len
    while (k < len) {

      var kValue, mappedValue;

      // a. Let Pk be ToString(k).
      //   This is implicit for LHS operands of the in operator
      // b. Let kPresent be the result of calling the HasProperty internal
      //    method of O with argument Pk.
      //   This step can be combined with c
      // c. If kPresent is true, then
      if (k in O) {

        // i. Let kValue be the result of calling the Get internal
        //    method of O with argument Pk.
        kValue = O[k];

        // ii. Let mappedValue be the result of calling the Call internal
        //     method of callback with T as the this value and argument
        //     list containing kValue, k, and O.
        mappedValue = callback.call(T, kValue, k, O);

        // iii. Call the DefineOwnProperty internal method of A with arguments
        // Pk, Property Descriptor
        // { Value: mappedValue,
        //   Writable: true,
        //   Enumerable: true,
        //   Configurable: true },
        // and false.

        // In browsers that support Object.defineProperty, use the following:
        // Object.defineProperty(A, k, {
        //   value: mappedValue,
        //   writable: true,
        //   enumerable: true,
        //   configurable: true
        // });

        // For best browser support, use the following:
        A[k] = mappedValue;
      }
      // d. Increase k by 1.
      k++;
    }

    // 9. return A
    return A;
  };
}

const functions = require("firebase-functions");
const fillFood = require("./fillFood.js");

fillFood.getFoodsFromAPI();

exports.fillFood = functions.https.onRequest(async (req, res) => {
  return await fillFood.getFoodsFromAPI();
});

const admin = require("firebase-admin");
const axios = require("axios");

const app = admin.initializeApp({
  credential: admin.credential.applicationDefault()
}, "messaging_app");

var nu_site_id = "5751fd2b90975b60e048929a";

exports.daily_job = functions.pubsub.topic("daily-tick").onPublish(cron);

function cron(message, context) {
  try {
    console.log("This job is run every 24 hours!");
    var db = admin.firestore();
    db.settings({timestampsInSnapshots: true}); // to suppress warning

    var date = new Date();
    var yr = date.getFullYear();
    var mnth = date.getMonth();
    var day = date.getDate();
    var date_string = yr + "-" + ("00" + mnth).substr(-2,2) + "-" + ("00" + day).substr(-2,2);
    
    getAllLocations(nu_site_id)
    .then((locations) => {
      console.log(locations.map((loc) => loc.name));
      locations.forEach((location) => {
        getAllFoodsAtLocation(nu_site_id, location.id, location.name, date_string)
        .then((foods_from_menu) => {
          db.collection('devices')
          .get()
          .then((snapshot) => {
            snapshot.forEach((doc) => {
              db.collection('devices').doc(doc.id).collection('preferredFoods')
              .get()
              .then((preferredFoods_snap) => {
                var foodPrefs = preferredFoods_snap.docs
                      .map((preferredFood_entry) => preferredFood_entry.data().food);
                foodPrefs.forEach((foodPref) => {
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
          })
          .catch((err) => {
            console.log('Error getting documents', err);
          });
        });
      });
    });

    return true;
  }
  catch (err) {

  }
}

function sendMessageToDevice(deviceID, msg) {
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

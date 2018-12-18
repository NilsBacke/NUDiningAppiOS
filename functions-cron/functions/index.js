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
const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const axios = require("axios");
const functions = require("firebase-functions");

var nu_site_id = "5751fd2b90975b60e048929a";

exports.daily_job = functions.pubsub.topic("daily-tick").onPublish(message => {
  console.log("This job is run every 24 hours!");

  // code goes here
  

  return true;
});

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

/*
 * Extracts the meal names from a specific dining period from the given
 *  menu object.
 *
 * menu_obj: A menu query response in JSON.
 * period: the name of the dining period, one of "Breakfast, Lunch, Dinner"
 */
function getMealNamesInPeriod(menu_obj, period) {
  var meal_names = [];
  // Assumes the data is well formed, i.e. there are no duplicates
  var menu_at_period = menu_obj.menu.periods
    .filter(period => period.name == period)[0];
  menu_at_period.categories.forEach(category => {
    category.items.forEach(item => {
      meal_names.push(item.name);
    });
  });
  return meal_names;
}

// TODO: Maybe reimplement this asynchronously.
/*
 * Maps meal names to dining halls for a specific meal.
 * Returns an array of pairs, where each pair is a two-element array,
 *  of meal names and dining hall names. The data is in this format to make
 *  filtering through it easier later on.
 *
 * period: the dining period to query
 * date: the date to query
 */
function getAllMealNamesInPeriodOnDate(period, date) {
  var meal_dh_pairs = [];
  var locations_obj = await getLocationsJSON();
  locations_obj.locations.forEach(function(loc) {
    var loc_id = loc.id;
    var loc_name = loc.name;
    var menu_obj = await getMenuJSON(nu_site_id, loc_id, date);
    var meal_names = getMealNamesInPeriod(menu_obj, period, date);
    meal_names.forEach(name => meal_dh_pairs.push([meal, loc_name]));
  });
  return meal_dh_pairs;
}

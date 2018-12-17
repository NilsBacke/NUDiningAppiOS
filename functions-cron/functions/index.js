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
const rp = require("request-promise");
const cheerio = require("cheerio");
admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

exports.five_min_job = functions.pubsub
  .topic("five-min-tick")
  .onPublish(message => {
    console.log("This job is run every 5 minutes!");

    var IVdinner = await getMenuData("International Village", "Dinner");

    return true;
  });

function getMenuData(place, time) {
  return new Promise(function(resolve) {
    rp("https://new.dineoncampus.com/Northeastern/menus").then(html => {
      let $ = cheerio.load(html);
    });
  });
}

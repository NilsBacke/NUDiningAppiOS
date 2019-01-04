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

const functions = require("firebase-functions");
const fillFood = require("./fillFood.js");
const messaging = require("./messaging.js");

fillFood.getFoodsFromAPI();

exports.fillFood = functions.https.onRequest(async (req, res) => {
  return await fillFood.getFoodsFromAPI();
});

exports.daily_job = functions.pubsub.topic("daily-tick").onPublish((msg, context) => { return messaging.execute(msg, context); });

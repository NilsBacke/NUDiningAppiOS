// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const admin = require("firebase-admin");
const axios = require("axios");
admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const locations = [
  "5b9bd1c41178e90d4774210e",
  "586d17503191a27120e60dec",
  "586d05e4ee596f6e6c04b527"
];

const dates = [
  "2018-12-02",
  "2018-12-03",
  "2018-12-04",
  "2018-12-05",
  "2018-12-06",
  "2018-12-07",
  "2018-12-08",
  "2018-12-09",
  "2018-12-10",
  "2018-12-11",
  "2018-12-12",
  "2018-12-13",
  "2018-12-14"
];

// fill cloud firestore with foods
module.exports = {
  getFoodsFromAPI: async function() {
    var foods = [];
    for (var i = 0; i < dates.length; i++) {
      var date = dates[i];
      for (var j = 0; j < locations.length; j++) {
        var loc = locations[j];
        var json = await getAPIData(loc, date);
        var listOfFoods = getListOfFoods(json);
        // console.log("foods: " + listOfFoods);
        if (listOfFoods) {
          foods = foods.concat(listOfFoods);
        }
      }
    }
    console.log(foods);
    console.log("num foods: " + foods.length);
    foods = removeDuplicates(foods);
    await uploadToFirestore(foods);
    return true;
  }
};

function getListOfFoods(json) {
  if (!json.menu) {
    return [];
  }
  var periods = json.menu.periods;
  var foods = [];
  for (var i = 0; i < periods.length; i++) {
    var categories = periods[i].categories;
    for (var j = 0; j < categories.length; j++) {
      var items = categories[j].items;
      for (var k = 0; k < items.length; k++) {
        // console.log(items[k].name);
        foods.push(items[k].name.toString());
      }
    }
  }
  return foods;
}

async function uploadToFirestore(foods) {
  var db = admin.firestore();
  var ref = db.collection("foods");
  for (var i = 0; i < foods.length; i++) {
    if (foods[i].includes("/")) {
      foods[i] = foods[i].replace("/", "");
    }
    await ref.doc(foods[i]).set({ name: foods[i] });
  }
}

function getAPIData(location, date) {
  return new Promise(function(resolve) {
    axios
      .get(
        "https://api.dineoncampus.com/v1/location/menu?site_id=5751fd2b90975b60e048929a&location_id=" +
          location +
          "&platform=0&date=" +
          date
      )
      .then(response => {
        var stringData = JSON.stringify(response.data);
        var data = response.data;
        resolve(data);
      })
      .catch(error => {
        console.log(error);
        resolve("error");
      });
  });
}

function removeDuplicates(foods) {
  var noDups = foods.filter(function(item, pos) {
    return foods.indexOf(item) == pos;
  });
  return noDups;
}

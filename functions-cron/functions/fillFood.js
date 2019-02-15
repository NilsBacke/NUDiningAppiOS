// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const admin = require("firebase-admin");
const axios = require("axios");
var querystring = require("querystring");
admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const apiKey1 = "f3767bc0c5cc4317a90373ca43022980";
// const apiKey2 = "5ae3a0bf3c034f28909df9c236b69308";
const host = "https://api.cognitive.microsoft.com";
const path = "/bing/v7.0/images/search";

const locations = [
  // "5b9bd1c41178e90d4774210e",
  // "586d17503191a27120e60dec",
  "586d05e4ee596f6e6c04b527"
];

const dates = [
  // "2019-01-14",
  // "2019-01-15",
  // "2019-01-16",
  // "2019-01-17"
  // "2019-01-18",
  // "2019-01-19",
  // "2019-01-20",
  // "2019-01-21",
  // "2019-01-22",
  // "2019-01-22",
  "2019-02-01"
];

// fill cloud firestore with foods
module.exports = {
  getFoodsFromAPI: async function() {
    var foodsNames = []; // list of strings
    for (var i = 0; i < dates.length; i++) {
      var date = dates[i];
      for (var j = 0; j < locations.length; j++) {
        var loc = locations[j];
        var json = await getAPIData(loc, date);
        var listOfFoods = getDictOfFoods(json);
        // console.log("foods: " + listOfFoods);
        if (listOfFoods) {
          foodsNames = foodsNames.concat(listOfFoods);
        }
      }
    }
    console.log(foodsNames);
    console.log("7000: " + foodsNames.length);
    foodsNames = removeDuplicates(foodsNames);
    foodsNames = sort(foodsNames);
    console.log("num foods: " + foodsNames.length);
    var foodItems = [];
    for (var i = 0; i < foodsNames.length; i++) {
      if (!(await foodExists(foodsNames[i]))) {
        var imageURL = await getImageURL(foodsNames[i]);
        await sleep(5); // 5 ms
        foodItems.push(new Item(foodsNames[i], imageURL));
      }
    }
    console.log("foodItemsLength: " + foodItems.length);
    await uploadToFirestore(foodItems);
    return true;
  }
};

function getDictOfFoods(json) {
  if (!json.menu) {
    return [];
  }
  var periods = json.menu.periods;
  var foods = []; // list of strings
  for (var i = 0; i < periods.length; i++) {
    var categories = periods[i].categories;
    for (var j = 0; j < categories.length; j++) {
      var items = categories[j].items;
      for (var k = 0; k < items.length; k++) {
        // console.log(items[k].name);
        var name = items[k].name.toString();
        foods.push(name);
      }
    }
  }
  return foods;
}

async function uploadToFirestore(foods) {
  var db = admin.firestore();
  var ref = db.collection("foods");
  for (var i = 0; i < foods.length; i++) {
    if (
      foods[i].name &&
      foods[i].imageURL &&
      foods[i].name instanceof String &&
      foods[i].imageURL instanceof String &&
      foods[i].name.length != 0 &&
      foods[i].name != "" &&
      foods[i].imageURL.length != 0 &&
      foods[i].imageURL != ""
    ) {
      if (foods[i].name.includes("/")) {
        foods[i] = foods[i].name.replace("/", "");
      }
      await ref
        .doc(foods[i].name)
        .set({ name: foods[i].name, imageURL: foods[i].imageURL });
    }
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

function getImageURL(query) {
  var searchQuery = querystring.stringify({ q: query });
  let url = host + path + "?" + searchQuery;

  return new Promise(function(resolve) {
    axios({
      method: "get",
      url: url,
      headers: { "Ocp-Apim-Subscription-Key": apiKey1 }
    })
      .then(response => {
        var data = response.data;
        console.log(query + " " + JSON.stringify(response.data));
        resolve(data.value[0].contentUrl);
      })
      .catch(error => {
        console.log(error);
        resolve("error");
      });
  });
}

function sort(arr) {
  arr.sort(function(a, b) {
    if (a < b) {
      return -1;
    }
    if (a > b) {
      return 1;
    }
    return 0;
  });
  return arr;
}

function removeDuplicates(foodsArray) {
  // var listSoFar = []; // names
  // var foods = foodsArray;
  // for (var i = 0; i < foods.length; i++) {
  //   if (listSoFar.includes(foods[i].name)) {
  //     foods.splice(i, 1);
  //     i--;
  //   } else {
  //     listSoFar.push(foods[i].name);
  //   }
  // }
  // return foods;
  var uniqueArray = foodsArray.filter(function(item, pos) {
    return foodsArray.indexOf(item) == pos;
  });
  return uniqueArray;
}

function sleep(ms) {
  return new Promise(resolve => {
    setTimeout(resolve, ms);
  });
}

async function foodExists(item) {
  var db = admin.firestore();
  var ref = db.collection("foods");
  var snapshot = await ref.get();
  snapshot.forEach(doc => {
    if (doc.data()["name"] === item) {
      return true;
    }
  });
  return false;
}

function Item(name, imageURL) {
  this.name = name;
  this.imageURL = imageURL;
  return this;
}

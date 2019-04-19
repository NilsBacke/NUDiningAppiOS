// admin.js
// File which initializes the Admin SDK for use with cloud Functions
// To use the admin database reference in a cloud function, add these lines to the top of the file:
//
// const {
//   db,
// } = require('./admin.js');
//

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault()
});
const db = admin.firestore();

module.exports = {
  db,
}

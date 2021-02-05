const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

const fcm = admin.messaging();

exports.myFunction = functions.firestore
    .document('missing_livestock/{livestock}')
    .onCreate((snapshot,context) => {
          const payload = {
            notification: {
              title: "Missing Livestock",
              body: snapshot.data().category + " went missing in " + snapshot.data().address,
              sound: "default",
            },
          };
          console.log(snapshot.data());
          return fcm.sendToTopic("MissingLivestock", payload);
    });

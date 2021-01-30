const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

const fcm = admin.messaging();

exports.myFunction = functions.firestore
    .document('missing_livestock/{livestock}')
    .onCreate((snapshot,context) => {
          const payload = {
            notification: {
              title: "Test",
              body: "MISSING",
              sound: "default",
            },
          };
          
          token = "dwzm4HVYTrKdk7v9gXlFPA:APA91bFIra_xMLxx9aueX3HIRz3Q4PIM389Jdu6D7K7OKUPYLBlQ747FcNY7u9rvBsWLx8JdQK3-kMuWqGpQasc3qpSiwDNdMMKYSY5cgEOD5DdXQME1oB82lwAzozUqUCY1O7ywcBOt";

          return fcm.sendToDevice(token, payload);
    });

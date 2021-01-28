const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

exports.myFunction = functions.firestore
    .document('missing_livestock/{livestock}')
    .onCreate((snapshot,context) => {
                // console.log(snapshot.data());
        return  admin.messaging().sendMulticast({
            tokens: ["token_1", "token_2"],
            notification: {
              title: "Weather Warning!",
              body: "A new weather warning has been issued for your location.",
              imageUrl: "https://my-cdn.com/extreme-weather.png",
            },
          });

    });

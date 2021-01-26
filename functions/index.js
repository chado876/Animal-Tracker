const functions = require("firebase-functions");
const admin = require('firebase-admin');

exports.myFunction = functions.firestore
    .document('missing_livestock/{livestock}')
    .onCreate((snapshot,context) => {
        // return admin.messaging().sendAll('test',{notification: {
        //     title: "Missing",
        //     body: snapshot.data.category,
        //     clickAction: 'FLUTTER_NOTIFICATION_CLICK'
        // }}); WIP
        console.log(snapshot.data());

        return;
    });

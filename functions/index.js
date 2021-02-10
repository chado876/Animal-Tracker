
const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

const fcm = admin.messaging();

exports.missingLivestock = functions.firestore
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

    exports.missingLivestockbyParameter = functions.firestore
    .document('parameters/{user}/livestock/{livestock}')
    .onWrite((snapshot,context) => {
          
          const livestockBefore = snapshot.before.data();
          const livestockAfter = snapshot.after.data();
          var outOfBounds = false;

          if(livestockAfter.isCircle == true){
    
            var inside = checkIfInside(livestockAfter.livestock.latitude,livestockAfter.livestock.longitude,
              livestockAfter.Circle.center.latitude,livestockAfter.Circle.center.longitude, livestockAfter.Circle.radius);
              console.log("INSIDE " + inside);

            if(inside == false){
                outOfBounds = true;
              }
          }
            console.log("LIVESTOCK IS OUT OF BOUNDS " + outOfBounds);

            if(outOfBounds == true){
              console.log("OUT OF BONDS!!!");
              const payload = {
                notification: {
                  title: "Livestock out of Bounds ",
                  body:  "Livestock #" + livestockAfter.livestock.id + " has gone out of bounds!",
                  sound: "default",
                  icon: "./templogo.png"
                },
              };
  
            return fcm.sendToTopic("ParameterNotification", payload);
            }
           
            return;
    });


function checkIfInside(pointx,pointy,circlex,circley,rad) {


    let newRadius = distanceInKmBetweenEarthCoordinates(pointx, pointy, circlex, circley);
    console.log(newRadius)

    if( newRadius < rad ) {
        //point is inside the circle
        console.log('inside')
        return true;
    }
    else if(newRadius > rad) {
        //point is outside the circle
        console.log('outside')
        return false;
    }
    else {
        //point is on the circle
        console.log('on the circle')
        return true;
    }

}

function distanceInKmBetweenEarthCoordinates(lat1, lon1, lat2, lon2) {
  var earthRadiusKm = 6371;

  var dLat = degreesToRadians(lat2-lat1);
  var dLon = degreesToRadians(lon2-lon1);

  lat1 = degreesToRadians(lat1);
  lat2 = degreesToRadians(lat2);

  var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
          Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
  var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
  return earthRadiusKm * c;
}

function degreesToRadians(degrees) {
  return degrees * Math.PI / 180;
}
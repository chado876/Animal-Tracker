import 'package:animal_tracker/models/livestock.dart';
import 'package:animal_tracker/models/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './auth_helper.dart';
import '../models/parameter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParameterHelper {
  static Future<void> postParameter(
      BuildContext ctx, Parameter parameter) async {
    UserObject currentUser = await AuthHelper.fetchData();

    int pointsLength = 0;
    if (parameter.isPolygon) {
      pointsLength = parameter.polygon.points.length;
      print(parameter.polygon.points.length);
      print(parameter.polygon.points[0].toString());
      print(parameter.polygon.points[1].toString());
      print(parameter.polygon.points[2].toString());
      print(parameter.polygon.points[3].toString());
      // print(parameter.polygon.points[4].toString());
    }

    try {
      await FirebaseFirestore.instance
          .collection('parameters')
          .doc(currentUser.uid)
          .collection('livestock')
          .doc(parameter.livestock.tagId)
          .set({
        "livestock": {
          "id": parameter.livestock.tagId,
          "ownerUid": parameter.livestock.uId,
          "latitude": parameter.livestock.latitude,
          "longitude": parameter.livestock.longitude,
        },
        "isCircle": parameter.isCircle,
        "isPolygon": parameter.isPolygon,
        "Circle": parameter.circle != null
            ? {
                "center": {
                  "latitude": parameter.circle.center.latitude,
                  "longitude": parameter.circle.center.longitude,
                },
                "circleId": parameter.circle.circleId.value,
                "fillColor": parameter.circle.fillColor.value,
                "radius": parameter.circle.radius,
                "strokeColor": parameter.circle.strokeColor.value,
                "strokeWidth": parameter.circle.strokeWidth
              }
            : null,
        "Polygon": parameter.polygon != null
            ? {
                "polygonId": parameter.polygon.polygonId.value,
                // "points": parameter.polygon.points
                //     .map((point) => point.toJson())
                //     .toList(),
                "points": {
                  "point0": {
                    "latitude": parameter.polygon.points[0].latitude,
                    "longitude": parameter.polygon.points[0].longitude,
                  },
                  "point1": {
                    "latitude": parameter.polygon.points[1].latitude,
                    "longitude": parameter.polygon.points[1].longitude,
                  },
                  if (3 <= pointsLength)
                    "point2": {
                      "latitude": parameter.polygon.points[2].latitude,
                      "longitude": parameter.polygon.points[2].longitude,
                    },
                  if (4 <= pointsLength)
                    "point3": {
                      "latitude": parameter.polygon.points[3].latitude,
                      "longitude": parameter.polygon.points[3].longitude,
                    },
                  if (5 <= pointsLength)
                    "point4": {
                      "latitude": parameter.polygon.points[4].latitude,
                      "longitude": parameter.polygon.points[4].longitude,
                    },
                  if (6 <= pointsLength)
                    "point5": {
                      "latitude": parameter.polygon.points[5].latitude,
                      "longitude": parameter.polygon.points[5].longitude,
                    },
                },
                "strokeWidth": parameter.polygon.strokeWidth,
                "strokeColor": parameter.polygon.strokeColor.value,
                "fillColor": parameter.polygon.fillColor.value
              }
            : null,
      });

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text("Parameter for " +
              parameter.livestock.tagId +
              " added successfully."),
          backgroundColor: Colors.green,
        ),
      );
      print("SUCCESS");
    } on PlatformException catch (err) {
      var message = 'An error occurred, please try again!';

      if (err.message != null) {
        message = err.message;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      print("FAIL");
    } catch (err) {
      print(err);
    }
  }

  static Future<List<Parameter>> getParameters() async {
    UserObject currentUser = await AuthHelper.fetchData();
    List<Parameter> parameters = [];

    QuerySnapshot documents = await FirebaseFirestore.instance
        .collection('parameters')
        .doc(currentUser.uid)
        .collection('livestock')
        .get();

    for (var doc in documents.docs) {
      List<Point> points = [];
      if (doc.data()['Polygon'] != null) {
        for (int i = 0; i < 5; i++) {
          if (doc.data()['Polygon']['points']['point$i'] != null)
            points.add(Point(
                latitude: doc.data()['Polygon']['points']['point$i']
                    ['latitude'],
                longitude: doc.data()['Polygon']['points']['point$i']
                    ['longitude']));
        }

// for (var point in doc.data()['Polygon']['points']) {
//           points.add(
//               Point(latitude: point['latitude'], longitude: point['latitude']));
//         }
      }

      parameters.add(
        Parameter(
          isCircle: doc.data()['isCircle'],
          isPolygon: doc.data()['isPolygon'],
          livestock: Livestock(
              latitude: doc.data()['livestock']['latitude'],
              longitude: doc.data()['livestock']['longitude'],
              tagId: doc.data()['livestock']['id'],
              uId: doc.data()['livestock']['ownerUid']),
          circle: doc.data()['Circle'] != null
              ? Circle(
                  circleId: CircleId(doc.data()['Circle']['circleId']),
                  center: LatLng(doc.data()['Circle']['center']['latitude'],
                      doc.data()['Circle']['center']['longitude']),
                  fillColor: Color(doc.data()['Circle']['fillColor']),
                  radius: doc.data()['Circle']['radius'],
                  strokeColor: Color(doc.data()['Circle']['strokeColor']),
                  strokeWidth: doc.data()['Circle']['strokeWidth'])
              : null,
          polygon: doc.data()['Polygon'] != null
              ? Polygon(
                  polygonId: PolygonId(doc.data()['Polygon']['polygonId']),
                  strokeColor: Color(doc.data()['Polygon']['strokeColor']),
                  strokeWidth: doc.data()['Polygon']['strokeWidth'],
                  fillColor: Color(doc.data()['Polygon']['fillColor']))
              : null,
          points: points,
        ),
      );
    }

    return parameters;
  }
}

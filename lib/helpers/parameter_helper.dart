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
                "points": parameter.polygon.points
                    .map((point) => point.toJson())
                    .toList(),
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
      parameters.add(
        Parameter(
          isCircle: doc.data()['isCircle'],
          isPolygon: doc.data()['isPolygon'],
          livestock: Livestock(
              latitude: doc.data()['livestock']['latitude'],
              longitude: doc.data()['livestock']['longitude'],
              tagId: doc.data()['livestock']['id'],
              uId: doc.data()['livestock']['ownerUid']),
          circle: Circle(
              circleId: CircleId(doc.data()['Circle']['circleId']),
              center: LatLng(doc.data()['Circle']['center']['latitude'],
                  doc.data()['Circle']['center']['longitude']),
              fillColor: Color(doc.data()['Circle']['fillColor']),
              radius: doc.data()['Circle']['radius'],
              strokeColor: Color(doc.data()['Circle']['strokeColor']),
              strokeWidth: doc.data()['Circle']['strokeWidth']),
          polygon: doc.data()['Polygon'] != null
              ? Polygon(
                  polygonId: PolygonId(doc.data()['Polygon']['polygonId']),
                  points: doc.data()['Polygon']['points'],
                  strokeColor: doc.data()['Polygon']['strokeColor'],
                  strokeWidth: doc.data()['Polygon']['strokeWidth'],
                  fillColor: doc.data()['Polygon']['fillColor'])
              : null,
        ),
      );
    }

    return parameters;
  }
}

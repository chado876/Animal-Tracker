import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/livestock.dart';
import '../models/profile.dart';
import './auth_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class LivestockHelper {
  UserObject currentUser;
  Livestock liveStock;

  static Future<List<Livestock>> getLivestockData() async {
    UserObject currentUser = await AuthHelper.fetchData();
    print(currentUser.uid);
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('livestock')
        .get();

    querySnapshot.docs.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data()['address'],
          uId: livestock.data()['uId'],
          tagId: livestock.data()['tagId'],
          category: livestock.data()['category'],
          // imageUrls: livestock.data()['image_urls'],
          latitude: livestock.data()['latitude'],
          longitude: livestock.data()['longitude']);

      allLivestock.add(item);
    });
    return allLivestock;
  }

  static Future<List<Livestock>> getLivestockDataByCategory(
      String category) async {
    UserObject currentUser = await AuthHelper.fetchData();
    print(currentUser.uid);
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('livestock')
        .where('category', isEqualTo: category)
        .get();

    querySnapshot.docs.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data()['address'],
          uId: livestock.data()['uId'],
          tagId: livestock.data()['tagId'],
          category: livestock.data()['category'],
          // imageUrls: livestock.data()['image_urls'],
          latitude: livestock.data()['latitude'],
          longitude: livestock.data()['longitude']);

      allLivestock.add(item);
    });
    return allLivestock;
  }

  static Future<Stream<QuerySnapshot>> queryByCategory(String category) async {
    UserObject currentUser = await AuthHelper.fetchData();

    Stream<QuerySnapshot> querySnapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('livestock')
        .where('category', isEqualTo: category)
        .snapshots();

    return querySnapshot;
  }

  static Future<bool> checkIfCategoryExists(String category) async {
    UserObject currentUser = await AuthHelper.fetchData();

    bool exists = false;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('livestock')
        .where('category', isEqualTo: category)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        exists = true;
      }
    });

    return exists;
  }

  static Future<List<Livestock>> getLivestockDataByTagID(String tagID) async {
    UserObject currentUser = await AuthHelper.fetchData();
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('livestock')
        .where('tagId', isEqualTo: tagID)
        .get();

    querySnapshot.docs.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data()['address'],
          uId: livestock.data()['uId'],
          tagId: livestock.data()['tagId'],
          category: livestock.data()['category'],
          imageUrls: (livestock.data()['image_urls'] as List)
              ?.map((item) => item as String)
              ?.toList(),
          latitude: livestock.data()['latitude'],
          longitude: livestock.data()['longitude']);

      print(livestock.data()['image_urls']);
      allLivestock.add(item);
    });
    return allLivestock;
  }

  static Future<void> postMissingLivestock(
      Livestock livestock, BuildContext ctx) async {
    var currentUser = await AuthHelper.fetchData();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('livestock')
          .doc(livestock.tagId)
          .update({"isMissing": true}).then((value) async {
        await FirebaseFirestore.instance
            .collection('missing_livestock')
            .doc(livestock.tagId)
            .set({
          'uId': currentUser.uid,
          'owner_name': currentUser.firstName + " " + currentUser.lastName,
          'tagId': livestock.tagId,
          'category': livestock.category,
          'weight': livestock.weight,
          'distinguishingFeatures': livestock.distinguishingFeatures,
          'image_urls': livestock.imageUrls,
          'latitude': livestock.latitude,
          'longitude': livestock.longitude,
          'address': livestock.address,
        });
      });

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text("Livestock with tag ID of " +
              livestock.tagId +
              " marked as missing successfully."),
          backgroundColor: Colors.green,
        ),
      );
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
    } catch (err) {
      print(err);
    }
  }

  static Future<List<Livestock>> getMissingLivestock() async {
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('missing_livestock').get();

    querySnapshot.docs.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data()['address'],
          uId: livestock.data()['uId'],
          tagId: livestock.data()['tagId'],
          category: livestock.data()['category'],
          imageUrls: (livestock.data()['image_urls'] as List)
              ?.map((item) => item as String)
              ?.toList(),
          latitude: livestock.data()['latitude'],
          longitude: livestock.data()['longitude']);

      allLivestock.add(item);
    });
    return allLivestock;
  }

  static Future<void> setLivestockAsFound(
      String tagId, BuildContext ctx) async {
    var currentUser = await AuthHelper.fetchData();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('livestock')
          .doc(tagId)
          .update({"isMissing": false}).then((value) async {
        await FirebaseFirestore.instance
            .collection('missing_livestock')
            .doc(tagId)
            .delete();
      });

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text("Livestock with tag ID of " +
              tagId +
              " marked as found successfully."),
          backgroundColor: Colors.green,
        ),
      );
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
    } catch (err) {
      print(err);
    }
  }
}

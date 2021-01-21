import '../models/livestock.dart';
import '../models/profile.dart';
import './auth_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class LivestockHelper {
  UserData currentUser;
  Livestock liveStock;

  static Future<List<Livestock>> getLivestockData() async {
    UserData currentUser = await AuthHelper.fetchData();
    print(currentUser.uid);
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('livestock')
        .getDocuments();

    querySnapshot.documents.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data['address'],
          uId: livestock.data['uId'],
          tagId: livestock.data['tagId'],
          category: livestock.data['category'],
          // imageUrls: livestock.data['image_urls'],
          latitude: livestock.data['latitude'],
          longitude: livestock.data['longitude']);

      allLivestock.add(item);
    });
    return allLivestock;
  }

  static Future<List<Livestock>> getLivestockDataByCategory(
      String category) async {
    UserData currentUser = await AuthHelper.fetchData();
    print(currentUser.uid);
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('livestock')
        .where('category', isEqualTo: category)
        .getDocuments();

    querySnapshot.documents.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data['address'],
          uId: livestock.data['uId'],
          tagId: livestock.data['tagId'],
          category: livestock.data['category'],
          // imageUrls: livestock.data['image_urls'],
          latitude: livestock.data['latitude'],
          longitude: livestock.data['longitude']);

      allLivestock.add(item);
    });
    return allLivestock;
  }

  static Future<Stream<QuerySnapshot>> queryByCategory(String category) async {
    UserData currentUser = await AuthHelper.fetchData();

    Stream<QuerySnapshot> querySnapshot = Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('livestock')
        .where('category', isEqualTo: category)
        .snapshots();

    return querySnapshot;
  }

  static Future<List<Livestock>> getLivestockDataByTagID(String tagID) async {
    UserData currentUser = await AuthHelper.fetchData();
    print(currentUser.uid);
    List<Livestock> allLivestock = [];

    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .collection('livestock')
        .where('tagId', isEqualTo: tagID)
        .getDocuments();

    querySnapshot.documents.forEach((livestock) {
      Livestock item = Livestock(
          address: livestock.data['address'],
          uId: livestock.data['uId'],
          tagId: livestock.data['tagId'],
          category: livestock.data['category'],
          imageUrls: (livestock.data['image_urls'] as List)
              ?.map((item) => item as String)
              ?.toList(),
          latitude: livestock.data['latitude'],
          longitude: livestock.data['longitude']);

      print(livestock.data['image_urls']);
      allLivestock.add(item);
    });
    return allLivestock;
  }
  //
}

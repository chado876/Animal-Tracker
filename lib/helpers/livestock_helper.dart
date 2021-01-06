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
    // Firestore.instance
    //     .collection('users')
    //     .document(currentUser.uid)
    //     .collection('livestock')
    //     .snapshots()
    //     .listen((snapshot) {
    //   snapshot.documents.forEach((livestock) {
    //     print(snapshot.documents[0].data.toString());
    //     Livestock item = Livestock(
    //         address: livestock.data['address'],
    //         uId: livestock.data['uId'],
    //         tagId: livestock.data['tagId'],
    //         category: 'SHEEP',
    //         imageUrls: ['ww.com'],
    //         latitude: 20.0,
    //         longitude: 20.0);

    //     allLivestock.add(item);
    //   });
    // });

    return allLivestock;
  }
  //
}

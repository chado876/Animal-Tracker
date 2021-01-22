import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile.dart';

class AuthHelper {
  static Future<UserObject> fetchData() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user;
    String firstName;
    String lastName;
    String parish;
    String uid;
    String photoLink;

    user = await _auth.currentUser;
    uid = user.uid;
    final document = FirebaseFirestore.instance.collection('users').doc(uid);

    await document.get().then<dynamic>((DocumentSnapshot snapshot) async {
      firstName = snapshot.data()['firstName'];
      lastName = snapshot.data()['lastName'];
      parish = snapshot.data()['parish'];
      photoLink = snapshot.data()['image_url'];
    });

    return UserObject(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        parish: parish,
        photoLink: photoLink);
  }

  static Future<User> getCurrentUser() async {
    return await new Future(() => FirebaseAuth.instance.currentUser);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/livestock.dart';
import '../models/profile.dart';
import '../models/tip.dart';
import './auth_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TipHelper {
  static Future<void> postTip(
      String uId, String tagId, String tip, BuildContext ctx) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .collection('tips')
          .doc()
          .set({
        'tagId': tagId,
        'tip': tip,
        'dateSent': DateTime.now(),
      });

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text("Anonymous tip sent for " + tagId + "  successfully."),
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

  static Future<Stream<QuerySnapshot>> queryTips(
      String uid, BuildContext ctx) async {
    Stream<QuerySnapshot> querySnapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tips')
        .snapshots();

    return querySnapshot;
  }

  static Future<List<Tip>> getAllTips(BuildContext ctx) async {
    UserObject currentUser = await AuthHelper.fetchData();

    List<Tip> tips = [];
    print(currentUser.uid);

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('tips')
          .get();

      print("HERE" + querySnapshot.size.toString());

      querySnapshot.docs.forEach((element) {
        Tip tip = Tip(
            id: element.id,
            dateSent: element['dateSent'].toDate(),
            tipMessage: element['tip'],
            tagId: element['tagId']);
        print(tip.tipMessage);
        tips.add(tip);
      });
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
    tips.forEach((element) {
      print(element.tipMessage);
    });
    return tips;
  }

  static Future<int> getNumberOfTips(BuildContext ctx) async {
    UserObject currentUser = await AuthHelper.fetchData();

    int length = 0;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('tips')
          .get();

      length = querySnapshot.size;
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
    print(length);
    return length;
  }

  static Future<bool> deleteTip(BuildContext ctx, String tipId) async {
    UserObject currentUser = await AuthHelper.fetchData();
    print(currentUser.uid);
    bool success = true;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('tips')
          .doc(tipId)
          .delete();

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
            content: Text("Tip deleted successfully."),
            backgroundColor: Colors.green),
      );
    } on PlatformException catch (err) {
      success = false;
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

    return success;
  }
}

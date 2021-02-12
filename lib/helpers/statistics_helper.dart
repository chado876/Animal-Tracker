import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/livestock.dart';
import '../models/profile.dart';
import './auth_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'livestock_helper.dart';

class StatsHelper {
  static Future<Map<String, int>> categoryChecker() async {
    List<String> categories = [
      "Cattle",
      "Sheep",
      "Pig",
      "Goat",
      "Horse",
      "Donkey",
      "Other",
    ];

    Map<String, int> livestock = {
      "Cattle": 0,
      "Sheep": 0,
      "Pig": 0,
      "Goat": 0,
      "Horse": 0,
      "Donkey": 4,
      "Other": 0,
    };

    for (var x in livestock.keys) {
      final number = await LivestockHelper.getNumberOfLivestock(x);
      print("Number: $number");
      livestock.update(x, (value) => number);
    }
    print(livestock);
    return livestock;
  }

  static Future<int> getNumberOfMissingLivestock() async {
    UserObject currentUser = await AuthHelper.fetchData();

    int result = 0;

    await FirebaseFirestore.instance
        .collection('missing_livestock')
        .where('uId', isEqualTo: currentUser.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        result = value.docs.length;
      }
    });

    return result;
  }
}

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

    // livestock.forEach((key, value) async {
    //   await LivestockHelper.getNumberOfLivestock(key)
    //       .then((res) => value = res);
    // });

    print(livestock);
    return livestock;
  }
}

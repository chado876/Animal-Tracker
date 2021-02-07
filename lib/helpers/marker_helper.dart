import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerHelper {
  static Future<BitmapDescriptor> setIcon(String category) async {
    switch (category) {
      case "Cattle":
        {
          return await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(24, 24)),
              'assets/images/cow_marker2.png');
        }
      case "Horse":
        {
          return await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(24, 24)),
              'assets/images/horse_marker.png');
        }
      case "Pig":
        {
          return await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(12, 12)),
              'assets/images/pig_marker.png');
        }
      case "Goat":
        {
          return await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(48, 48)),
              'assets/images/goat_marker.png');
        }
      case "Sheep":
        {
          return await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(48, 48)),
              'assets/images/sheep_marker.png');
        }
      case "Donkey":
        {
          return await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(48, 48)),
              'assets/images/donkey_marker.png');
        }
    }
  }
}

import 'package:flutter/foundation.dart';

class Livestock {
  String tagId;
  String uId;
  String category;
  String address;
  String distinguishingFeatures;
  double longitude;
  double latitude;
  double weight;
  List<String> imageUrls;

  Livestock(
      {@required this.tagId,
      @required this.uId,
      @required this.category,
      @required this.address,
      this.distinguishingFeatures,
      @required this.longitude,
      @required this.latitude,
      this.weight,
      @required this.imageUrls});
}

import 'package:animal_tracker/models/livestock.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parameter {
  Livestock livestock;
  bool isPolygon;
  bool isCircle;
  Circle circle;
  Polygon polygon;

  Parameter(
      {@required this.isPolygon,
      @required this.isCircle,
      @required this.livestock,
      this.circle,
      this.polygon});
}

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mapsToolkit;

class AreaChecker {
  static bool checkIfPointisInArea(LatLng point, List<LatLng> polyLines) {
    bool geodesic = false;
    List<mapsToolkit.LatLng> listOfPoints = [];

    polyLines.forEach((element) {
      listOfPoints.add(mapsToolkit.LatLng(element.latitude, element.longitude));
    });

    return mapsToolkit.PolygonUtil.containsLocation(
        mapsToolkit.LatLng(37.42713664245048, -122.08062720043169),
        listOfPoints,
        geodesic);
  }
}

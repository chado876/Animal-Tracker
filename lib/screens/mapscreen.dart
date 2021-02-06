import 'dart:collection';

import 'package:animal_tracker/helpers/parameter_helper.dart';
import 'package:animal_tracker/models/parameter.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../helpers/livestock_helper.dart';
import '../models/livestock.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng _initialcameraposition =
      LatLng(18.018139159603447, -76.74373834686291);
  GoogleMapController _controller;
  Location _location = Location();
  Set<Marker> _markers = {};
  List<Parameter> parameters = [];
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Circle> _circles = HashSet<Circle>();

  @override
  void initState() {
    getLivestock();
    setParameters();
    super.initState();
  }

  void setParameters() async {
    parameters = await ParameterHelper.getParameters();
    print(parameters.length);
    _setCircles();
  }

  void getLivestock() async {
    List<Livestock> livestock = await LivestockHelper.getLivestockData();
    addMarker(livestock);
  }

  // Draw Polygon to the map
  void _setPolygon() {
    for (var param in parameters) {
      if (param.isPolygon) {
        _polygons.add(Polygon(
          polygonId: param.polygon.polygonId,
          points: param.polygon.points,
          strokeWidth: param.polygon.strokeWidth,
          strokeColor: param.polygon.strokeColor,
          fillColor: Colors.yellow.withOpacity(0.15),
        ));
      }
    }
  }

  // Set circles as points to the map
  void _setCircles() {
    for (var param in parameters) {
      if (param.isCircle) {
        _circles.add(Circle(
            circleId: param.circle.circleId,
            center: param.circle.center,
            radius: param.circle.radius,
            fillColor: Colors.redAccent.withOpacity(0.5),
            strokeWidth: 3,
            strokeColor: Colors.redAccent));
      }
    }
  }

  void addMarker(List<Livestock> livestock) {
    Set<Marker> markers = {};
    livestock.forEach((element) async {
      markers.add(
        Marker(
          markerId: MarkerId(element.tagId),
          position: LatLng(element.latitude, element.longitude),
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(48, 48)), 'assets/images/cow.png'),
        ),
      );
    });

    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 95),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition, zoom: 15.0),
              mapType: MapType.hybrid,
              // onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: Set.from(_markers),
              circles: _circles,
            ),
          ],
        ),
      ),
    );
  }
}

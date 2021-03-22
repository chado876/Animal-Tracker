import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:animal_tracker/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../helpers/livestock_helper.dart';
import '../models/livestock.dart';
import 'dart:math' as Math;

import '../utilities/areaChecker.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mapsToolkit;

import '../helpers/parameter_helper.dart';
import '../models/parameter.dart';
import '../helpers/marker_helper.dart';

class MapPage extends StatefulWidget {
  final Livestock livestock;
  MapPage({@required this.livestock});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Circle> _circles = HashSet<Circle>();
  Set<Marker> _markers = HashSet<Marker>();

  double radius = 50;

  //ids
  int _circleIdCounter = 1;

  // Type controllers
  bool _isCircle = false;

  // Set circles as points to the map
  void _setCircle() {
    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    _circles = {};
    _circles.add(Circle(
        circleId: CircleId(circleIdVal),
        center: LatLng(widget.livestock.latitude, widget.livestock.longitude),
        radius: radius,
        fillColor: Colors.greenAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: Colors.greenAccent));
  }

  // Set Markers to the map
  Future<void> _setMarkers() async {
    final String markerIdVal = 'marker_id_${widget.livestock.tagId}';
    BitmapDescriptor marker =
        await MarkerHelper.setIcon(widget.livestock.category);
    setState(() {
      print(
          'Marker | Latitude: ${widget.livestock.latitude}  Longitude: ${widget.livestock.latitude}');
      _markers.add(
        Marker(
            markerId: MarkerId(markerIdVal),
            position:
                LatLng(widget.livestock.latitude, widget.livestock.longitude),
            icon: marker),
      );
    });
  }

  @override
  void initState() {
    _setMarkers();
    _setCircle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Set Digital Parameters'),
          centerTitle: true,
          actions: [
            if (_circles.isNotEmpty)
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  print(_isCircle);
                  ParameterHelper.postParameter(
                      context,
                      Parameter(
                          isCircle: _isCircle,
                          isPolygon: false,
                          livestock: widget.livestock,
                          circle: _circles.isNotEmpty ? _circles.first : null,
                          polygon: null));
                },
              ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    widget.livestock.latitude, widget.livestock.longitude),
                zoom: 18,
              ),
              mapType: MapType.normal,
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              onTap: null,
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: <Widget>[
                  RaisedButton(
                    color: Colors.black,
                    onPressed: () {
                      setState(() {
                        radius = radius + 10;
                        _setCircle();
                      });
                    },
                    child: Text(
                      'Larger',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    color: Colors.black,
                    onPressed: () {
                      setState(() {
                        radius = radius - 10;
                        _setCircle();
                      });
                    },
                    child: Text(
                      'Smaller',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapPage extends StatefulWidget {
  final Livestock livestock;
  final String tagFrequency;
  final String tagType;

  MapPage(
      {@required this.livestock,
      @required this.tagFrequency,
      @required this.tagType});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Circle> _circles = HashSet<Circle>();
  Set<Marker> _markers = HashSet<Marker>();

  double radius = 0;
  double maxRange = 0;
  double increment = 0;

  //ids
  int _circleIdCounter = 1;

  // Type controllers
  bool _isCircle = true;

  @override
  void initState() {
    _setParams();
    _setMarkers();
    _setCircle();
    super.initState();
  }

  // Set circles as points to the map
  void _setCircle() {
    final String circleIdVal = widget.livestock.tagId.toString();
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

  void _setParams() {
    switch (widget.tagType) {
      case "Active":
        switch (widget.tagFrequency) {
          case "UHF":
            maxRange = 35;
            increment = 5;
            break;
          case "HF":
            maxRange = 1.5;
            increment = 0.3;
            break;
          case "LF":
            maxRange = 1;
            increment = 0.2;
            break;
        }
        break;
      case "Passive":
        switch (widget.tagFrequency) {
          case "UHF":
            maxRange = 6;
            increment = 1;
            break;
          case "HF":
            maxRange = 1.5;
            increment = 0.3;
            break;
          case "LF":
            maxRange = 1;
            increment = 0.2;
            break;
        }
        break;
    }

    radius = maxRange;
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
                  ParameterHelper.postParameter(
                          context,
                          Parameter(
                              isCircle: _isCircle,
                              isPolygon: false,
                              livestock: widget.livestock,
                              circle:
                                  _circles.isNotEmpty ? _circles.first : null,
                              polygon: null))
                      .then((value) => Navigator.of(context).pop());
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
                    color: Colors.green,
                    onPressed: () {
                      setState(() {
                        if (radius + increment <= maxRange) radius = radius + increment;
                        _setCircle();
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Larger',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        radius = radius - increment;
                        _setCircle();
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'Smaller',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

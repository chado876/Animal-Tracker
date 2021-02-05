import 'dart:async';
import 'dart:collection';
import 'dart:io';

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

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polyLines = HashSet<Polyline>();

  bool _drawPolygonEnabled = false;
  List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  int _lastXCoordinate, _lastYCoordinate;

  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons2 = HashSet<Polygon>();
  Set<Circle> _circles = HashSet<Circle>();
  List<LatLng> _polygonLatLngs = [];
  double radius;
  GoogleMapController _googleMapController;
  BitmapDescriptor _markerIcon;
  //ids
  int _polygonIdCounter = 1;
  int _circleIdCounter = 1;
  int _markerIdCounter = 1;

  // Type controllers
  bool _isPolygon = true; //Default
  bool _isMarker = false;
  bool _isCircle = false;

  // This function is to change the marker icon
  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/farm.png');
  }

  // Draw Polygon to the map
  void _setPolygon() {
    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: _polygonLatLngs,
      strokeWidth: 2,
      strokeColor: Colors.yellow,
      fillColor: Colors.yellow.withOpacity(0.15),
    ));
  }

  // Set circles as points to the map
  void _setCircles(LatLng point) {
    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;
    print(
        'Circle | Latitude: ${point.latitude}  Longitude: ${point.longitude}  Radius: $radius');
    _circles.add(Circle(
        circleId: CircleId(circleIdVal),
        center: point,
        radius: radius,
        fillColor: Colors.redAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: Colors.redAccent));
  }

  // Set Markers to the map
  void _setMarkers(LatLng point) {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    setState(() {
      print(
          'Marker | Latitude: ${point.latitude}  Longitude: ${point.longitude}');
      _markers.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
        ),
      );
    });
  }

  // Start the map with this marker setted up
  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('0'),
          position: LatLng(-20.131886, -47.484488),
          infoWindow:
              InfoWindow(title: 'Roça', snippet: 'Um bom lugar para estar'),
          //icon: _markerIcon,
        ),
      );
    });
  }

  Widget _fabPolygon() {
    return FloatingActionButton.extended(
      onPressed: () {
        //Remove the last point setted at the polygon
        setState(() {
          _polygonLatLngs.removeLast();
        });
      },
      icon: Icon(Icons.undo),
      label: Text('Undo point'),
      backgroundColor: Colors.orange,
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: GestureDetector(
  //       onPanUpdate: (_drawPolygonEnabled) ? _onPanUpdate : null,
  //       onPanEnd: (_drawPolygonEnabled) ? _onPanEnd : null,
  //       child: GoogleMap(
  //         mapType: MapType.normal,
  //         initialCameraPosition: _kGooglePlex,
  //         polygons: _polygons,
  //         polylines: _polyLines,
  //         onMapCreated: (GoogleMapController controller) {
  //           _controller.complete(controller);
  //         },
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: _toggleDrawing,
  //       tooltip: 'Drawing',
  //       child: Icon((_drawPolygonEnabled) ? Icons.cancel : Icons.edit),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Set Digital Parameters'),
          centerTitle: true,
        ),
        floatingActionButton:
            _polygonLatLngs.length > 0 && _isPolygon ? _fabPolygon() : null,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.hybrid,
              markers: _markers,
              circles: _circles,
              polygons: _polygons,
              myLocationEnabled: true,
              onTap: (point) {
                if (_isPolygon) {
                  setState(() {
                    _polygonLatLngs.add(point);
                    _setPolygon();
                  });
                } else if (_isMarker) {
                  setState(() {
                    _markers.clear();
                    _setMarkers(point);
                  });
                } else if (_isCircle) {
                  setState(() {
                    _circles.clear();
                    _setCircles(point);
                  });
                }
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: <Widget>[
                  RaisedButton(
                      color: Colors.black54,
                      onPressed: () {
                        _isPolygon = true;
                        _isMarker = false;
                        _isCircle = false;
                      },
                      child: Text(
                        'Polygon',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                  // RaisedButton(
                  //     color: Colors.black54,
                  //     onPressed: () {
                  //       _isPolygon = false;
                  //       _isMarker = true;
                  //       _isCircle = false;
                  //     },
                  //     child: Text('Marker',
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.white))),
                  RaisedButton(
                      color: Colors.black54,
                      onPressed: () {
                        _isPolygon = false;
                        _isMarker = false;
                        _isCircle = true;
                        radius = 50;
                        showDialog(
                            context: context,
                            builder: (context) {
                              child:
                              return AlertDialog(
                                backgroundColor: Colors.grey[900],
                                title: Text(
                                  'Choose the radius (in meters)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                content: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Material(
                                      color: Colors.black,
                                      child: TextField(
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        decoration: InputDecoration(
                                          icon: Icon(Icons.zoom_out_map),
                                          hintText: 'Ex: 100',
                                          suffixText: 'meters',
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        onChanged: (input) {
                                          setState(() {
                                            radius = double.parse(input);
                                          });
                                        },
                                      ),
                                    )),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                ],
                              );
                            });
                      },
                      child: Text('Circle',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)))
                ],
              ),
            )
          ],
        ));
  }

  _toggleDrawing() {
    _clearPolygons();
    setState(() => _drawPolygonEnabled = !_drawPolygonEnabled);
  }

  _onPanUpdate(DragUpdateDetails details) async {
    // To start draw new polygon every time.
    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }

    if (_drawPolygonEnabled) {
      double x, y;
      if (Platform.isAndroid) {
        // It times in 3 without any meaning,
        // We think it's an issue with GoogleMaps package.
        x = details.globalPosition.dx * 3;
        y = details.globalPosition.dy * 3;
      } else if (Platform.isIOS) {
        x = details.globalPosition.dx;
        y = details.globalPosition.dy;
      }

      // Round the x and y.
      int xCoordinate = x.round();
      int yCoordinate = y.round();

      // Check if the distance between last point is not too far.
      // to prevent two fingers drawing.
      if (_lastXCoordinate != null && _lastYCoordinate != null) {
        var distance = Math.sqrt(Math.pow(xCoordinate - _lastXCoordinate, 2) +
            Math.pow(yCoordinate - _lastYCoordinate, 2));
        // Check if the distance of point and point is large.
        if (distance > 80.0) return;
      }

      // Cached the coordinate.
      _lastXCoordinate = xCoordinate;
      _lastYCoordinate = yCoordinate;

      ScreenCoordinate screenCoordinate =
          ScreenCoordinate(x: xCoordinate, y: yCoordinate);

      final GoogleMapController controller = await _controller.future;
      LatLng latLng = await controller.getLatLng(screenCoordinate);

      try {
        // Add new point to list.
        _userPolyLinesLatLngList.add(latLng);

        _polyLines.removeWhere(
            (polyline) => polyline.polylineId.value == 'user_polyline');
        _polyLines.add(
          Polyline(
            polylineId: PolylineId('user_polyline'),
            points: _userPolyLinesLatLngList,
            width: 2,
            color: Colors.blue,
          ),
        );
      } catch (e) {
        print(" error painting $e");
      }
      setState(() {});
    }
  }

  _onPanEnd(DragEndDetails details) async {
    // Reset last cached coordinate
    _lastXCoordinate = null;
    _lastYCoordinate = null;

    if (_drawPolygonEnabled) {
      _polygons
          .removeWhere((polygon) => polygon.polygonId.value == 'user_polygon');
      _polygons.add(
        Polygon(
          polygonId: PolygonId('user_polygon'),
          points: _userPolyLinesLatLngList,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.4),
        ),
      );

      LatLng point = LatLng(37.42713664245048, -122.08062720043169);
      print(AreaChecker.checkIfPointisInArea(point, _userPolyLinesLatLngList));

      setState(() {
        _clearDrawing = true;
      });
    }
  }

  _clearPolygons() {
    setState(() {
      _polyLines.clear();
      _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }
}

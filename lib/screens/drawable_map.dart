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

class MapPage extends StatefulWidget {
  final Livestock livestock;
  MapPage({@required this.livestock});

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
  Future<BitmapDescriptor> _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/cow.png');
    return _markerIcon;
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
  Future<void> _setMarkers() async {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    final BitmapDescriptor markerIcon = await _setMarkerIcon();
    _markerIdCounter++;
    setState(() {
      print(
          'Marker | Latitude: ${widget.livestock.latitude}  Longitude: ${widget.livestock.latitude}');
      _markers.add(
        Marker(
            markerId: MarkerId(markerIdVal),
            position:
                LatLng(widget.livestock.latitude, widget.livestock.longitude),
            icon: markerIcon),
      );
    });
  }

  @override
  void initState() {
    _setMarkers();
    super.initState();
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
      label: Text('Undo Point'),
      backgroundColor: Colors.red,
    );
  }

  Widget _fabPost(BuildContext ctx) {
    return FloatingActionButton.extended(
      onPressed: () {
        print(_isCircle);
        print(_isPolygon);

        ParameterHelper.postParameter(
            ctx,
            Parameter(
                isCircle: _isCircle,
                isPolygon: _isPolygon,
                livestock: widget.livestock,
                circle: _circles.isNotEmpty ? _circles.first : null,
                polygon: _polygons.isNotEmpty ? _polygons.first : null));
      },
      icon: Icon(Icons.undo),
      label: Text('Submit'),
      backgroundColor: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Set Digital Parameters'),
          centerTitle: true,
          actions: [
            if (_circles.isNotEmpty || _polygons.isNotEmpty)
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  print(_isCircle);
                  print(_isPolygon);

                  ParameterHelper.postParameter(
                      context,
                      Parameter(
                          isCircle: _isCircle,
                          isPolygon: _isPolygon,
                          livestock: widget.livestock,
                          circle: _circles.isNotEmpty ? _circles.first : null,
                          polygon:
                              _polygons.isNotEmpty ? _polygons.first : null));
                },
              ),
          ],
        ),
        floatingActionButton:
            _polygonLatLngs.length > 0 && _isPolygon ? _fabPolygon() : null,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    widget.livestock.latitude, widget.livestock.longitude),
                zoom: 16,
              ),
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
                }
                // else if (_isMarker) {
                //   setState(() {
                //     _markers.clear();
                //     _setMarkers(point);
                //   });
                // }
                else if (_isCircle) {
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
}

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
import '../helpers/marker_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../components/livestock_view.dart';

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

  bool show = false;
  Livestock infoLivestock;

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
    _setPolygon();
  }

  void getLivestock() async {
    List<Livestock> livestock = await LivestockHelper.getLivestockData();
    addMarker(livestock);
  }

  // Draw Polygon to the map
  void _setPolygon() {
    for (var param in parameters) {
      if (param.isPolygon) {
        List<LatLng> latLngpoints = [];
        for (var p in param.points) {
          latLngpoints.add(LatLng(p.latitude, p.longitude));
        }
        _polygons.add(Polygon(
          polygonId: param.polygon.polygonId,
          points: latLngpoints,
          strokeWidth: param.polygon.strokeWidth,
          strokeColor: Colors.greenAccent.withOpacity(0.30),
          fillColor: Colors.greenAccent.withOpacity(0.30),
        ));
        print(param.points[0]);
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
            fillColor: Colors.greenAccent.withOpacity(0.5),
            strokeWidth: 3,
            strokeColor: Colors.greenAccent.withOpacity(0.15)));
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
            // icon: await MarkerHelper.setIcon(element.category),
            onTap: () {
              print("yes" + element.tagId);
              setInfoPopup(element);
            }),
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

  setInfoPopup(Livestock livestock) {
    setState(() {
      infoLivestock = livestock;
      show = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: _initialcameraposition, zoom: 15.0),
                  mapType: MapType.hybrid,
                  // onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  markers: Set.from(_markers),
                  circles: _circles,
                  polygons: _polygons,
                ),
              ],
            ),
          ),
          if (show == true) _buildInfoPopup(),
        ],
      ),
    );
  }

  Widget _buildInfoPopup() {
    return Container(
      margin: EdgeInsets.all(5),
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                child: SvgPicture.asset(
                  "assets/svg/${infoLivestock.category}.svg",
                  height: 48,
                  width: 48,
                ),
                padding: EdgeInsets.only(left: 8, top: 10, right: 5),
              ),
              Column(
                children: [
                  Text("${infoLivestock.category} - #${infoLivestock.tagId}"),
                  Text(
                    "${infoLivestock.address}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LivestockView(livestock: infoLivestock)),
                    );
                  },
                  child: Text("More"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
                padding: EdgeInsets.only(right: 10),
              ),
            ],
          )
        ],
      ),
    );
  }
}

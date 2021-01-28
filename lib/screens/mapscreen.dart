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

  @override
  void initState() {
    getLivestock();
    super.initState();
  }

  void getLivestock() async {
    List<Livestock> livestock = await LivestockHelper.getLivestockData();
    addMarker(livestock);
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
              mapType: MapType.normal,
              // onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: Set.from(_markers),
            ),
          ],
        ),
      ),
    );
  }
}

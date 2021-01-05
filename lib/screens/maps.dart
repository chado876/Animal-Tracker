import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place.dart';

class Map extends StatefulWidget {
  final PlaceLocation initialLocation;
  final bool isSelecting;

  Map(
      {this.initialLocation = const PlaceLocation(
          latitude: 18.018139159603447, longitude: -76.74373834686291),
      this.isSelecting = false});

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng _pickedLocation;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.isSelecting)
            IconButton(
                icon: Icon(Icons.check),
                onPressed: _pickedLocation == null
                    ? null
                    : () {
                        Navigator.of(context).pop(_pickedLocation);
                      })
        ],
      ),
      body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.initialLocation.latitude,
              widget.initialLocation.longitude,
            ),
            zoom: 16,
          ),
          onTap: widget.isSelecting ? _selectLocation : null,
          markers: _pickedLocation == null
              ? null
              : {
                  Marker(
                    markerId: MarkerId('m1'),
                    position: _pickedLocation,
                  ),
                }),
    );
  }
}

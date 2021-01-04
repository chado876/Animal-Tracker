import 'package:flutter/material.dart';

class LocationInput extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LocationInput> {
  String _previewImageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          child: _previewImageUrl == null
              ? Text(
                  'No Location Chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(_previewImageUrl,
                  fit: BoxFit.cover, width: double.infinity),
        ),
        Row(
          children: [
            FlatButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Current Location'),
              textColor: Colors.blue,
              onPressed: () {},
            ),
            SizedBox(
              width: 50,
            ),
            FlatButton.icon(
              icon: Icon(Icons.map),
              label: Text('Select on Map'),
              textColor: Colors.blue,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

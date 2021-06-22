import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:animal_tracker/screens/drawable_map.dart';
import 'package:flutter/material.dart';

import '../models/livestock.dart';
import 'package:chips_choice/chips_choice.dart';

class RfidOptionsScreen extends StatefulWidget {
  final Livestock livestock;

  RfidOptionsScreen({@required this.livestock});

  @override
  _RfidOptionsState createState() => _RfidOptionsState();
}

class _RfidOptionsState extends State<RfidOptionsScreen> {
  int tag = 0;
  int type = 0;

  String rfidFrequency;
  String rfidType;

  List<String> options = [
    'Low Frequency (RF)',
    'High Frequency (HF)',
    'Ultra-High Frequency (UHF)'
  ];
  List<String> options2 = [
    'Passive',
    'Active',
  ];

  String photo = 'assets/images/low_frequency.png';

  String description = 'Cheapest and fast enough for most applications. '
      'The electromagnetic properties of this tag allows it to operate through water dense objects, '
      'metal, wood and even animal tissues but can only operate within a few centimetres. '
      'Most popular for animal tracking.';

  String range = 'between 125 KHz and 134.2 KHz';

  void setContent(val) {
    tag = val;
    switch (tag) {
      case 0:
        setState(() {
          rfidFrequency = "LF";
          photo = 'assets/images/low_frequency.png';
          description =
              'Low Frequency (LF) tags are the cheapest and fast enough for most applications. '
              'The electromagnetic properties of this tag allows it to operate through water dense objects, '
              'metal, wood and even animal tissues but can only operate within a few centimetres. '
              'Most popular for animal tracking.';
          range = '1 meter';
        });
        break;
      case 1:
        setState(() {
          rfidFrequency = "HF";
          photo = 'assets/images/high_frequency.png';
          description =
              'High Frequency (HF) tags also have higher transmission rates when compared to LF tags but '
              'are inadvertently more expensive due to its design which may include copper, silver or aluminium.'
              'HF tags have no issues when placed inside or around various materials as with LF tags, '
              'however metals in close vicinity may negatively affect its performance '
              'by reducing/interfering with the magnetic field perpendicular to the object.';
          range = '1.5 meters';
        });
        break;
      case 2:
        setState(() {
          rfidFrequency = "UHF";
          photo = 'assets/images/uhf.png';
          description =
              'Ultra-High Frequency (UHF) tags have the highest range of all tags and are therefore more expensive than the others.'
              'As a major disadvantage, UHF tags are severely affected by fluid and metals, '
              ' can degrade the read range of the tags through energy absorption and de-tuning.';
          range = '3-6 meters for passive tags and 30+ meters for active tags';
        });
        break;
    }
  }

  void setType(type) {
    this.type = type;
    if (type == 0) {
      rfidType = "Passive";
    } else {
      rfidType = "Active";
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select RFID Type'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) => setState(() => setContent(val)),
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
            ChipsChoice<int>.single(
              value: type,
              onChanged: (val) => setState(() => setType(val)),
              choiceItems: C2Choice.listFrom<int, String>(
                source: options2,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                photo,
                width: 250,
                height: 250,
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: RichText(
                text: TextSpan(
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: 'Description: ',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(text: description),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: RichText(
                text: TextSpan(
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: "Maximum Range: ",
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(text: range)
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5.0,
                textColor: Colors.white,
                color: Colors.green,
                child: Text('Continue'),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => MapPage(
                          livestock: widget.livestock,
                          tagFrequency: rfidFrequency,
                          tagType: rfidType),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

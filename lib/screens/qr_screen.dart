import 'package:animal_tracker/components/body.dart';
import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/screens/add_livestock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../helpers/livestock_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';

final CarouselController _controller = CarouselController();

class QrScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return QrState();
  }
}

class QrState extends StatefulWidget {
  const QrState({
    Key key,
  }) : super(key: key);

  @override
  _QrScreenState createState() => _QrScreenState();
}

class _QrScreenState extends State<QrState> {
  String qrCode;
  bool found = false;

  @override
  void initState() {
    scanQrCode();
  }

  Future<void> scanQrCode() async {
    try {
      final code = await FlutterBarcodeScanner.scanBarcode(
          "#000000", "Cancel", true, ScanMode.QR);

      setState(() {
        qrCode = code;
        found = true;
      });
    } on PlatformException {
      found = false;
      qrCode = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: found ? livestockView(qrCode) : Container(),
    );
  }

  Widget livestockView(String tagId) {
    return FutureBuilder(
        future: LivestockHelper.getLivestockDataByTagID(tagId),
        builder: (ctx, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            Center(
              child: CircularProgressIndicator(),
            );
          }

          if (futureSnapshot.hasData) {
            final livestockQuery = futureSnapshot.data;
            final livestock = livestockQuery[0];
            return Column(
              children: <Widget>[
                if (livestock.imageUrls != null)
                  CarouselSlider(
                    items: generateImageList(livestock.imageUrls),
                    options:
                        CarouselOptions(enlargeCenterPage: true, height: 200),
                    carouselController: _controller,
                  ),
                // ListTile(
                //   leading: FaIcon(FontAwesomeIcons.bell, color: Colors.black),
                //   title: Text('Status'),
                //   subtitle: livestock.isMissing
                //       ? Text(
                //           "Missing",
                //           style: TextStyle(
                //             color: Colors.redAccent,
                //           ),
                //         )
                //       : Text(
                //           "Safe",
                //           style: TextStyle(
                //             color: Colors.green,
                //           ),
                //         ),
                // ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.locationArrow,
                      color: Colors.black),
                  title: Text('Current Location'),
                  subtitle: Text(livestock.address),
                ),
                ListTile(
                  leading:
                      FaIcon(FontAwesomeIcons.calendar, color: Colors.black),
                  title: Text('Age'),
                  subtitle: Text(livestock.age),
                ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.weight, color: Colors.black),
                  title: Text('Weight'),
                  subtitle: Text(livestock.weight.toString() + " lbs"),
                ),
                // ListTile(
                //   leading: FaIcon(
                //     FontAwesomeIcons.calendarAlt,
                //     color: Colors.black,
                //   ),
                //   title: Text('Date Added'),
                //   subtitle: livestock.dateAdded != null
                //       ? (Text(livestock.dateAdded.toString()))
                //       : ("1/27/2021"),
                // ),
                RaisedButton(
                  onPressed: () {
                    scanQrCode();
                  },
                  color: Colors.green,
                  child: Text("Scan"),
                ),
                SizedBox(height: 50),
              ],
            );
          } else {
            return Container();
          }
        });
  }

  List<Widget> generateImageList(List<String> urls) {
    return urls
        .map((item) => Container(
              child: Container(
                margin: EdgeInsets.all(5.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(item, fit: BoxFit.cover, width: 1000.0),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            // child: Text(
                            //   'No. ${imgList.indexOf(item)} image',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 20.0,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();
  }
}

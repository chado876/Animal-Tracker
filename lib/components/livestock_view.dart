import 'dart:async';

import 'package:animal_tracker/models/livestock.dart';
import 'package:animal_tracker/models/place.dart';
import 'package:animal_tracker/screens/drawable_map.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';

import '../helpers/livestock_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:barcode_widget/barcode_widget.dart';

final CarouselController _controller = CarouselController();

class LivestockView extends StatelessWidget {
  const LivestockView({Key key, @required this.livestock}) : super(key: key);

  final Livestock livestock;

  @override
  Widget build(BuildContext context) {
    return LivestockViewSection(
      livestockInstance: livestock,
    );
  }
}

class LivestockViewSection extends StatefulWidget {
  final Livestock livestockInstance;

  const LivestockViewSection({Key key, @required this.livestockInstance})
      : super(key: key);

  @override
  _LivestockViewState createState() => _LivestockViewState();
}

class _LivestockViewState extends State<LivestockViewSection>
    with SingleTickerProviderStateMixin {
  Livestock livestock;

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    livestock = widget.livestockInstance;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  refresh() async {
    var data = await LivestockHelper.getLivestockDataByTagID(livestock.tagId);

    setState(() {
      livestock = data[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(livestock.category + " #" + livestock.tagId),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (livestock.imageUrls != null)
              CarouselSlider(
                items: generateImageList(livestock.imageUrls),
                options: CarouselOptions(enlargeCenterPage: true, height: 200),
                carouselController: _controller,
              ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.bell, color: Colors.black),
              title: Text('Status'),
              subtitle: livestock.isMissing
                  ? Text(
                      "Missing",
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    )
                  : Text(
                      "Safe",
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
            ),
            ListTile(
              leading:
                  FaIcon(FontAwesomeIcons.locationArrow, color: Colors.black),
              title: Text('Current Location'),
              subtitle: Text(livestock.address),
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.calendar, color: Colors.black),
              title: Text('Age'),
              subtitle: Text(livestock.age),
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.weight, color: Colors.black),
              title: Text('Weight'),
              subtitle: Text(livestock.weight.toString() + " lbs"),
            ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.calendarAlt,
                color: Colors.black,
              ),
              title: Text('Date Added'),
              subtitle: livestock.dateAdded != null
                  ? (Text(livestock.dateAdded.toString()))
                  : ("1/27/2021"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    color: Colors.black,
                    data: livestock.tagId,
                    width: 150,
                    height: 150),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: Icon(FontAwesomeIcons.share),
                  label: Text("Export"),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      //Init Floating Action Bubble
      floatingActionButton: FloatingActionBubble(
        // Menu items
        items: <Bubble>[
          // Floating action menu item
          Bubble(
            title: "Edit",
            iconColor: Colors.white,
            bubbleColor: Colors.black,
            icon: Icons.edit,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController.reverse();
            },
          ),
          // Floating action menu item
          Bubble(
            title: "Delete",
            iconColor: Colors.white,
            bubbleColor: Colors.red,
            icon: Icons.delete,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              LivestockHelper.deleteLivestock(livestock.tagId, context);
            },
          ),
          Bubble(
            title: livestock.isMissing ? "Mark as found" : "Mark as missing",
            iconColor: Colors.white,
            bubbleColor: livestock.isMissing ? Colors.green : Colors.red,
            icon: livestock.isMissing
                ? Icons.find_in_page_rounded
                : Icons.warning_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              livestock.isMissing
                  ? LivestockHelper.setLivestockAsFound(
                      livestock.tagId, context)
                  : LivestockHelper.postMissingLivestock(livestock, context);
              Navigator.of(context).pop();
            },
          ),
          Bubble(
            title: "Show on map",
            iconColor: Colors.white,
            bubbleColor: Colors.black,
            icon: FontAwesomeIcons.searchLocation,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        showMap(livestock, context),
                  ));
            },
          ),
          Bubble(
            title: "Set Digital Parameters",
            iconColor: Colors.white,
            bubbleColor: Colors.black,
            icon: FontAwesomeIcons.mapMarkedAlt,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MapPage(livestock: livestock),
                ),
              );
            },
          ),
          //Floating action menu item
          Bubble(
            title: "Home",
            iconColor: Colors.white,
            bubbleColor: Colors.black,
            icon: Icons.home,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              // Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => Homepage()));
              Navigator.of(context).pop();
            },
          ),
        ],

        // animation controller
        animation: _animation,

        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),

        // Floating Action button Icon color
        iconColor: Colors.white,
        // Flaoting Action button Icon
        iconData: Icons.more_horiz,
        backGroundColor: Colors.black,
      ),
    );
  }
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

Widget showMap(Livestock livestock, BuildContext context) {
  Marker marker = Marker(
    markerId: MarkerId(livestock.tagId),
    position: LatLng(livestock.latitude, livestock.longitude),
    // icon: BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(size: Size(48, 48)), 'assets/images/cow.png'),
  );

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
            initialCameraPosition: CameraPosition(
                target: LatLng(livestock.latitude, livestock.longitude),
                zoom: 15.0),
            mapType: MapType.normal,
            // onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            markers: {marker},
          ),
        ],
      ),
    ),
  );
}

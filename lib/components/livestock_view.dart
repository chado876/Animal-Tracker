import 'dart:async';

import 'package:animal_tracker/models/livestock.dart';
import 'package:animal_tracker/models/place.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';

import '../helpers/livestock_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  // 'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  // 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

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
            CarouselSlider(
              items: generateImageList(livestock.imageUrls),
              options: CarouselOptions(enlargeCenterPage: true, height: 200),
              carouselController: _controller,
            ),
            ListTile(
              leading: FlutterLogo(size: 56.0),
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
              leading: FlutterLogo(size: 56.0),
              title: Text('Current Location'),
              subtitle: Text(livestock.address),
            ),
            ListTile(
              leading: FlutterLogo(size: 56.0),
              title: Text('Age'),
              subtitle: Text("8 months"),
            ),
            ListTile(
              leading: FlutterLogo(size: 56.0),
              title: Text('Weight'),
              subtitle: Text(livestock.weight.toString() + " lbs"),
            ),
            ListTile(
              leading: FlutterLogo(size: 56.0),
              title: Text('Date Added'),
              subtitle: livestock.dateAdded != null
                  ? (Text(livestock.dateAdded.toString()))
                  : ("1/27/2021"),
            ),
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
            bubbleColor: Colors.blue,
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
            bubbleColor: Colors.blue,
            icon: Icons.delete,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController.reverse();
            },
          ),
          Bubble(
            title: livestock.isMissing ? "Mark as found" : "Mark as missing",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: livestock.isMissing
                ? Icons.find_in_page_outlined
                : Icons.warning_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              livestock.isMissing
                  ? LivestockHelper.setLivestockAsFound(
                      livestock.tagId, context)
                  : LivestockHelper.postMissingLivestock(livestock, context);
            },
          ),
          Bubble(
            title: "Show on map",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.location_on_outlined,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => ShowMap(
                        PlaceLocation(
                            latitude: livestock.latitude,
                            longitude: livestock.longitude),
                        context),
                  ));
            },
          ),
          //Floating action menu item
          Bubble(
            title: "Home",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.home,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              // Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => Homepage()));
              _animationController.reverse();
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
        iconColor: Colors.blue,

        // Flaoting Action button Icon
        iconData: Icons.more_horiz,
        backGroundColor: Colors.white,
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

Widget ShowMap(PlaceLocation initialLocation, BuildContext context) {
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
                target:
                    LatLng(initialLocation.latitude, initialLocation.longitude),
                zoom: 15.0),
            mapType: MapType.normal,
            // onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            // markers: Set.from(_markers),
          ),
        ],
      ),
    ),
  );
}

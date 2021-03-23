import 'package:animal_tracker/components/body.dart';
import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/screens/add_livestock.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './qr_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return HomeCard();
  }
}

class HomeCard extends StatefulWidget {
  const HomeCard({
    Key key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeCard>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  String firstName;

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    // fetchData();
    FirebaseMessaging.instance.subscribeToTopic("MissingLivestock");
    FirebaseMessaging.instance.subscribeToTopic("ParameterNotification");

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  void fetchData() async {
    user = await _auth.currentUser;
    String uid = user.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((user) {
      // print(data.data['image_url']);
      firstName = user.data()['firstName'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      //Init Floating Action Bubble
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 60),
        child: FloatingActionBubble(
          // Menu items
          items: <Bubble>[
            // Floating action menu item
            Bubble(
              title: "Scan QR Code",
              iconColor: Colors.white,
              bubbleColor: Colors.black,
              icon: FontAwesomeIcons.qrcode,
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => QrScreen(),
                  ),
                );
              },
            ),
            //Floating action menu item
            Bubble(
              title: "Add Livestock",
              iconColor: Colors.white,
              bubbleColor: Colors.black,
              icon: FontAwesomeIcons.plus,
              titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => AddLivestock(),
                  ),
                );
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
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
    );
  }
}

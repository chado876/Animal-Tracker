import 'package:animal_tracker/components/body.dart';
import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/screens/add_livestock.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

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

class _HomeScreenState extends State<HomeCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  String firstName;

  @override
  void initState() {
    // fetchData();
    FirebaseMessaging.instance.subscribeToTopic("MissingLivestock");
    FirebaseMessaging.instance.subscribeToTopic("ParameterNotification");

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
      floatingActionButton: Padding(
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => AddLivestock(),
              ),
            );
          },
        ),
        padding: EdgeInsets.only(bottom: 60),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
    );
  }
}

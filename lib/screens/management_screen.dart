import 'package:animal_tracker/screens/add_livestock.dart';
import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/providers/auth.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/drawable_map.dart';

class ManagementScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    // TODO: implement build

    return Settings();
  }
}

class Settings extends StatefulWidget {
  const Settings({
    Key key,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  String firstName;
  String lastName;
  String parish;
  String uid;
  String photoLink;

  int section = 0;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    user = await _auth.currentUser;
    uid = user.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((user) {
      // print(data.data['image_url']);

      setState(() {
        firstName = user.data()['firstName'];
        lastName = user.data()['lastName'];
        parish = user.data()['parish'];
        photoLink = user.data()['image_url'];
      });
    });
    // Firestore.instance.collection('users/$uid').snapshots().listen((data) {
    //   photoLink = data.documents[0]['image_url'];
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        // iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'Management',
          style: kLabelStyle2.copyWith(color: Colors.white),
        ),
      ),
      body: section == 0 ? _optionsPage() : AddLivestock(),
    );
  }

  Widget _optionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          ListTile(
              title: Text("Add Livestock",
                  style: GoogleFonts.sarala().copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              trailing: Icon(
                Icons.add,
                color: Colors.black,
              ),
              onTap: () {
                // setState(() {
                //   section = 1;
                // });
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => AddLivestock(),
                ));
              }),
        ],
      ),
    );
  }
}

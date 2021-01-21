import 'package:animal_tracker/helpers/auth_helper.dart';
import 'package:animal_tracker/models/profile.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MissingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MissingSection();
  }
}

class MissingSection extends StatefulWidget {
  const MissingSection({
    Key key,
  }) : super(key: key);

  @override
  _MissingScreenState createState() => _MissingScreenState();
}

class _MissingScreenState extends State<MissingSection> {
  UserData currentUser = new UserData();
  String uid;

  void fetchUserData() async {
    // final prefs = await SharedPreferences.getInstance();
    // firstName = prefs.getString("firstname") ?? "John";
    currentUser = await AuthHelper.fetchData();
    setState(() {
      uid = currentUser.uid;
    });
    // print(currentUser.uid);
    // print(currentUser.firstName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        // iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          'Missing Livestock',
          style: kLabelStyle2.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        // parent ListView
        children: <Widget>[
          Column(
            children: [
              Container(
                height: 600,
                child: _fetchMissingLivestock(uid),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _fetchMissingLivestock(String uid) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
            stream:
                Firestore.instance.collection('missing_livestock').snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final livestock = snapshot.data.documents;

              if (livestock.length > 0) {
                return ListView.builder(
                  // scrollDirection: Axis.horizontal,
                  itemCount: livestock.length,
                  itemBuilder: (BuildContext context, int index) => Card(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(livestock[index]['category']),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Image.network(
                                livestock[index]['image_urls'][0],
                                height: 300,
                                width: 300),
                          ),
                          Text(livestock[index].documentID),
                          Text(
                            "Last seen: " + livestock[index]['address'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text("Owner: " + livestock[index]['owner_name']),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    "No ",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
            });
      },
    );
  }
}

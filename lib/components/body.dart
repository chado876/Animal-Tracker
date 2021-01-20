import 'dart:async';

import 'package:animal_tracker/components/header.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_data_provider.dart';
import '../models/profile.dart';

import '../helpers/livestock_helper.dart';
import '../models/livestock.dart';
import '../helpers/auth_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BodySection();
  }
}

class BodySection extends StatefulWidget {
  const BodySection({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<BodySection> {
  UserData userData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String uid;
  String firstName;
  List<Livestock> cattle;
  bool isLoading = true;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  Timer _debounce;

  UserData currentUser = new UserData();

  List<String> _categories = [
    "Cattle",
    "Sheep",
    "Pig",
    "Goat",
    "Horse",
    "Donkey",
    "Other",
  ];

  void getLivestock() async {
    List<Livestock> livestock = await LivestockHelper.getLivestockData();
    print(livestock.length);
  }

  void getLivestockByCategory() async {
    cattle = await LivestockHelper.getLivestockDataByCategory("Cattle");
    isLoading = false;
  }

  @override
  void initState() {
    fetchUserData();
    _searchQueryController.addListener(_onSearchChanged);

    super.initState();
  }

  @override
  void dispose() {
    _searchQueryController.removeListener(_onSearchChanged);
    _searchQueryController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void fetchUserData() async {
    // final prefs = await SharedPreferences.getInstance();
    // firstName = prefs.getString("firstname") ?? "John";
    currentUser = await AuthHelper.fetchData();
    setState(() {
      firstName = currentUser.firstName;
      print(currentUser.firstName);
      print(currentUser.uid);

      uid = currentUser.uid;
    });
    // print(currentUser.uid);
    // print(currentUser.firstName);
  }

  void fetchData() async {
    user = await _auth.currentUser();
    uid = user.uid;
    currentUser.uid = uid;
    Firestore.instance
        .collection('users')
        .document(uid)
        .snapshots()
        .listen((user) {
      // print(data.data['image_url']);
      setState(() {
        firstName = user.data['firstName'];
        print("Here!!!!" + firstName);
      });
      // lastName = user.data['lastName'];
      // parish = user.data['parish'];
      // photoLink = user.data['image_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context)
        .size; // provides total height and width of screen

    return ListView(
      // parent ListView
      children: <Widget>[
        _buildHeader(size, firstName),
        for (var category in _categories)
          Column(
            children: [
              Text(category),
              Container(
                height: 350,
                child: _fetchLivestockByCategory(uid, category),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildHeader(@required Size size, String name) {
    // print("HEREEEEE" + name);
    return Column(
      children: <Widget>[
        Container(
          //will cover 20% of screen height
          margin: EdgeInsets.only(bottom: kDefaultPadding * 2.5),
          height: size.height * 0.2,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  left: kDefaultPadding,
                  right: kDefaultPadding,
                  bottom: 36 + kDefaultPadding,
                ),
                height: size.height * 0.2 - 27,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    name != null
                        ? Text(
                            'Hi, $name !',
                            style: kLabelStyle2,
                          )
                        : Text(
                            'Hi!',
                            style: kLabelStyle2,
                          ),
                    Spacer(),
                    Image.asset(
                      "assets/logos/templogo.png",
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 10),
                          blurRadius: 50,
                          color: kPrimaryColor.withOpacity(0.23),
                        )
                      ]),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _searchQueryController,
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: TextStyle(
                              color: kPrimaryColor.withOpacity(0.5),
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            // suffixIcon: SvgPicture.asset("assets/")
                          ),
                          // onChanged: (query) => _onSearchChanged(query),
                          // onTap: _startSearch,
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/icons/search.svg",
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchQueryController.text;
      });
      print(_searchQueryController.text);
    });
  }
}

Widget _fetchLivestockByCategory(String uid, String category) {
  return FutureBuilder(
    future: FirebaseAuth.instance.currentUser(),
    builder: (ctx, futureSnapshot) {
      if (futureSnapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(uid)
              .collection('livestock')
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final livestock = snapshot.data.documents;

            if (livestock.length > 0) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: livestock.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.network(livestock[1]['image_urls'][0],
                              height: 300, width: 300),
                        ),
                        Text(livestock[index].documentID),
                        Row(
                          children: [
                            Text(livestock[index]['address']),
                            Icon(Icons.add_location),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: Text(
                  "No " + category,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          });
    },
  );
}

import 'dart:async';

import 'package:animal_tracker/components/header.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_data_provider.dart';
import '../models/profile.dart';

import '../helpers/livestock_helper.dart';
import '../models/livestock.dart';
import '../helpers/auth_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'livestock_view.dart';

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
  UserObject userData;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  String uid;
  String firstName;
  List<Livestock> cattle;
  bool isLoading = true;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  Timer _debounce;

  bool isPresent;

  List<Livestock> _searchResult;

  UserObject currentUser = new UserObject();

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

    // notif();

    super.initState();
  }

  // Future<void> notif() async {
  //   RemoteMessage initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();

  //     FirebaseMessaging.
  //   print(initialMessage.toString());
  //   if (initialMessage?.data['category'] == 'Cattle') {
  //     print("HEREEEZ!");
  //   } else {
  //     print(initialMessage.toString());
  //   }

  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     if (message.data['category'] == 'Cattle') {
  //       print("HEREEEZ!");
  //     } else {
  //       print(initialMessage.toString());
  //     }
  //   });
  // }

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
    user = _auth.currentUser;
    uid = user.uid;
    currentUser.uid = uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((user) {
      // print(data.data['image_url']);
      setState(() {
        firstName = user.data()['firstName'];
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
        if (_isSearching && _searchQueryController.text.length != 0)
          Container(
            height: 350,
            child: _searchResultView(_searchResult),
          ),
        if (!_isSearching)
          for (var category in _categories)
            // if (LivestockHelper.checkIfCategoryExists(category) == false)
            Column(
              children: [
                Text(category,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Container(
                  height: 350,
                  width: 500,
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

  Future<void> _onSearchChanged() async {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});

    bool searching;

    List<Livestock> searchResult = await search(_searchQueryController.text);

    if (_searchQueryController.text.length == 0) {
      searching = false;
    } else {
      searching = true;
    }

    setState(() {
      _isSearching = searching;
      searchQuery = _searchQueryController.text;
      _searchResult = searchResult;
    });
  }

  Future<List<Livestock>> search(String query) async {
    var result = await LivestockHelper.getLivestockDataByTagID(query);

    return result;
  }
}

Widget _searchResultView(List<Livestock> livestock) {
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
                child: Image.network(livestock[index].imageUrls[0],
                    height: 300, width: 300),
              ),
              Text(livestock[index].tagId),
              Row(
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
                    child: Text("Whee"),
                  ),
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
        "No Results",
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

Widget _fetchLivestockByCategory(String uid, String category) {
  return FutureBuilder(
    future: AuthHelper.getCurrentUser(),
    builder: (ctx, futureSnapshot) {
      if (futureSnapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('livestock')
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final livestock = snapshot.data.docs;
            if (livestock.length > 0) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: livestock.length,
                itemBuilder: (BuildContext context, int index) =>
                    GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LivestockView(
                                livestock: Livestock(
                                  tagId: livestock[index]['tagId'],
                                  address: livestock[index]['address'],
                                  uId: livestock[index]['uId'],
                                  latitude: livestock[index]['latitude'],
                                  longitude: livestock[index]['longitude'],
                                  distinguishingFeatures: livestock[index]
                                      ['distinguishingFeatures'],
                                  weight: livestock[index]['weight'],
                                  imageUrls:
                                      (livestock[index]['image_urls'] as List)
                                          ?.map((item) => item as String)
                                          ?.toList(),
                                  category: livestock[index]['category'],
                                  isMissing: livestock[index]['isMissing'],
                                ),
                              )),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ListTile(
                          //   leading: Icon(Icons.arrow_drop_down_circle),
                          //   title: Text('Card title 1'),
                          //   subtitle: Text(
                          //     'Secondary Text',
                          //     style:
                          //         TextStyle(color: Colors.black.withOpacity(0.6)),
                          //   ),
                          // ),
                          Stack(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: Image.network(
                                    livestock[index]['image_urls'][
                                        0], //this needs to be fixed (null checking)
                                    height: 300,
                                    width: 300),
                              ),
                            ],
                          ),

                          // Row(
                          //   children: [
                          //     livestock[index]['isMissing']
                          //         ? Text(
                          //             "Missing",
                          //             style: TextStyle(
                          //               color: Colors.red,
                          //               fontSize: 20,
                          //             ),
                          //           )
                          //         : Text(
                          //             "Safe",
                          //             style: TextStyle(
                          //               color: Colors.green,
                          //               fontSize: 20,
                          //             ),
                          //           ),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     Text("Tag ID"),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       livestock[index]['tagId'],
                          //       textAlign: TextAlign.left,
                          //     ),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     Text("Current Location"),
                          //   ],
                          // ),
                          // Row(
                          //   children: [
                          //     Container(
                          //       width: 300,
                          //       child: Text(livestock[index]['address']),
                          //     )
                          //   ],
                          // ),
                          // Row(
                          //   // mainAxisAlignment: MainAxisAlignment.start,
                          //   children: [
                          //     SizedBox(width: 25),
                          //     ElevatedButton(
                          //       onPressed: () {},
                          //       child: Row(
                          //         children: [
                          //           Text("Show on Map"),
                          //         ],
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 15,
                          //     ),
                          //     livestock[index]['isMissing']
                          //         ? ElevatedButton(
                          //             onPressed: () {
                          //               LivestockHelper.setLivestockAsFound(
                          //                   livestock[index]['tagId'], context);
                          //             },
                          //             child: Row(
                          //               children: [
                          //                 Text("Mark as Found "),
                          //               ],
                          //             ),
                          //             style: ElevatedButton.styleFrom(
                          //               primary: Colors.green,
                          //               padding: EdgeInsets.only(left: 5),
                          //             ),
                          //           )
                          //         : ElevatedButton(
                          //             onPressed: () {
                          //               LivestockHelper.postMissingLivestock(
                          //                   Livestock(
                          //                       tagId: livestock[index]['tagId'],
                          //                       address: livestock[index]
                          //                           ['address'],
                          //                       uId: livestock[index]['uId'],
                          //                       latitude: livestock[index]
                          //                           ['latitude'],
                          //                       longitude: livestock[index]
                          //                           ['longitude'],
                          //                       distinguishingFeatures: livestock[
                          //                               index]
                          //                           ['distinguishingFeatures'],
                          //                       weight: livestock[index]
                          //                           ['weight'],
                          //                       imageUrls: (livestock[index]
                          //                               ['image_urls'] as List)
                          //                           ?.map(
                          //                               (item) => item as String)
                          //                           ?.toList(),
                          //                       category: livestock[index]
                          //                           ['category']),
                          //                   context);
                          //             },
                          //             child: Row(
                          //               children: [
                          //                 Text("Mark as Missing "),
                          //               ],
                          //             ),
                          //             style: ElevatedButton.styleFrom(
                          //               primary: Colors.redAccent,
                          //               padding: EdgeInsets.only(left: 5),
                          //             ),
                          //           ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(
                child: Stack(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/cow_placeholder.jpg",
                        height: 250,
                        // width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          "No " + category + " available.",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        )),
                  ],
                ),
              );
            }
          });
    },
  );
}

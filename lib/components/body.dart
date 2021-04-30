import 'dart:async';

import 'package:animal_tracker/helpers/auth_helper.dart';
import 'package:animal_tracker/helpers/livestock_helper.dart';
import 'package:animal_tracker/models/livestock.dart';
import 'package:animal_tracker/models/profile.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_select/smart_select.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'livestock_view.dart';

final CarouselController _controller = CarouselController();

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  bool isLoading = true;

  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  Timer _debounce;

  bool isPresent;
  List<Livestock> _searchResult;

  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'Cattle', title: 'Cattle'),
    S2Choice<String>(value: 'Sheep', title: 'Sheep'),
    S2Choice<String>(value: 'Pig', title: 'Pig'),
    S2Choice<String>(value: 'Goat', title: 'Goat'),
    S2Choice<String>(value: 'Horse', title: 'Horse'),
    S2Choice<String>(value: 'Donkey', title: 'Donkey'),
    S2Choice<String>(value: 'Other', title: 'Other'),
  ];

  String value = "Cattle";

  Future<List<Livestock>> getLivestockByCategory(category) async {
    List<Livestock> res =
        await LivestockHelper.getLivestockDataByCategory(category);
    isLoading = false;
    return res;
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

  Future<void> _onSearchChanged() async {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});

    bool searching;
    print(_searchQueryController.text);
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
    print(query);
    var result = await LivestockHelper.getLivestockDataByTagID(query);
    return result;
  }

  Future<UserObject> fetchUserData() async {
    UserObject currentUser = await AuthHelper.fetchData();
    return currentUser;
  }

  Widget _searchResultView(List<Livestock> livestock, BuildContext context) {
    print(livestock.toString());
    if (livestock.length > 0) {
      return _buildCardView(livestock[0], context);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context)
        .size; // provides total height and width of screen
    return Column(
      children: [
        _buildHeader(size, "Chad"),
        SmartSelect<String>.single(
            title: 'Livestock Category',
            value: value,
            choiceItems: options,
            onChange: (state) => setState(() => value = state.value)),
        if (_isSearching && _searchQueryController.text.length != 0)
          Expanded(
            child: _searchResultView(_searchResult, context),
          ),
        if (!_isSearching)
          Expanded(
            child: _fetchLivestock(),
          ),
      ],
    );
  }

  Widget _buildHeader(@required Size size, String name) {
    // print("HEREEEEE" + name);
    return Column(
      children: <Widget>[
        Container(
          //will cover 20% of screen height
          margin: EdgeInsets.only(bottom: kDefaultPadding * 0.5),
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

  Widget _fetchLivestock() {
    return FutureBuilder(
      future: AuthHelper.getCurrentUser(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (futureSnapshot.hasError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text("An error occurred! Please try again later."),
              backgroundColor: Colors.red,
            ),
          );
          return Center(
            child: Container(
              child: Text("An error occurred!"),
            ),
          );
        } else if (futureSnapshot.hasData) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(futureSnapshot.data.uid)
                  .collection('livestock')
                  .where('category', isEqualTo: value)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content:
                            Text("An error occurred! Please try again later."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                  return Center(
                    child: Container(
                      child: Text(
                        "An error occurred!",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final livestock = snapshot.data.docs;
                  if (livestock.length > 0) {
                    return ListView.builder(
                        // scrollDirection: Axis.horizontal,
                        itemCount: livestock.length,
                        itemBuilder: (BuildContext context, int index) =>
                            _buildCardView(
                                Livestock(
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
                                  age: livestock[index]['age'],
                                  isMissing: livestock[index]['isMissing'],
                                  dateAdded:
                                      livestock[index]['dateAdded'].toDate(),
                                  descripton: null,
                                  // descripton: livestock[index]
                                  //     ['description'],
                                ),
                                context));
                  } else {
                    return Container();
                  }
                }
              });
        }
      },
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

Widget _buildCardView(Livestock livestock, BuildContext context) {
  return Card(
    shadowColor: Colors.black,
    elevation: 5,
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.passport,
              color: Colors.black,
            ),
            title: Text("Tag ID"),
            subtitle: Text(livestock.tagId.toString()),
          ),
          CarouselSlider(
            items: generateImageList(
              (livestock.imageUrls as List)
                  ?.map((item) => item as String)
                  ?.toList(),
            ),
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LivestockView(livestock: livestock),
                ),
              );
            },
            child: Container(
              width: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("More"),
                ],
              ),
            ),
          ),
          // if (index == livestock.length - 1)
          //   Container(height: 20),
        ],
      ),
    ),
  );
}

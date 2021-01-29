import 'package:animal_tracker/helpers/auth_helper.dart';
import 'package:animal_tracker/models/profile.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../helpers/livestock_helper.dart';
import '../helpers/tip_helper.dart';
import '../models/tip.dart';

import 'package:badges/badges.dart';

import '../screens/tip_screen.dart';

final CarouselController _controller = CarouselController();

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
  UserObject currentUser = new UserObject();
  String uid;
  List<Tip> tips = [];
  int tipsNum = 0;

  void initState() {
    fetchUserData();
    // setTips();
    getNumberOfTips();

    super.initState();
  }

  void getNumberOfTips() async {
    int numOfTips = await TipHelper.getNumberOfTips(context);

    setState(() {
      tipsNum = numOfTips;
      print(tipsNum);
    });
  }

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

  Future<void> setTips() async {
    tips = await fetchTips();
  }

  Future<List<Tip>> fetchTips() async {
    var tipList = await TipHelper.getAllTips(context);

    return tipList;
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
        actions: <Widget>[
          GestureDetector(
            child: Badge(
              toAnimate: true,
              badgeContent: Text(tipsNum.toString()),
              child: Icon(Icons.inbox_sharp),
              position: BadgePosition.topStart(),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TipScreen()));
            },
          )
        ],
      ),
      // body: SingleChildScrollView(
      //     child: Column(
      //   children: [
      //     SizedBox(height: 10),
      //     Container(
      //       height: 800,
      //       child: _fetchMissingLivestock(uid),
      //     ),
      //     SizedBox(height: 300),
      //   ],
      // )));
      body: ListView(
        // parent ListView
        children: <Widget>[
          Column(
            children: [
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height,
                child: _fetchMissingLivestock(uid),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _fetchMissingLivestock(String uid) {
    TextEditingController tipController = new TextEditingController();

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
                .collection('missing_livestock')
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
                  // scrollDirection: Axis.horizontal,
                  itemCount: livestock.length,
                  itemBuilder: (BuildContext context, int index) => Card(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("Tag ID"),
                            subtitle:
                                Text(livestock[index]['tagId'].toString()),
                          ),
                          CarouselSlider(
                            items: generateImageList(
                              (livestock[index]['image_urls'] as List)
                                  ?.map((item) => item as String)
                                  ?.toList(),
                            ),
                            options: CarouselOptions(
                                enlargeCenterPage: true, height: 200),
                            carouselController: _controller,
                          ),
                          ListTile(
                            title: Text("Last Seen"),
                            subtitle: Text(livestock[index]['address']),
                          ),
                          ListTile(
                            title: Text("Owner"),
                            subtitle: Text(livestock[index]['owner_name']),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Container(
                                        height: 200,
                                        width: 150,
                                        child: Column(
                                          children: [
                                            Text("Send Tip"),
                                            Card(
                                              // color: Colors.white70,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: TextField(
                                                  controller: tipController,
                                                  maxLines: 4,
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                          hintText:
                                                              "Enter your text here"),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  print(tipController.text);
                                                  TipHelper.postTip(
                                                          livestock[index]
                                                              ['uId'],
                                                          livestock[index]
                                                              ['tagId'],
                                                          tipController.text,
                                                          context)
                                                      .then((value) {
                                                    setState(() {
                                                      getNumberOfTips();
                                                    });
                                                  });
                                                },
                                                child: Text("Submit"))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            child: Container(
                              width: 85,
                              child: Row(
                                children: [
                                  Text("Send Tip "),
                                  Icon(Icons.report)
                                ],
                              ),
                            ),
                          ),
                          if (index == 2) Container(height: 180),
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

import 'package:animal_tracker/screens/add_livestock.dart';
import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/providers/auth.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:animal_tracker/widgets/line_chart.dart';
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
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../helpers/statistics_helper.dart';

class AnalyticsScreen extends StatelessWidget {
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

  Map<String, int> livestock = {};

  @override
  void initState() {
    fetchData();
    getStats();
    super.initState();
  }

  Future<void> getStats() async {
    var res = await StatsHelper.categoryChecker();

    setState(() {
      livestock.addAll(res);
    });
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
          'Statistics',
          style: kLabelStyle2.copyWith(color: Colors.white),
        ),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          _buildOptionsTabBar(),
          _lostAndFoundSection(),
          _categorySection(),
          spacer()
        ],
      ),
    );
  }

  Widget spacer() {
    return SliverToBoxAdapter(
      child: SizedBox(height: 100),
    );
  }

  Widget _buildOptionsTabBar() {
    return SliverPadding(
      padding: EdgeInsets.only(top: 5),
      sliver: SliverToBoxAdapter(
        child: DefaultTabController(
          length: 3,
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(25.0)),
            child: TabBar(
              indicator: BubbleTabIndicator(
                tabBarIndicatorSize: TabBarIndicatorSize.tab,
                indicatorHeight: 40.0,
                indicatorColor: Colors.black,
              ),
              unselectedLabelColor: Colors.white,
              tabs: [Text("Personal"), Text("Parish"), Text("Islandwide")],
              onTap: null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categorySection() {
    return SliverPadding(
      padding: EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Text("Categories"),
            Container(
              // height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50)),
              ),
              child: Wrap(
                runSpacing: 20,
                spacing: 20,
                children: [
                  for (var x in livestock.entries)
                    StatsCard(title: x.key, number: x.value, prefix: x.key),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _lostAndFoundSection() {
  return SliverPadding(
    padding: EdgeInsets.only(top: 10),
    sliver: SliverToBoxAdapter(
      child: Column(
        children: [
          Text("Lost & Found"),
          Container(
            // height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50)),
            ),
            child: Wrap(
              runSpacing: 20,
              spacing: 20,
              children: [
                StatsCard(
                  title: "Livestock Stolen",
                  number: 10,
                  prefix: "Animals",
                ),
                StatsCard(
                  title: "Livestock Found",
                  number: 10,
                  prefix: "Animals",
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class StatsCard extends StatelessWidget {
  final String title;
  final int number;
  final String prefix;
  final Color iconColor;

  const StatsCard({
    Key key,
    this.title,
    this.number,
    this.iconColor,
    this.prefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth / 2 - 10,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Color(0xFFFF9C00).withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: SvgPicture.asset(
                    "assets/svg/thief.svg",
                    height: 12,
                    width: 12,
                  ),
                ),
                SizedBox(width: 5),
                Text("$title", maxLines: 1, overflow: TextOverflow.ellipsis)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "$number \n",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      TextSpan(
                        text: "$prefix",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   child: LineReportChart(),
                // ),
              ],
            ),
          ),
        ]),
      );
    });
  }
}

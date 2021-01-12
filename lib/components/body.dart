import 'package:animal_tracker/components/header.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_data_provider.dart';
import '../models/profile.dart';

class Body extends StatelessWidget {
  String firstName;

  Body(this.firstName);
  UserDataProvider dataProvider;

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

  // Title List Here
  var titleList = [
    "Success",
    "Motivation",
    "Hard Work",
    "Decision",
    "Confidence",
    "Business",
    "Team Work"
  ];

  // Description List Here
  var descList = [
    "Push yourself, because no one else is going to do it for you.",
    "Your limitation—it's only your imagination.",
    "Hard Work changes the life.",
    "Sometimes it's the smallest decisions that can change your life forever.",
    "Confidence is the most beautiful thing you can possess",
    "A big business starts small.",
    "Talent wins games, but teamwork and intelligence win championships."
  ];

  @override
  void initState() {
    fetchData();
    // dataProvider.fetchData().then((value) {
    //   userData = value;
    //   print(userData.firstName);
    // });
    super.initState();
  }

  void fetchUserData() async {}

  void fetchData() async {
    user = await _auth.currentUser();
    uid = user.uid;
    Firestore.instance
        .collection('users')
        .document(uid)
        .snapshots()
        .listen((user) {
      // print(data.data['image_url']);
      setState(() {
        firstName = user.data['firstName'];
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

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(size, firstName),
          Text(
            'Cows',
            style: TextStyle(fontSize: 18),
          ),
          Container(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 15,
              itemBuilder: (BuildContext context, int index) => Card(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("tag-1234"),
                      Image.asset('assets/images/cow2.jpg',
                          height: 300, width: 300),
                      Text("May Pen St, May Pen, Clarendon"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Pigs',
            style: TextStyle(fontSize: 18),
          ),
          Container(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 15,
              itemBuilder: (BuildContext context, int index) => Card(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("tag-1234"),
                      Image.asset('assets/images/cow2.jpg',
                          height: 300, width: 300),
                      Text("May Pen St, May Pen, Clarendon"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // SingleChildScrollView(
    //   child: Column(
    //     children: <Widget>[
    //       _buildHeader(size, firstName),
    //       Text(
    //         'Cows',
    //         style: TextStyle(fontSize: 18),
    //       ),
    //       Expanded(
    //         child:
    //ListView.builder(
    //           scrollDirection: Axis.horizontal,
    //           itemCount: 15,
    //           itemBuilder: (BuildContext context, int index) => Container(
    //             height: 330,
    //             child: Card(
    //               child: SingleChildScrollView(
    //                 child: Column(
    //                   children: [
    //                     Text("tag-1234"),
    //                     Image.asset('assets/images/cow2.jpg',
    //                         height: 300, width: 300),
    //                     Text("May Pen St, May Pen, Clarendon"),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Text(
    //         'Pigs',
    //         style: TextStyle(fontSize: 18),
    //       ),
    //       Expanded(
    //         child: ListView.builder(
    //           scrollDirection: Axis.horizontal,
    //           itemCount: 15,
    //           itemBuilder: (BuildContext context, int index) => Container(
    //             height: 330,
    //             child: Card(
    //               child: SingleChildScrollView(
    //                 child: Column(
    //                   children: [
    //                     Text("tag-1234"),
    //                     Image.asset('assets/images/cow2.jpg',
    //                         height: 300, width: 300),
    //                     Text("May Pen St, May Pen, Clarendon"),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    // Text(
    //   'Demo Headline 2',
    //   style: TextStyle(fontSize: 18),
    // ),
    // Expanded(
    //   child: ListView.builder(
    //     shrinkWrap: true,
    //     itemBuilder: (ctx, int) {
    //       return Card(
    //         child: ListTile(
    //             title: Text('Motivation $int'),
    //             subtitle: Text('this is a description of the motivation')),
    //       );
    //     },
    //   ),
    // ),

    // return SingleChildScrollView(
    //   //it enable scrolling on small devices
    //   child: Column(
    //     children: [
    //       _buildHeader(size, firstName),
    //       Card(
    //         child:

    //         Column(
    //           children: [
    // Text("tag-1234"),
    // Image.asset('assets/images/cow2.jpg', height: 300, width: 300),
    // Text("May Pen St, May Pen, Clarendon"),
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}

Widget _buildHeader(@required Size size, String name) {
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
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                            color: kPrimaryColor.withOpacity(0.5),
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          // suffixIcon: SvgPicture.asset("assets/")
                        ),
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

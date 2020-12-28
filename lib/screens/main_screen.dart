import 'package:animal_tracker/components/navbar.dart';
import 'package:flutter/material.dart';

import './home_screen.dart';
import './settings_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();

  int index = 0;
  MainScreen({this.index});
}

class _MainScreenState extends State<MainScreen> {
  final screens = [
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    SettingsScreen(),
    HomeScreen()
  ];

  int currentIndex = 0;
  int indx = 0;

  Function setIndex(int index) {
    currentIndex = index;
  }

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
    indx = widget.index;
  }

  var section = 0;
  var currentPage;
  List<Widget> _options = <Widget>[HomeScreen(), SettingsScreen()];

  void _onItemTap(int index) {
    print(section);
    setState(() {
      section = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(section);
    return Scaffold(
      body: screens.elementAt(section),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.black,
        buttonBackgroundColor: Colors.black,
        height: 60,
        animationDuration: Duration(
          milliseconds: 200,
        ),
        index: section,
        animationCurve: Curves.bounceInOut,
        items: <Widget>[
          Icon(Icons.home,
              size: 30,
              color: section == 0 ? Colors.lightBlueAccent : Colors.white),
          Icon(Icons.verified_user,
              size: 30,
              color: section == 1 ? Colors.lightBlueAccent : Colors.white),
          Icon(Icons.public,
              size: 40,
              color: section == 2 ? Colors.lightBlueAccent : Colors.white),
          Icon(Icons.settings,
              size: 30,
              color: section == 3 ? Colors.lightBlueAccent : Colors.white),
          Icon(Icons.more_horiz,
              size: 30,
              color: section == 4 ? Colors.lightBlueAccent : Colors.white),
        ],
        onTap: (index) {
          _onItemTap(index);
        },
      ),
    );
  }
}

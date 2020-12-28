import 'package:animal_tracker/components/body.dart';
import 'package:animal_tracker/screens/home_screen.dart';
import 'package:animal_tracker/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../screens/main_screen.dart';
import 'package:provider/provider.dart';

class Navbar extends StatelessWidget {
  Widget build(BuildContext context) {
    // TODO: implement build
    return NavbarWidget();
  }
}

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({
    Key key,
  }) : super(key: key);

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<NavbarWidget> {
  var section = 0;
  var currentPage;
  List<Widget> _options = <Widget>[HomeScreen(), SettingsScreen()];

  void _onItemTap(int index) {
    setState(() {
      section = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
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
        _onItemTap;
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => MainScreen(
        //         index: index,
        //       ),
        //     ),
        //   );
        // onTap: (index) {_selectTab(pageKeys[index], index);}
        // builder: (context) => Nav()
        // if (_section == 3) {
        //   Navigator.pushNamed(context, '/settings');
        // }
        // if (_section == 0) {
        //   Navigator.pushNamed(context, '/home');
        // }
        //Handle button tap
      },
    );
  }
}

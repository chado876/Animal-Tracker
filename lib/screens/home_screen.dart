import 'package:animal_tracker/components/body.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return HomeCard();
  }
}

class HomeCard extends StatefulWidget {
  const HomeCard({
    Key key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeCard> {
  var _section = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(),
      bottomNavigationBar: buildNavBar(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/menu.svg'),
          onPressed: null,
        ));
  }

  CurvedNavigationBar buildNavBar() {
    return CurvedNavigationBar(
      backgroundColor: Colors.white,
      color: Colors.black,
      buttonBackgroundColor: Colors.black,
      height: 60,
      animationDuration: Duration(
        milliseconds: 200,
      ),
      index: 0,
      animationCurve: Curves.bounceInOut,
      items: <Widget>[
        Icon(Icons.home,
            size: 30,
            color: _section == 0 ? Colors.lightBlueAccent : Colors.white),
        Icon(Icons.verified_user,
            size: 30,
            color: _section == 1 ? Colors.lightBlueAccent : Colors.white),
        Icon(Icons.public,
            size: 40,
            color: _section == 2 ? Colors.lightBlueAccent : Colors.white),
        Icon(Icons.settings,
            size: 30,
            color: _section == 3 ? Colors.lightBlueAccent : Colors.white),
        Icon(Icons.more_horiz,
            size: 30,
            color: _section == 4 ? Colors.lightBlueAccent : Colors.white),
      ],
      onTap: (index) {
        setState(() {
          _section = index;
        });
        //Handle button tap
      },
    );
  }
}

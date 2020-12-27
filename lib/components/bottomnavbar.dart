import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // return Positioned(
    //     bottom: 0,
    //     left: 0,
    //     child: Container(
    //         width: size.width,
    //         height: 80,
    //         color: Colors.black,
    //         child: Stack(children: [])));
    return BottomNavigationBar();
  }
}

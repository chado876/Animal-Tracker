import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          color: Colors.grey,
          child: SvgPicture.asset("assets/images/jamaica.svg",
              semanticsLabel: 'Jamaica'),
        ));
  }
}

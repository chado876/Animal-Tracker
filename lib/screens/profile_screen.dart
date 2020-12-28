import 'package:animal_tracker/screens/additional_info_screen.dart';
import 'package:animal_tracker/utilities/background_painter.dart';
import 'package:animal_tracker/widgets/fadein.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animal_tracker/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../utilities/constants.dart';
import '../models/http_exception.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';

enum Section { Section1, Section2 }

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ProfileCard());
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    Key key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Section section = Section.Section1;
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _switchPage() {
    if (section == Section.Section1) {
      setState(() {
        section = Section.Section2;
        print("Auth mode switched TO SIGNUP");
      });
    } else {
      setState(() {
        print("Auth mode switched TO LOGIN");
        section = Section.Section1;
      });
    }
  }

  Widget _buildBackground() {
    return SizedBox.expand(
      child: CustomPaint(
        painter: BackgroundPainter(
          animation: _controller,
        ),
      ),
    );
  }

  Widget _buildCowImage() {
    return FadeIn(
      4,
      Align(
        alignment: Alignment.topRight,
        child: Image.asset(
          'assets/images/cow.png',
          width: 300,
          height: 300,
          alignment: Alignment.topRight,
        ),
      ),
    );
  }

  Widget _buildInfoSection1() {
    return Column(
      children: [
        Container(
          child: Text(
            "What\'s your full name?",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        SizedBox(height: 30.0),
        TextFormField(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14.0),
            prefixIcon: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            labelText: 'First Name',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
        ),
        TextFormField(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            labelText: 'Last Name',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection2() {
    return Column(
      children: [
        Container(
          child: Text(
            "What\'s your full name 2?",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
        SizedBox(height: 30.0),
        TextFormField(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14.0),
            prefixIcon: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            labelText: 'First Name',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
        ),
        TextFormField(
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.edit,
              color: Colors.blue,
            ),
            labelText: 'Last Name',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: FadeIn(
        3,
        Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Tell Us \n A Little More \n About Yourself...",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 34,
                ),
                // textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 40.0),
            if (section == Section.Section1) _buildInfoSection1(),
            if (section == Section.Section2) _buildInfoSection2(),
            RaisedButton(
              elevation: 5,
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                "Next",
                style: kHintTextStyle.copyWith(fontSize: 18),
              ),

              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text("Next", style: kHintTextStyle),
              //   ],
              // ),
              onPressed: () {
                _switchPage();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [_buildBackground(), _buildCowImage(), _buildBody()],
    );
  }
}

import 'package:animal_tracker/utilities/background_painter.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:animal_tracker/widgets/fadein.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';

enum Section { Section1, Section2 }
int sec = 0;

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({
    Key key,
  }) : super(key: key);

  @override
  _AdditionalInfoScreenState createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Section currentSection = Section.Section1;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: BackgroundPainter(
                animation: _controller,
              ),
            ),
          ),
          FadeIn(
            4,
            Align(
              // top: 0.0,
              // right: 0.0,
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/images/cow.png',
                width: 300,
                height: 300,
                alignment: Alignment.topRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: FadeIn(
              3,
              Column(
                children: [
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
                  if (sec == 0) InfoSection1(),
                  if (sec == 1) InfoSection2(),
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
                      // _switchPage();
                      sec++;
                      print(sec);
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchPage() {
    if (currentSection == Section.Section1) {
      setState(() {
        currentSection = Section.Section2;
        print("Auth mode switched TO SIGNUP");
      });
    } else {
      setState(() {
        print("Auth mode switched TO LOGIN");
        currentSection = Section.Section1;
      });
    }
  }
}

class InfoSection1 extends StatelessWidget {
  const InfoSection1({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class InfoSection2 extends StatelessWidget {
  const InfoSection2({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
    ]);
  }
}

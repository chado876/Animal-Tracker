import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.pushReplacementNamed(context, '/main');
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Manage your livestock",
          body:
              "Add livestock to your inventory and set their digital bounds to keep them safe!",
          image: _buildImage('cowhead.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Track your livestock",
          body:
              "View your livestock's live location and receIve live notifications when they leave their bounds.",
          image: _buildImage('cowhead.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Get live updates",
          body:
              "Not only do you get live push notifications when trouble is near for your livestock, there is also " +
                  "the option to receive them from other rearers near you!",
          image: _buildImage('cowhead.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Livestock details one scan away",
          body:
              "Using Quick Response (QR) Code technology, tag your livestock and scan them to " +
                  "see their details within seconds!",
          image: _buildImage('cowhead.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Be your brother's keeper!",
          body:
              "View missing livestock around the country and send anonymous tips if you have information. Remember," +
                  "we're all  in this fight against praedial larceny together!",
          image: _buildImage('cowhead.png'),
          footer: RaisedButton(
            onPressed: () {
              introKey.currentState?.animateScroll(0);
            },
            child: const Text(
              'FooButton',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}

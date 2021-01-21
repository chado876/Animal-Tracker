import 'package:flutter/material.dart';

class MissingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MissingSection();
  }
}

class MissingSection extends StatefulWidget {
  const MissingSection({
    Key key,
  }) : super(key: key);

  @override
  _MissingScreenState createState() => _MissingScreenState();
}

class _MissingScreenState extends State<MissingSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Text("Missing Livestock"),
          ],
        ));
  }
}

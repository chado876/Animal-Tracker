import 'package:animal_tracker/components/navbar.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    // TODO: implement build
    return Settings();
  }
}

class Settings extends StatefulWidget {
  const Settings({
    Key key,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
    );
  }
}

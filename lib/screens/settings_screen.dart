import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/providers/auth.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          brightness: Brightness.light,
          // iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: Text(
            'Settings',
            style: kLabelStyle2.copyWith(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30.0),
              Row(
                children: <Widget>[
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/8/80/Farmer%2C_Nicaragua.jpg'),
                        fit: BoxFit.cover,
                      ),
                      // border: Border.all(color: Colors.lightBlueAccent),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "John Doe",
                          style: GoogleFonts.ubuntu().copyWith(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "Jamaica ${Emojis.flagJamaica}",
                              style: GoogleFonts.abel().copyWith(),
                            ),
                            // Flag(
                            //   'JM',
                            //   height: 10,
                            //   width: 10,
                            //   fit: BoxFit.fill,
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ListTile(
                title: Text("Log Out",
                    style: GoogleFonts.sarala().copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                trailing: Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
                onTap: () {
                  Provider.of<Auth>(context, listen: false).logout();
                  Navigator.pushNamed(context, '/login');
                },
              )
            ],
          ),
        ));
  }
}

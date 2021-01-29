import 'package:animal_tracker/components/navbar.dart';
import 'package:animal_tracker/helpers/tip_helper.dart';
import 'package:animal_tracker/models/profile.dart';
import 'package:animal_tracker/models/tip.dart';
import 'package:animal_tracker/providers/auth.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emojis/emojis.dart';
import 'package:emojis/emoji.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class TipScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    // TODO: implement build

    return TipScreenState();
  }
}

class TipScreenState extends StatefulWidget {
  const TipScreenState({
    Key key,
  }) : super(key: key);

  @override
  _TipScreenBuilder createState() => _TipScreenBuilder();
}

class _TipScreenBuilder extends State<TipScreenState> {
  List<Tip> tips;
  final f = new DateFormat('yyyy-MM-dd hh:mm');

  @override
  void initState() {
    getAllTips();
    super.initState();
  }

  Future<void> getAllTips() async {
    tips = await TipHelper.getAllTips(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tips"),
      ),
      body: _fetchTips(),
    );
  }

  Widget _fetchTips() {
    TextEditingController tipController = new TextEditingController();

    return FutureBuilder(
        future: TipHelper.getAllTips(context),
        builder: (ctx, futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (futureSnapshot.hasData) {
            final List<Tip> tips = futureSnapshot.data;
            if (tips.length > 0) {
              return ListView.builder(
                  itemCount: tips.length,
                  itemBuilder: (BuildContext context, int index) => Dismissible(
                      // Each Dismissible must contain a Key. Keys allow Flutter to
                      // uniquely identify widgets.
                      key: Key(tips[index].tagId),
                      // Provide a function that tells the app
                      // what to do after an item has been swiped away.
                      onDismissed: (direction) {
                        // Remove the item from the data source.
                        TipHelper.deleteTip(ctx, tips[index].id).then((value) {
                          if (value == true) {
                            setState(() {
                              tips.removeAt(index);
                            });
                          }
                        });

                        // Then show a snackbar.
                      },
                      // Show a red background as the item is swiped away.
                      background: Container(color: Colors.red),
                      child: ListTile(
                        leading: Icon(
                          Icons.info_sharp,
                          color: Colors.blue,
                        ),
                        title: Text(
                            '(${tips[index].tagId}) ' + tips[index].tipMessage),
                        subtitle: Text(timeago.format(tips[index].dateSent)),
                      ))
                  // Card(
                  //   child:
                  //     SingleChildScrollView(
                  //   child: Column(
                  //     children: <Widget>[
                  //       ListTile(
                  //         leading: Icon(
                  //           Icons.info_sharp,
                  //           color: Colors.blue,
                  //         ),
                  //         title: Text(
                  //             '(${tips[index].tagId}) ' + tips[index].tipMessage),
                  //         subtitle: Text(tips[index].dateSent.toString()),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // ),
                  );
            } else {
              return Container(
                alignment: Alignment.center,
                child: Text(
                  "No ",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
          } else {
            return Container(
              alignment: Alignment.center,
              child: Text(
                "No ",
                style: TextStyle(color: Colors.red),
              ),
            );
          }
        });
  }
}

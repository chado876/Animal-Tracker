import 'package:flutter/material.dart';

class AddLivestock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddLivestockSection();
  }
}

class AddLivestockSection extends StatefulWidget {
  const AddLivestockSection({
    Key key,
  }) : super(key: key);

  @override
  _AddLivestockState createState() => _AddLivestockState();
}

class _AddLivestockState extends State<AddLivestockSection> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      Container(
        height: 350,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          itemCount: 10,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) => Image.asset(
            "assets/images/cow2.jpg",
            height: 350,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ]);
  }
}

import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:smart_select/smart_select.dart';

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
  List<Asset> images = List<Asset>.empty();
  String _error = 'No Error Dectected';

  List<String> _categories = [
    "Cattle",
    "Sheep",
    "Pig",
    "Goat",
    "Horse",
    "Donkey",
    "Other",
  ];

  String value = 'Cattle';
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'Cattle', title: 'Cattle'),
    S2Choice<String>(value: 'Sheep', title: 'Sheep'),
    S2Choice<String>(value: 'Pig', title: 'Pig'),
  ];

  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   return Column(children: [
  //     Container(
  //       height: 350,
  //       width: MediaQuery.of(context).size.width,
  //       child: ListView.builder(
  //         itemCount: 10,
  //         scrollDirection: Axis.horizontal,
  //         itemBuilder: (ctx, index) => Image.asset(
  //           "assets/images/cow2.jpg",
  //           height: 350,
  //           width: MediaQuery.of(context).size.width,
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //     ),
  //   ]);
  // }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Widget buildListView() {
    return Column(children: [
      Container(
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: images.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, index) {
              Asset asset = images[index];
              return AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              );
            }),
      ),
    ]);
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>.empty();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 3,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Upload Livestock Photos",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text("Add Livestock",
            style: kLabelStyle2.copyWith(color: Colors.black)),
        Center(
          child: Text('Error: $_error'),
        ),
        Container(
          width: 50,
          child: RaisedButton(
            child: Text("Upload images"),
            elevation: 5,
            onPressed: loadAssets,
            color: Colors.grey,
          ),
        ),
        buildGridView(),
        SmartSelect<String>.single(
            title: 'Livestock Category',
            value: value,
            choiceItems: options,
            onChange: (state) => setState(() => value = state.value)),
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
              Icons.tag,
              color: Colors.blue,
            ),
            labelText: 'Tag ID',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
          onSaved: (value) {
            // _firstName = value;
            // print(value);
          },
        ),
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
              Icons.tag,
              color: Colors.blue,
            ),
            labelText: 'Weight (optional)',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
          onSaved: (value) {
            // _firstName = value;
            // print(value);
          },
        ),
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
              Icons.tag,
              color: Colors.blue,
            ),
            labelText: 'Distinguishing Features (optional)',
            labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
          ),
          onSaved: (value) {
            // _firstName = value;
            // print(value);
          },
        ),
        RaisedButton(
          elevation: 5,
          color: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "Add",
            style: kHintTextStyle.copyWith(fontSize: 18),
          ),
          onPressed: () {
            // Section nextSection = Section.Section2;
            // _formKey2.currentState.save();

            // _switchPage(nextSection);
          },
        )
      ],
    );
  }

  List<int> generateNumbers() => List<int>.generate(30, (i) => i + 1);
}

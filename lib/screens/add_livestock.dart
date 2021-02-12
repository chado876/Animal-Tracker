import 'dart:io';

import 'package:animal_tracker/models/livestock.dart';
import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:smart_select/smart_select.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utilities/assetConverter.dart';
import '../utilities/constants.dart';
import '../widgets/location_input.dart';

import '../models/place.dart';

import '../helpers/location_helper.dart';
import 'drawable_map.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey();

  String _tagId;
  double _weight;
  String _features;
  List<String> _imageUrls = [];
  PlaceLocation locationData;

  String _error = 'No Error Dectected';
  bool _isLoading;
  bool postSuccess = false;

  bool imagesLoaded = false;
  bool addImages = false;
  bool imgError = false;

  PlaceLocation _pickedLocation;

  Livestock livestock;

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
    S2Choice<String>(value: 'Goat', title: 'Goat'),
    S2Choice<String>(value: 'Horse', title: 'Horse'),
    S2Choice<String>(value: 'Donkey', title: 'Donkey'),
    S2Choice<String>(value: 'Other', title: 'Other'),
  ];

  TextEditingController tagIdController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController featuresController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Future<void> _trySubmit() async {
    try {
      setState(() {
        _isLoading = true;
      });

      PlaceLocation pickedLocation = _pickedLocation;

      // _formKey.currentState.save(); no longer using forms
      final _auth = FirebaseAuth.instance;
      User user = _auth.currentUser;

      int x = 0;

      for (var image in images) {
        String fileName = tagIdController.text + x.toString();
        await postImage(
                imageFile: image,
                fileName: fileName,
                tagId: tagIdController.text,
                userId: user.uid)
            .then((url) {
          _imageUrls.add(url.toString());
        });
        x++;
      }

      final address = await LocationHelper.getPlacedAddress(
          pickedLocation.latitude, pickedLocation.longitude);

      locationData = PlaceLocation(
          latitude: pickedLocation.latitude,
          longitude: pickedLocation.longitude,
          address: address);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('livestock')
          .doc(tagIdController.text)
          .set({
        'uId': user.uid,
        'tagId': tagIdController.text,
        'category': value,
        'age': ageController.text,
        'weight': double.parse(weightController.text),
        'distinguishingFeatures': featuresController.text,
        'image_urls': _imageUrls,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'address': locationData.address,
        'isMissing': false,
        'dateAdded': generateCurrentDate(),
      });
      livestock = Livestock(
        uId: user.uid,
        tagId: tagIdController.text,
        category: value,
        age: ageController.text,
        weight: double.parse(weightController.text),
        distinguishingFeatures: featuresController.text,
        imageUrls: _imageUrls,
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address,
        isMissing: false,
      );

      postSuccess = true;
    } on PlatformException catch (err) {
      postSuccess = false;
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<dynamic> postImage(
      {Asset imageFile, String fileName, String tagId, String userId}) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('livestock/' + userId + '/' + tagIdController.text)
        .child(fileName + '.jpg');
    UploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  void _selectPlace(double lat, double lng) {
    _pickedLocation = PlaceLocation(latitude: lat, longitude: lng);
  }

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
    addImages = true;
    imgError = false;
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
      imagesLoaded = true;
    } on Exception catch (e) {
      imgError = true;
      imagesLoaded = false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Livestock"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Align(
                child: Text(
                  "Fill out the information below.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                alignment: Alignment.center,
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: tagIdController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tag ID',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Weight (Optional)',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Age (Optional)',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: featuresController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Distinguishing Features (Optional)',
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SmartSelect<String>.single(
                  title: 'Livestock Category',
                  value: value,
                  choiceItems: options,
                  onChange: (state) => setState(() => value = state.value)),
              if (imgError)
                Center(
                  child: Text('Error: $_error'),
                ),
              addImages
                  ? buildGridView()
                  : Text(
                      "No Image Selected",
                      style: TextStyle(color: Colors.redAccent),
                    ),
              Container(
                width: 200,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  color: Colors.blue,
                  child: Text(
                    "Upload images",
                    style: kLabelStyle.copyWith(color: Colors.white),
                  ),
                  elevation: 5,
                  onPressed: loadAssets,
                ),
              ),
              LocationInput(_selectPlace),
              Container(
                  height: 50,
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: RaisedButton(
                    elevation: 5.0,
                    textColor: Colors.white,
                    color: Colors.lightGreen,
                    child: Text('Add Livestock'),
                    onPressed: () {
                      _trySubmit().then((value) {
                        SnackBar snackBar = SnackBar(
                          backgroundColor: postSuccess
                              ? Colors.lightGreen
                              : Colors.redAccent,
                          content: Text(postSuccess
                              ? "Livestock added successfully"
                              : "An error occurred. Please try again."),
                          action: SnackBarAction(
                            label: 'Ok',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }).then((value) => postSuccess
                          ? Navigator.push(
                              context,
                              new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    MapPage(livestock: livestock),
                              ),
                            )
                          : null);
                    },
                  )),
              SizedBox(height: 10),
              Container(
                  height: 50,
                  width: 300,
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: RaisedButton(
                    elevation: 5.0,
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<int> generateNumbers() => List<int>.generate(30, (i) => i + 1);

  DateTime generateCurrentDate() {
    DateTime now = new DateTime.now();
    return now;
  }
}

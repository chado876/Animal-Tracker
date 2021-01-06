import 'dart:io';

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

  bool imagesLoaded = false;
  bool addImages = false;
  bool imgError = false;

  PlaceLocation _pickedLocation;

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

  Future<void> _trySubmit() async {
    try {
      setState(() {
        _isLoading = true;
      });

      PlaceLocation pickedLocation = _pickedLocation;

      _formKey.currentState.save();
      final _auth = FirebaseAuth.instance;
      FirebaseUser user = await _auth.currentUser();

      int x = 0;

      images.forEach((image) {
        String fileName = _tagId.toString() + x.toString();
        postImage(
                imageFile: image,
                fileName: fileName,
                tagId: _tagId,
                userId: user.uid)
            .then((url) {
          _imageUrls.add(url.toString());
          print(url.toString());
        });

        x++;
      });

      final address = await LocationHelper.getPlacedAddress(
          pickedLocation.latitude, pickedLocation.longitude);

      print("Address here" + address);
      print(pickedLocation.latitude);
      print(pickedLocation.longitude);

      locationData = PlaceLocation(
          latitude: pickedLocation.latitude,
          longitude: pickedLocation.longitude,
          address: address);

      print(locationData.latitude);
      print(locationData.longitude);
      print(locationData.address);
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('livestock')
          .document(_tagId)
          .setData({
        'uId': user.uid,
        'tagId': _tagId,
        'category': value,
        'weight': _weight,
        'distinguishingFeatures': _features,
        'image_urls': _imageUrls,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'address': locationData.address,
      });
    } on PlatformException catch (err) {
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
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child('livestock/' + userId + '/' + _tagId)
        .child(fileName + '.jpg');
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
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
              SmartSelect<String>.single(
                  title: 'Livestock Category',
                  value: value,
                  choiceItems: options,
                  onChange: (state) => setState(() => value = state.value)),
              TextFormField(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0, left: 10.0),
                  labelText: 'Tag ID',
                  labelStyle: kHintTextStyle.copyWith(color: Colors.grey),
                ),
                onSaved: (value) {
                  _tagId = value;
                },
              ),
              TextFormField(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0, left: 10.0),
                  labelText: 'Weight (optional)',
                  labelStyle: kHintTextStyle.copyWith(color: Colors.grey),
                ),
                onSaved: (value) {
                  _weight = double.parse(value);
                },
              ),
              TextFormField(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0, left: 10.0),
                  labelText: 'Distinguishing Features (optional)',
                  labelStyle: kHintTextStyle.copyWith(color: Colors.grey),
                ),
                onSaved: (value) {
                  _features = value;
                },
              ),
              TextFormField(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0, left: 10.0),
                  labelText: 'RFID #',
                  labelStyle: kHintTextStyle.copyWith(color: Colors.grey),
                ),
                onSaved: (value) {
                  _features = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              LocationInput(_selectPlace),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      _trySubmit();
                    },
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                    elevation: 5,
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      "Cancel",
                      style: kHintTextStyle.copyWith(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/manage');
                    },
                  ),
                ],
              ),
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
}

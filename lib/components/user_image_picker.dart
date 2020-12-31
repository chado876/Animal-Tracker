import 'dart:io';

import 'package:animal_tracker/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
    );
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 90,
            backgroundImage: _pickedImage != null
                ? FileImage(_pickedImage)
                : AssetImage("assets/images/profile.png"),
          ),
        ),
        SizedBox(height: 30.0),
        RaisedButton(
          elevation: 5,
          color: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "Upload Profile Picture",
            style: kHintTextStyle.copyWith(fontSize: 18),
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}

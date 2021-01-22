import 'package:animal_tracker/components/user_image_picker.dart';
import 'package:animal_tracker/models/parish.dart';
import 'package:animal_tracker/screens/additional_info_screen.dart';
import 'package:animal_tracker/utilities/background_painter.dart';
import 'package:animal_tracker/utilities/image_uploader.dart';
import 'package:animal_tracker/widgets/fadein.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:animal_tracker/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../utilities/constants.dart';
import '../models/http_exception.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Section { Section1, Section2, Section3 }

class ProfileScreen extends StatelessWidget {
  String userEmail;
  String userPassword;

  ProfileScreen({this.userEmail, this.userPassword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileCard(
        userEmail: this.userEmail,
        userPassword: this.userPassword,
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  final String userEmail;
  final String userPassword;
  const ProfileCard({
    Key key,
    this.userEmail,
    this.userPassword,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey2 = GlobalKey();

  Section section = Section.Section1;
  AnimationController _controller;
  List<Parish> _parishes = Parish.getParishes();
  List<DropdownMenuItem<Parish>> _dropdownItems;
  Parish _selectedParish;
  String imageUrl;

  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _firstName;
  var _lastName;
  File _userImageFile;
  var _isLoading = false;

  void Function(
    String email,
    String password,
    String firstName,
    String lastName,
    String parish,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  void _trySubmit() async {
    try {
      setState(() {
        _isLoading = true;
      });
      _userEmail = widget.userEmail;
      _userPassword = widget.userPassword;
      final _auth = FirebaseAuth.instance;

      var result = await _auth.createUserWithEmailAndPassword(
        email: _userEmail,
        password: _userPassword,
      );
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(result.user.uid + '.jpg');
      await ref.putFile(_userImageFile);
      final url = await ref.getDownloadURL();

      print(ref.getDownloadURL());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user.uid)
          .set({
        'firstName': _firstName,
        'lastName': _lastName,
        'parish': _selectedParish.name,
        'email': _userEmail,
        'image_url': url,
      });

      await _auth.signInWithEmailAndPassword(
        email: _userEmail,
        password: _userPassword,
      );

      Navigator.pushNamed(context, '/main');
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

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.forward();
    _dropdownItems = _buildDropDownMenuItems(_parishes);
    _selectedParish = _dropdownItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<Parish>> _buildDropDownMenuItems(List parishes) {
    List<DropdownMenuItem<Parish>> items = [];
    for (Parish parish in parishes) {
      items.add(
        DropdownMenuItem(
          value: parish,
          child: Text(parish.name),
        ),
      );
    }
    return items;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _switchPage(Section s) {
    setState(() {
      section = s;
    });
  }

  onChangeDropDownItem(Parish selectedParish) {
    setState(() {
      _selectedParish = selectedParish;
    });
  }

  Widget _buildParishDropList() {
    return FadeIn(
      3,
      Container(
        child: Column(
          children: [
            Text(
              "Select a parish",
              style: kLabelStyle.copyWith(color: Colors.white, fontSize: 28),
            ),
            DropdownButton(
              value: _selectedParish,
              items: _dropdownItems,
              onChanged: onChangeDropDownItem,
              dropdownColor: Colors.white,
              style: kLabelStyle.copyWith(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'Selected: ${_selectedParish.name}',
              style: kLabelStyle.copyWith(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox.expand(
      child: CustomPaint(
        painter: BackgroundPainter(
          animation: _controller,
        ),
      ),
    );
  }

  Widget _buildCowImage() {
    return FadeIn(
      4,
      Align(
        alignment: Alignment.topRight,
        child: Image.asset(
          'assets/images/cow.png',
          width: 300,
          height: 300,
          alignment: Alignment.topRight,
        ),
      ),
    );
  }

  Widget _buildInfoSection1() {
    return Form(
      key: _formKey2,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Tell Us \n A Little More \n About Yourself...",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 34,
              ),
              // textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            child: Text(
              "What\'s your full name?",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
          ),
          SizedBox(height: 30.0),
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
                Icons.edit,
                color: Colors.blue,
              ),
              labelText: 'First Name',
              labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
            ),
            onSaved: (value) {
              _firstName = value;
              print(value);
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
              prefixIcon: Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              labelText: 'Last Name',
              labelStyle: kHintTextStyle.copyWith(color: Colors.blue),
            ),
            onSaved: (value) {
              _lastName = value;
              print(value);
            },
          ),
          RaisedButton(
            elevation: 5,
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              "Next",
              style: kHintTextStyle.copyWith(fontSize: 18),
            ),
            onPressed: () {
              Section nextSection = Section.Section2;
              _formKey2.currentState.save();

              _switchPage(nextSection);
            },
          )
        ],
      ),
    );
  }

  Widget _buildInfoSection3() {
    return Column(
      children: [
        SizedBox(height: 15.0),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Almost there...",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 34,
            ),
            // textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 40.0),
        UserImagePicker(_pickedImage),
        RaisedButton(
          elevation: 5,
          color: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Text(
            "Finish",
            style: kHintTextStyle.copyWith(fontSize: 18),
          ),
          onPressed: _trySubmit,
        )
      ],
    );
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  Widget _buildInfoSection2() {
    return FadeIn(
      2,
      Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Tell Us \n A Little More \n About Yourself...",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 34,
              ),
              // textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 40.0),
          Container(
            child: Text(
              "Which parish are you from?",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
          ),
          SizedBox(height: 30.0),
          _buildParishDropList(),
          RaisedButton(
            elevation: 5,
            color: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text(
              "Next",
              style: kHintTextStyle.copyWith(fontSize: 18),
            ),
            onPressed: () {
              Section nextSection = Section.Section3;
              _switchPage(nextSection);
            },
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: FadeIn(
        3,
        // Form(
        //   key: _formKey,
        //   child:
        Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            if (section == Section.Section1) _buildInfoSection1(),
            if (section == Section.Section2) _buildInfoSection2(),
            if (section == Section.Section3) _buildInfoSection3(),
          ],
        ),
      ),
      // ),
    );
  }

  // uploadImage() async {
  //   await Firebase.initializeApp();
  //   final _storage = FirebaseStorage.instance;
  //   final _picker = ImagePicker();
  //   PickedFile image;

  //   //Check Permissions
  //   await Permission.photos.request();

  //   var permissionStatus = await Permission.photos.status;

  //   if (permissionStatus.isGranted) {
  //     //Select Image
  //     image = await _picker.getImage(source: ImageSource.gallery);
  //     var file = File(image.path);

  //     if (image != null) {
  //       //Upload to Firebase
  //       var snapshot =
  //           await _storage.ref().child('folderName/imageName').putFile(file);
  //       var downloadUrl = await snapshot.ref.getDownloadURL();

  //       setState(() {
  //         imageUrl = downloadUrl;
  //       });
  //     } else {
  //       print('No Path Received');
  //     }
  //   } else {
  //     print('Grant Permissions and try again');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [_buildBackground(), _buildCowImage(), _buildBody()],
    );
  }
}

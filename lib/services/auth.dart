// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

// class AuthService {
//   final _auth = FirebaseAuth.instance;

//   void submitForm(
//     String type,
//     String email,
//     String password,
//     String firstName,
//     String lastName,
//     String parish,
//     File image,
//     BuildContext ctx,
//   ) async {
//     var result;
//     try {
//       if (type == "Sign In") {
//         result = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//       } else {
//         result = await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//       }

//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('user_image')
//           .child(result.user.uid + '.jpg');
//       await ref.putFile(image);
//       final url = await ref.getDownloadURL();

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(result.user.uid)
//           .set({
//         'firstName': firstName,
//         'lastName': lastName,
//         'parish': parish,
//         'email': email,
//         'image_url': url,
//       });
//     } on PlatformException catch (err) {
//       var message = 'An error occurred, pelase check your credentials!';

//       if (err.message != null) {
//         message = err.message;
//       }
//       print(message);
//       // Scaffold.of(ctx).showSnackBar(
//       //   SnackBar(
//       //     content: Text(message),
//       //     backgroundColor: Theme.of(ctx).errorColor,
//       //   ),
//       // );
//       // setState(() {
//       //   _isLoading = false;
//       // });
//     } catch (err) {
//       print(err);
//       // setState(() {
//       //   _isLoading = false;
//       // });
//     }
//   }
// }

import 'package:animal_tracker/screens/additional_info_screen.dart';
import 'package:animal_tracker/screens/auth_screen.dart';
import 'package:animal_tracker/screens/main_screen.dart';
import 'package:animal_tracker/screens/profile_screen.dart';
import 'package:animal_tracker/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './screens/management_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          // initialRoute: '/',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/login': (context) => LoginScreen(),
            '/info': (context) => AdditionalInfoScreen(),
            '/main': (context) => MainScreen(),
            '/home': (context) => HomeScreen(),
            '/settings': (context) => SettingsScreen(),
            '/profile': (context) => ProfileScreen(),
            '/manage': (context) => ManagementScreen()

            // When navigating to the "/second" route, build the SecondScreen widget.
            // '/second': (context) => SecondScreen(),
          },
          theme: ThemeData(
            primaryColor: Colors.black,
            buttonColor: Colors.black,
          ),
          title: 'Flutter Login UI',
          debugShowCheckedModeBanner: false,
          home: StreamBuilder(
            stream: FirebaseAuth.instance.onAuthStateChanged,
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData) {
                return MainScreen();
              } else
                return LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}

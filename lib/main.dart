import 'package:animal_tracker/notifications/notif_main.dart';
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

import './screens/analytics_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(MyApp());
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  enableVibration: true,
  playSound: true,
);

/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message ${message.messageId}");
}

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
            '/manage': (context) => AnalyticsScreen()

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
            stream: FirebaseAuth.instance.authStateChanges(),
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

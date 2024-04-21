
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/offers/AddTrajet.dart';
import 'package:frontendcovoituragemobile/pages/Favorite.dart';
import 'package:frontendcovoituragemobile/pages/home.dart';
import 'package:frontendcovoituragemobile/pages/authentification/signup_page.dart';
import 'package:frontendcovoituragemobile/pages/authentification/login.dart';
import 'package:frontendcovoituragemobile/pages/authentification/profile.dart';

import 'package:frontendcovoituragemobile/pages/splash_animated_page.dart';
import 'package:permission_handler/permission_handler.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  runApp(const MyApp());

}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),

      routes: {
        '/': (context) => AnimatedSplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilPage(),
        '/addOffer': (context) => AddTrajet(),

      },
    );
  }
}

void handleError(dynamic error, StackTrace stackTrace) {
  print('An error occurred: $error');

}
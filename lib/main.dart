
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/AddTrajet.dart';
import 'package:frontendcovoituragemobile/pages/home.dart';
import 'package:frontendcovoituragemobile/pages/signup_page.dart';
import 'package:frontendcovoituragemobile/pages/login.dart';
import 'package:frontendcovoituragemobile/pages/profile.dart';
import 'package:frontendcovoituragemobile/pages/splash_animated_page.dart';
import 'package:frontendcovoituragemobile/pages/test.dart';

Future<void> main() async {
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
        '/test': (context) => CarsListPage(),
      },
    );
  }
}

void handleError(dynamic error, StackTrace stackTrace) {
  print('An error occurred: $error');

}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/home_page.dart';
import 'package:frontendcovoituragemobile/pages/signup_page.dart';

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
        '/' : (context) => const SignupPage(),
        '/home' : (context) => const HomePage(),
        '/profile' : (context) => const HomePage(),



      },
    );
  }
}

void handleError(dynamic error, StackTrace stackTrace) {
  // Handle the error
  print('An error occurred: $error');
  // Show an error message or perform other actions

}

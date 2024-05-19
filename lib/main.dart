
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/Navigation/navigation_bar.dart';
import 'package:frontendcovoituragemobile/pages/authentification/signup_page.dart';
import 'package:frontendcovoituragemobile/pages/authentification/login.dart';
import 'package:frontendcovoituragemobile/pages/authentification/profile.dart';
import 'package:frontendcovoituragemobile/pages/Splash/splash_animated_page.dart';
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
      theme: ThemeData(
        primaryColor: Color(0xFF009C77),
        colorScheme: ColorScheme(
          primary: Color(0xFF009C77),
          secondary: Color(0xFFFF9800),
          surface: Color(0xFFECECEC),
          background: Color(0xFFECECEC),
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => AnimatedSplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => NavigationBarScreen(),
        '/profile': (context) => ProfilPage(),

      },
    );
  }
}

void handleError(dynamic error, StackTrace stackTrace) {
  print('An error occurred: $error');

}
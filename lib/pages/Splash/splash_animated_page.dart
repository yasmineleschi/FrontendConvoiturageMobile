import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:frontendcovoituragemobile/pages/Splash/onboarding.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> {
  final List<String> _animations = [
    'assets/animations/animation2.json',
  ];

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 12), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(_animations.length, (index) {
          return Lottie.asset(
            _animations[index],
            width: double.infinity,
            height: double.infinity,
          );
        }),
      ),
    );
  }
}


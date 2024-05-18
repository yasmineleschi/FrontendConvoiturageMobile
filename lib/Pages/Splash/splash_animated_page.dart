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

  bool _buttonVisible = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      setState(() {
        _buttonVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009C77),
      body: Stack(
        children: [
          ..._animations.map((animation) => Lottie.asset(
            animation,
            width: double.infinity,
            height: double.infinity,
          )),
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _buttonVisible ? 50 : -100,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(
                      Colors.white),
                ),
                child: Text(
                  'Carpooling with Tawssila',
                  style: TextStyle(fontSize: 20 ,color:Color(0xFF009C77)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

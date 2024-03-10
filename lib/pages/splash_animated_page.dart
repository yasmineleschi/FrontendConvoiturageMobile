import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontendcovoituragemobile/pages/login.dart';
import 'package:frontendcovoituragemobile/pages/onboarding.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}


class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<String> _images = [
    'assets/images/splash1.png',
    'assets/images/splash2.png',
    'assets/images/splash3.png',
    'assets/images/splash4.png',
    'assets/images/splach5.png',
  ];

  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _opacityAnimations = [];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < _images.length; i++) {
      final controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this, // Now 'this' is a valid TickerProvider
      );
      final animation = Tween(begin: 0.0, end: 1.0).animate(controller);
      _controllers.add(controller);
      _opacityAnimations.add(animation);
    }

    _controllers.first.forward();

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentIndex < _images.length - 1) {
        _controllers[_currentIndex].reverse();
        _currentIndex++;
        _controllers[_currentIndex].forward();
      } else {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(_images.length, (index) {
          return FadeTransition(
            opacity: _opacityAnimations[index],
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/Model/Onboarding.dart';
import 'package:frontendcovoituragemobile/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Onboarding> onboardingData = [
    Onboarding(
      imagePath: "assets/images/car.png",
      type: OnboardingType.type1,
    ),
    Onboarding(
      imagePath: "assets/images/icon.png",
      type: OnboardingType.type2,
    ),
    Onboarding(
      imagePath: "assets/images/car.png",
      type: OnboardingType.type3,
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        onPageChanged: (int page) {
          setState(() {
            currentPage = page;
          });
        },
        itemBuilder: (_, i) {
          Onboarding currentScreen = onboardingData[i];
          switch (currentScreen.type) {
            case OnboardingType.type1:
              return Type1Widget(onboarding: currentScreen);
            case OnboardingType.type2:
              return Type2Widget(onboarding: currentScreen);
            case OnboardingType.type3:
              return Type3Widget(onboarding: currentScreen);

            default:
              return Type1Widget(
                  onboarding: currentScreen);
          }
        },
      ),
      bottomSheet: currentPage == onboardingData.length - 1
          ? Container(
              margin: const EdgeInsets.only(top: 20),
              height: 50,
              width: 200,
              child: ElevatedButton(
                onPressed: ()  {
                  _finishOnboarding();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF009C77)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Color(0xFFECEAEA)),
                    ),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          : Offstage(),
    );
  }

  void _finishOnboarding() async {
    await _markOnboardingComplete();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
  }
}

class Type1Widget extends StatelessWidget {
  final Onboarding onboarding;

  const Type1Widget({Key? key, required this.onboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Image.asset(
              onboarding.imagePath,
              width: 200,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                      text: "Welcome To \n",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextSpan(
                      text: "Taw",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009C77))),
                  TextSpan(
                      text: "Sila",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFDB583))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 24, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text:
                          "We’re Here To Help You Join And Offer \nCarpooling Opportunities\n \n"),

                  TextSpan(
                      text: "HOW? \n ",
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                  TextSpan(text: "Follow The Next Steps !"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Type2Widget extends StatelessWidget {
  final Onboarding onboarding;

  const Type2Widget({Key? key, required this.onboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 190),
            Image.asset(
              onboarding.imagePath,
              width: 300,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                      text: "You’re A ",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextSpan(
                      text: "Busy Person ",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009C77))),
                ],
              ),
            ),
            SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: "You No Longer Want To "),
                  TextSpan(text: "Waste Time Waiting For "),
                  TextSpan(text: "Transportation, All Alone ..."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Type3Widget extends StatelessWidget {
  final Onboarding onboarding;

  const Type3Widget({Key? key, required this.onboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/back.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              onboarding.imagePath,
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                      text: "You Own  ",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextSpan(
                      text: "A Vehicule",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009C77))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(text: "But Lack Company & Why  "),
                  TextSpan(text: "Not Someone To Share "),
                  TextSpan(text: "The Fuel Fares With .."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


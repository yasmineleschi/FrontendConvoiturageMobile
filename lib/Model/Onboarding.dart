
enum OnboardingType { type1, type2, type3 }

class Onboarding {
  final String imagePath;
  final OnboardingType type;

  Onboarding({
    required this.imagePath,
    this.type = OnboardingType.type1,
  });
}

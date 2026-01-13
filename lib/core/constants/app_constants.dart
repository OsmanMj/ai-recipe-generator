import 'api_keys.dart';

class AppConstants {
  static const String appName = 'AI Recipe Generator';
  static const String appVersion = '1.1.2';

  // Hive Boxes
  static const String favoritesBox = 'favorites_box';

  // API (Placeholder - user needs to provide key or we use a configurable one)
  // Using Gemini as default for now
  static const String geminiApiKey = ApiKeys.geminiApiKey;
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/';

  static const List<String> geminiModels = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-3-flash',
  ];

  // Strings (Arabic)
  static const String splashText = 'Find your next meal';
  static const String onboardingTitle1 = 'Welcome';
  static const String onboardingDesc1 =
      'Discover recipes based on what you have.';
  static const String onboardingTitle2 = 'Cuisine Choice';
  static const String onboardingDesc2 = 'Select your favorite cuisine type.';
  static const String onboardingTitle3 = 'Cook & Enjoy';
  static const String onboardingDesc3 = 'Follow simple steps to create magic.';

  // Cuisines
  static const List<String> cuisines = [
    'Any',
    'Turkish',
    'Arabic',
    'Italian',
    'Indian',
    'Mexican',
    'Chinese',
    'Japanese',
    'French',
    'American',
  ];
}

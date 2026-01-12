class Constants {
  // API Configuration
  // For Android emulator: 'http://10.0.2.2:8080/'
  // For physical device: Replace 10.0.2.2 with your PC's LAN IP (e.g., 'http://192.168.1.100:8080/')
  // For production: 'https://your-production-domain.com/'
  static const String apiBaseUrl = 'http://192.168.1.9:5000/';

  // App Information
  static const String appName = 'Crop Disease Detector';
  static const String appVersion = '1.0.0';

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // Default Values
  static const double defaultConfidenceThreshold = 0.7;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVoiceDuration = 30; // seconds

  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'sw': 'Swahili',
  };

  // Crop Types for Questions
  static const List<String> cropTypes = [
    'Maize',
    'Rice',
    'Wheat',
    'Tomato',
    'Potato',
    'Beans',
    'Cassava',
    'Banana',
    'Vegetables',
    'Fruits',
    'Other'
  ];

  // Common Symptoms
  static const List<String> commonSymptoms = [
    'Yellow leaves',
    'Brown spots',
    'White powder',
    'Wilting',
    'Stunted growth',
    'Leaf curling',
    'Fruit rot',
    'Root damage',
    'Insect presence',
    'Other'
  ];
}

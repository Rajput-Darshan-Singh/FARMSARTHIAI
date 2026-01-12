import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = Locale('en', 'US');
  final List<Locale> _supportedLocales = [
    Locale('en', 'US'),
    Locale('hi', 'IN'),
    Locale('kn', 'IN'), // Kannada
    Locale('mr', 'IN'), // Marathi
  ];

  Locale get currentLocale => _currentLocale;
  List<Locale> get supportedLocales => _supportedLocales;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code');
      final countryCode = prefs.getString('country_code');
      if (languageCode != null && countryCode != null) {
        _currentLocale = Locale(languageCode, countryCode);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');

      // Keep LocalStorage + user-friendly language label in sync for profile
      final localStorage = LocalStorage();
      await localStorage.setLanguage(locale.languageCode);

      final languageLabel = _languageLabelFromCode(locale.languageCode);
      await prefs.setString('user_language', languageLabel);
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  void toggleLanguage() {
    final currentIndex = _supportedLocales.indexWhere(
      (locale) => locale.languageCode == _currentLocale.languageCode,
    );
    final nextIndex = (currentIndex + 1) % _supportedLocales.length;
    setLocale(_supportedLocales[nextIndex]);
  }

  String _languageLabelFromCode(String code) {
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'kn':
        return 'Kannada';
      case 'mr':
        return 'Marathi';
      case 'en':
      default:
        return 'English';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocaleService {
  // Singleton pattern
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  // Get saved locale
  Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.keyLanguage) ?? 'en';
    return Locale(languageCode);
  }

  // Save locale
  Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
  }

  // Get locale from code
  Locale getLocaleFromCode(String code) {
    return Locale(code);
  }

  // Get language name
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'mr':
        return 'मराठी';
      case 'te':
        return 'తెలుగు';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  // Get supported locales
  List<Locale> getSupportedLocales() {
    return const [
      Locale('en'), // English
      Locale('hi'), // Hindi
      Locale('mr'), // Marathi
      Locale('te'), // Telugu
      Locale('ta'), // Tamil
    ];
  }

  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    return getLanguageName(locale.languageCode);
  }
}
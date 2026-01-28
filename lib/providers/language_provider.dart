import 'package:flutter/material.dart';
import '../services/locale_service.dart';

class LanguageProvider with ChangeNotifier {
  final LocaleService _localeService = LocaleService();
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    _currentLocale = await _localeService.getSavedLocale();
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _localeService.saveLocale(languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    return _localeService.getLanguageName(code);
  }

  List<Locale> getSupportedLocales() {
    return _localeService.getSupportedLocales();
  }
}
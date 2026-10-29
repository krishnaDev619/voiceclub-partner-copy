import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/app_themes.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.main;

  ThemeData get currentTheme => _currentTheme;

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }
}

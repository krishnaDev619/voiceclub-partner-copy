import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/app_themes.dart';

class ThemeController extends GetxController {
  final _currentTheme = AppThemes.main.obs;

  ThemeData get currentTheme => _currentTheme.value;

  void setTheme(ThemeData theme) {
    _currentTheme.value = theme;
  }
}

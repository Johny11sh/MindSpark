// ignore_for_file: prefer_if_null_operators, implementation_imports, file_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/OnBoarding.dart';
import 'Themes.dart';

class ThemeController extends GetxController {
  final Rx<ThemeData> _currentTheme = Themes.customLightTheme.obs;

  ThemeData get initialTheme => _currentTheme.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    final savedTheme = sharedPrefs.prefs.getString("theme");
    // Default to light theme if no preference exists

    if (savedTheme == "light") {
      _currentTheme.value = Themes.customLightTheme;
    } else {
      _currentTheme.value = Themes.customDarkTheme;
    }
    update();
    // Get.forceAppUpdate();
  }

  void toggleTheme(String mode) {
    // Switch to the opposite theme
    if (mode == "dark") {
      _currentTheme.value = Themes.customLightTheme;
      sharedPrefs.prefs.setString("theme", "light");
    } else if (mode == "light") {
      _currentTheme.value = Themes.customDarkTheme;
      sharedPrefs.prefs.setString("theme", "dark");
    }

    update();
    // Get.forceAppUpdate();
  }
}

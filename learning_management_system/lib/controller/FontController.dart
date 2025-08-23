// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/SharedPrefs.dart';

class FontController extends GetxController {
  final SharedPrefs sharedPrefs = SharedPrefs.instance;

  // Simple reactive variables
  final RxDouble fontSizeDelta = 0.0.obs;
  final RxString fontFamily =
      Platform.isAndroid
          ? 'Roboto'.obs
          : Platform.isIOS
          ? 'Montserrat'.obs
          : 'Montserrat'.obs;

  // Correct font family names that Flutter can use
  final List<String> availableFonts = [
    'Montserrat',
    'Roboto',
    'Amiri',
    'Cairo',
    'Changa',
    'Harmattan',
    'Lalezar',
    'Merriweather',
    'Tajawal',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadFontSettings();
  }

  void _loadFontSettings() {
    try {
      // Load font size delta
      final savedFontDelta = sharedPrefs.prefs.getDouble('fontDelta');
      if (savedFontDelta != null) {
        fontSizeDelta.value = savedFontDelta.clamp(-6.0, 6.0);
      }

      // Load font family
      final savedFontFamily = sharedPrefs.prefs.getString('fontFamily');
      if (savedFontFamily != null && availableFonts.contains(savedFontFamily)) {
        fontFamily.value = savedFontFamily;
      }
    } catch (e) {
      debugPrint("Error loading font settings: $e");
      // Use defaults
      fontSizeDelta.value = 0.0;
      fontFamily.value =
          Platform.isAndroid
              ? 'Roboto'
              : Platform.isIOS
              ? 'Montserrat'
              : 'Montserrat';
    }
  }

  // Simple font size update
  void updateFontSize(double newDelta) {
    try {
      final clamped = newDelta.clamp(-6.0, 6.0);
      fontSizeDelta.value = clamped;
      sharedPrefs.prefs.setDouble('fontDelta', clamped);
    } catch (e) {
      debugPrint("Error saving font size: $e");
    }
  }

  // Simple font family update
  void updateFontFamily(String newFamily) {
    try {
      if (availableFonts.contains(newFamily)) {
        fontFamily.value = newFamily;
        sharedPrefs.prefs.setString('fontFamily', newFamily);
        debugPrint("Font family updated to: $newFamily");
      }
    } catch (e) {
      debugPrint("Error saving font family: $e");
    }
  }

  // Getters
  double get currentFontSizeDelta => fontSizeDelta.value;
  String get currentFontFamily => fontFamily.value;
}

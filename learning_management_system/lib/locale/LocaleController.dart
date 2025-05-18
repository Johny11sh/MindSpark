// ignore_for_file: unused_import, file_names, non_constant_identifier_names

import 'dart:ui';
import '../view/OnBoarding.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../services/SharedPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  final Rx<Locale> _currentLang = const Locale('En').obs;

  Locale get initialLang => _currentLang.value;

  final List<Locale> SupportedLanguages = [
    const Locale("En"),
    const Locale("Ar"),
    const Locale("De"),
    const Locale("Fr"),
    const Locale("Es"),
  ];

  @override
  void onInit() async {
    super.onInit();

    final savedLang = sharedPrefs.prefs.getString('lang');

    if (savedLang != null) {
      _currentLang.value = Locale(savedLang);
    } else {
      _currentLang.value = Get.deviceLocale ?? const Locale("En");
    }
  }

  void changeLang(String langCode) {
    if (langCode.isEmpty) {
      throw ArgumentError("Language code cannot be empty".tr);
    }

    final localeLang = Locale(langCode);
    if (!SupportedLanguages.contains(localeLang)) {
      throw ArgumentError("Unsupported language code: $langCode".tr);
    }

    sharedPrefs.prefs.setString("lang", langCode);
    _currentLang.value = localeLang;
    Get.updateLocale(localeLang);
  }
}

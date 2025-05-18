// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();

  static final SharedPrefs _instance = SharedPrefs._();

  static SharedPrefs get instance => _instance;

  late SharedPreferences _prefs;

  Future<void> Init() async {
    try {
      print("Initializing Shared Preferences");
      _prefs = await SharedPreferences.getInstance();
      print("Shared Preferences is Initialized");
    } catch (e) {
      print("Error When initializing shredPreferences");
    }
  }

  SharedPreferences get prefs => _prefs;
}

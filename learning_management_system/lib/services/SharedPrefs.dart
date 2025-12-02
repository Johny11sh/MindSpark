// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();

  static final SharedPrefs _instance = SharedPrefs._();

  static SharedPrefs get instance => _instance;

  late SharedPreferences _prefs;

  Future<void> saveMap(String key, Map<int, bool> map) async {
    final prefs = await SharedPreferences.getInstance();
    final stringMap = map.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(key, jsonEncode(stringMap));
  }

  Future<Map<int, bool>> loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return {};
    final decoded = Map<String, dynamic>.from(jsonDecode(data));
    return decoded.map((k, v) => MapEntry(int.parse(k), v as bool));
  }

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

// ignore_for_file: file_names

import 'package:get/get.dart';

import 'SharedPrefs.dart';

class CacheManager extends GetxController {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  final RxBool isCacheEnabled = true.obs;

  Future<void> init() async {
    final prefs = SharedPrefs.instance;
    isCacheEnabled.value = prefs.prefs.getBool('cacheEnabled') ?? true;
  }

  Future<void> setCacheEnabled(bool enabled) async {
    final prefs = SharedPrefs.instance;
    await prefs.prefs.setBool('cacheEnabled', enabled);
    isCacheEnabled.value = enabled;
  }

  static CacheManager get to => _instance;
}

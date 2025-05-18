// ignore_for_file: file_names, non_constant_identifier_names, use_full_hex_values_for_flutter_colors

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/SharedPrefs.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  SharedPrefs sharedPrefs = SharedPrefs.instance;
  bool isConnected = false;
  bool isLoading = false; // Track loading state

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity(); // Check connectivity only once when the app starts
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResult);
      sharedPrefs.prefs.setBool('isConnected', true);
    } catch (e) {
      sharedPrefs.prefs.setBool('isConnected', false);
      Get.snackbar("Error".tr, "Failed to check connectivity: $e".tr);
    }
  }

  void _updateConnectivityStatus(List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.rawSnackbar(
        messageText:  Text("Please connect to the internet or you will have limited features".tr),
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 7),
        backgroundColor: const Color.fromARGB(255,189, 189, 189),
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 35),
        margin: const EdgeInsets.all(5),
        borderRadius: 5,
        borderColor: const Color.fromARGB(255,103, 103, 103),
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.rawSnackbar(
        messageText:  Text("Connected to the internet".tr),
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.wifi_rounded, color: Colors.white, size: 35),
        margin: const EdgeInsets.all(5),
        borderRadius: 5,
        borderColor: Colors.green[700]!,
      );
    }
  }

  // Add a method to manually check connectivity when needed
  Future<void> checkConnectivityManually() async {
    isLoading = true; // Start loading
    update(); 
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResult);
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to check connectivity: $e".tr);
    }
    finally {
      isLoading = false; // Stop loading
      update(); // Notify listeners
    }
  }
}



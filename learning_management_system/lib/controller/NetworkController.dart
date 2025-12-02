// // ignore_for_file: file_names, non_constant_identifier_names, use_full_hex_values_for_flutter_colors

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:http/http.dart' as http;
// import '../services/SharedPrefs.dart';
// import '../core/constants/FontGlobals.dart';

// class NetworkController extends GetxController {
//   final SharedPrefs _sharedPrefs = SharedPrefs.instance;

//   // reactive flags UI can observe
//   final RxBool isConnected = false.obs;
//   final RxBool isChecking = false.obs;

//   // small throttles
//   DateTime? _lastSnackbarAt;
//   final Duration _snackbarCooldown = const Duration(seconds: 4);
//   final Duration _verifyTimeout = const Duration(seconds: 5);

//   // Public initializer (call in main or initState once)
//   Future<void> init() async {
//     await checkConnectivityManually();
//   }

//   // Manual re-check (no stream subscription)
//   Future<void> checkConnectivityManually({bool showFeedback = true}) async {
//     if (isChecking.value) return;
//     isChecking.value = true;

//     try {
//       // quick platform connectivity check
//       final List<ConnectivityResult> conn =
//           await Connectivity().checkConnectivity();

//       if (conn == ConnectivityResult.none) {
//         _setConnected(false);
//         if (showFeedback) _notifyNoConnection();
//         return;
//       }

//       // verify actual internet access (some networks may be captive)
//       final bool ok = await _verifyInternet();
//       _setConnected(ok);

//       if (!ok) {
//         if (showFeedback) _notifyNoConnection();
//       } else {
//         // connected - clear snackbar if present
//         if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
//       }
//     } catch (e) {
//       debugPrint('NetworkController.checkConnectivityManually error: $e');
//       _setConnected(false);
//       if (showFeedback) _notifyNoConnection();
//     } finally {
//       isChecking.value = false;
//     }
//   }

//   Future<bool> _verifyInternet() async {
//     try {
//       final uri = Uri.parse('https://www.google.com/generate_204');
//       final response = await http.get(uri).timeout(_verifyTimeout);
//       return response.statusCode == 204 || response.statusCode == 200;
//     } catch (e) {
//       debugPrint('Network verify failed: $e');
//       return false;
//     }
//   }

//   void _setConnected(bool value) {
//     isConnected.value = value;
//     try {
//       _sharedPrefs.prefs.setBool('isConnected', value);
//     } catch (_) {}
//   }

//   void _notifyNoConnection() {
//     final now = DateTime.now();
//     if (_lastSnackbarAt != null &&
//         now.difference(_lastSnackbarAt!) < _snackbarCooldown) {
//       return; // throttle snackbars
//     }
//     _lastSnackbarAt = now;

//     if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

//     Get.rawSnackbar(
//       messageText: Text(
//         "Please connect to the internet or you will have limited features".tr,
//         style: TextStyle(fontFamily: globalFontFamily),
//       ),
//       isDismissible: true,
//       snackPosition: SnackPosition.BOTTOM,
//       duration: const Duration(seconds: 5),
//       backgroundColor: const Color.fromARGB(255, 189, 189, 189),
//       icon: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 28),
//       margin: const EdgeInsets.all(6),
//       borderRadius: 6,
//       borderColor: const Color.fromARGB(255, 103, 103, 103),
//     );
//   }
// }

// ignore_for_file: file_names, non_constant_identifier_names, use_full_hex_values_for_flutter_colors

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/SharedPrefs.dart';
import '../core/constants/FontGlobals.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  SharedPrefs sharedPrefs = SharedPrefs.instance;
  bool isConnected = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    // Check initial connectivity and subscribe to changes
    _checkInitialConnectivity();

    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectivityStatus(result);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResult);
    } catch (e) {
      sharedPrefs.prefs.setBool('isConnected', false);
      isConnected = false;
      Get.snackbar("Error".tr, "Failed to check connectivity: $e".tr);
    }
  }

  void _updateConnectivityStatus(dynamic connectivityResult) {
    // connectivity_plus API changed in recent versions: checkConnectivity/onConnectivityChanged
    // may return either a single ConnectivityResult or a List<ConnectivityResult>.
    final bool hasConnection;
    if (connectivityResult is List<ConnectivityResult>) {
      hasConnection = !connectivityResult.contains(ConnectivityResult.none);
    } else if (connectivityResult is ConnectivityResult) {
      hasConnection = connectivityResult != ConnectivityResult.none;
    } else {
      hasConnection = false;
    }

    // persist and update local state so callers can rely on it
    try {
      sharedPrefs.prefs.setBool('isConnected', hasConnection);
    } catch (_) {}
    isConnected = hasConnection;

    if (!hasConnection) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.rawSnackbar(
        messageText: Text(
          "Please connect to the internet or you will have limited features".tr,
          style: TextStyle(fontFamily: globalFontFamily),
        ),
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 7),
        backgroundColor: const Color.fromARGB(255, 189, 189, 189),
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 35),
        margin: const EdgeInsets.all(5),
        borderRadius: 5,
        borderColor: const Color.fromARGB(255, 103, 103, 103),
      );
    } else {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
      // Optionally show a connected toast/snackbar
    }
    update();
  }

  /// Public initializer kept for backward compatibility with callers that invoke `init()`.
  Future<void> init() async {
    await _checkInitialConnectivity();
  }

  Future<void> checkConnectivityManually() async {
    isLoading = true;
    update();
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(connectivityResult);
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to check connectivity: $e".tr);
    } finally {
      isLoading = false;
      update();
    }
  }
}

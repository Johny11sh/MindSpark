// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/view/LogIn.dart';
import '../services/SharedPrefs.dart';
import '../view/NavBar.dart';
import 'NetworkController.dart';
import '../../view/OnBoarding.dart';

class ProfileController extends GetxController {
  late SharedPrefs sharedPrefs;
  var isLoading = true.obs;
  var profileData = {}.obs;
  final NetworkController networkController = Get.find<NetworkController>();

  @override
  void onInit() {
    super.onInit();
    sharedPrefs = SharedPrefs.instance;
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading(true);
      await _loadCachedProfile();
      if (sharedPrefs.prefs.getBool('isConnected') == true) {
        await getProfileData();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadCachedProfile() async {
    try {
      final cachedData = sharedPrefs.prefs.getString('cached_profile');
      if (cachedData != null) {
        profileData.value = jsonDecode(cachedData);
      }
    } catch (e) {
      debugPrint("Error loading cached profile: $e");
    }
  }

  Future<void> _cacheProfile() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_profile',
        jsonEncode(profileData.value),
      );
    } catch (e) {
      debugPrint("Error caching profile: $e");
    }
  }

  Future<void> getProfileData() async {
    final token = sharedPrefs.prefs.getString('token') ?? '';
    if (token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LogIn());
        showErrorSnackbar("Session expired. Please log in again.".tr);
      });
      return;
    }

    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/getuser';

      final response = await http.get(
        Uri.parse(APIurl),
        headers: {
          'Authorization': "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['user'] is Map) {
          final userData = Map<String, dynamic>.from(responseBody['user']);
          userData.remove('subjects');
          userData.remove('created_at');
          userData.remove('updated_at');
          profileData.value = userData;
          await _cacheProfile();
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
        });
      } else {
        if (profileData.isEmpty) {
          throw Exception("Failed to load profile: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      if (profileData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.".tr);
      } else {
        showErrorSnackbar("Using cached data - connection is slow".tr);
      }
    } catch (e) {
      if (profileData.isEmpty) {
        showErrorSnackbar("Failed to load profile".tr);
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}".tr);
      }
      debugPrint("Error fetching profile: $e");
    }
  }

  Future<Map<String, dynamic>?> sendLogOutData() async {
    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        debugPrint("No token found, already logged out");
        return null;
      }

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/logout';

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("Logout API response: ${response.statusCode}");

      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      await sharedPrefs.prefs.remove('cached_profile');
      await sharedPrefs.prefs.clear();

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint("Logout successful");
        await sharedPrefs.prefs.clear();
        Get.offAll(() => OnBoarding());
        return responseBody;
      } else {
        debugPrint("Logout API failed but local session cleared");
        Get.offAll(() => OnBoarding());
        return {'success': true, 'message': 'Local session cleared'.tr};
      }
    } on TimeoutException {
      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      await sharedPrefs.prefs.remove('cached_profile');
      debugPrint("Logout timeout but local session cleared");
      Get.offAll(() => OnBoarding());
      return {'success': true, 'message': 'Local session cleared'.tr};
    } catch (e) {
      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      await sharedPrefs.prefs.remove('cached_profile');
      debugPrint("Logout error: $e");
      Get.offAll(() => OnBoarding());
      return {'success': true, 'message': 'Local session cleared'.tr};
    }
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
} 
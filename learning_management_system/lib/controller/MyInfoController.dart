import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../core/function/SnackBarFun.dart';
import '../services/SharedPrefs.dart';
import '../view/LogIn.dart';
import '../view/NavBar.dart';

class MyInfoController extends GetxController {
  late SharedPrefs sharedPrefs;
  Map<String, dynamic> profileData = {};

  late String userName;
  late String phone;
  late String token;

  Future<void> _loadInitialData() async {
    // Try to load from cache first
    await _loadCachedProfile();

    // Then try to fetch fresh data if online
    if (sharedPrefs.prefs.getBool('isConnected') == true) {
      await getProfileData();
    }
  }

  Future<void> _loadCachedProfile() async {
    try {
      final cachedData = sharedPrefs.prefs.getString('cached_profile');
      if (cachedData != null) {
        final Map<String, dynamic> parsedData = jsonDecode(cachedData);
        profileData = parsedData;
        update();
      }
    } catch (e) {
      debugPrint("Error loading cached profile: $e");
    }
  }

  Future<void> _cacheProfile() async {
    try {
      await sharedPrefs.prefs.setString(
        'cached_profile',
        jsonEncode(profileData),
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

      final response = await http
          .get(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Extract only the needed fields from the user object
        if (responseBody['user'] is Map) {
          final userData = Map<String, dynamic>.from(responseBody['user']);

          // Remove unwanted fields
          userData.remove('subjects');
          userData.remove('created_at');
          userData.remove('updated_at');

          // Keep all other fields including subs and lecturesNum

          profileData = userData;
          update();
          await _cacheProfile();
        }
      } else if (response.statusCode == 401) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
        });
      } else {
        // If API fails but we have cached data, don't throw error
        if (profileData.isEmpty) {
          throw Exception("Failed to load profile: ${response.statusCode}");
        }
      }
    } on TimeoutException {
      // If we have cached data, just show a warning
      if (profileData.isEmpty) {
        showErrorSnackbar("Request timeout. Please try again.".tr);
      } else {
        showErrorSnackbar("Using cached data - connection is slow".tr);
      }
    } catch (e) {
      // If we have cached data, just show a warning
      if (profileData.isEmpty) {
        showErrorSnackbar("Failed to load profile".tr);
      } else {
        showErrorSnackbar("Using cached data - ${e.toString()}".tr);
      }
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    sharedPrefs = SharedPrefs.instance;
    getProfileData();
    _loadInitialData();
    // userName = sharedPrefs.prefs.getString("userName")!;
    // phone = sharedPrefs.prefs.getString("phone")!;
    token = sharedPrefs.prefs.getString("token")!;
    print("===================token: $token =================================");
  }
}

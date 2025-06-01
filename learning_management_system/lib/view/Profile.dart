// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:learning_management_system/core/classes/WatchList.dart';

import '../core/classes/AboutUs.dart';
import '../core/classes/ChangeTheme.dart';
import '../core/classes/ContactUs.dart';
import '../core/classes/PrivacyPolicy.dart';
import '../view/LogIn.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/ImageAssets.dart';
import '../../view/OnBoarding.dart';
import 'package:get/get.dart';
import '../controller/NetworkController.dart';
import '../core/classes/ChangePassword.dart';
import '../core/classes/ChangeUsername.dart';
import '../core/classes/Language.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:flutter/material.dart';

import 'NavBar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool? isConnected;
  late SharedPrefs sharedPrefs;
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSharedPreferences().then((_) => _loadInitialData());
  }

  Future<void> _initSharedPreferences() async {
    sharedPrefs = SharedPrefs.instance;
  }

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
        setState(() {
          profileData = parsedData;
        });
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
          if (mounted) {
            setState(() {
              profileData = userData;
            });
            await _cacheProfile();
          }
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

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  Future<Map<String, dynamic>?> sendLogOutData() async {
    try {
      // 1. Token validation with early return
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        debugPrint("No token found, already logged out");
        return null;
      }

      // 2. Configurable API URL
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/logout';

      // 3. API request with timeout
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

      // 4. Always clear local session data regardless of API response
      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      await sharedPrefs.prefs.remove('cached_profile');

      // 5. Response handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint("Logout successful");
        return responseBody;
      } else {
        // Even if API fails, we consider logout successful locally
        debugPrint("Logout API failed but local session cleared");
        return {'success': true, 'message': 'Local session cleared'.tr};
      }
    } on TimeoutException {
      // Still clear local data even on timeout
      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      await sharedPrefs.prefs.remove('cached_profile');
      debugPrint("Logout timeout but local session cleared");
      return {'success': true, 'message': 'Local session cleared'.tr};
    } catch (e) {
      // Still clear local data even on error
      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      await sharedPrefs.prefs.remove('cached_profile');
      debugPrint("Logout error: $e");
      return {'success': true, 'message': 'Local session cleared'.tr};
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    final NetworkController networkController = Get.find<NetworkController>();
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Profile".tr), centerTitle: true),
        body: RefreshIndicator(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
          backgroundColor:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 210, 209, 224)
                  : Color.fromARGB(255, 46, 48, 97),
          onRefresh: () async {
            await networkController.checkConnectivityManually();
            await getProfileData();
          },
          child: ListView(
            children: [
              SizedBox(height: 30),
              Expanded(
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    isThreeLine: true,
                    leading: Image.asset( 
                      themeController.initialTheme == Themes.customLightTheme
                      ? ImageAssets.UserLightMode 
                      : ImageAssets.UserDarkMode ,
                      width: 60,
                      height: 60,
                    ),
                    title: Text(
                      profileData.isEmpty
                          ? "Username".tr
                          : "${profileData["userName"]}".tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                      ),
                    ),
                    trailing: Text(
                      profileData.isEmpty
                          ? "09XXXXXXXX"
                          : "0${profileData["number"]}".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileData.isEmpty
                              ? "● Subscriptions:\n".tr
                              : "● Subscriptions:\n[ ${profileData["subs"]} ]"
                                  .tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                          ),
                        ),
                        Text(
                          profileData.isEmpty
                              ? "\n● Lectures number: X".tr
                              : "\n● Lectures number: ${profileData["lecturesNum"]}"
                                  .tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Get.to(() => WatchList());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.format_list_numbered_outlined,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "WatchList".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => ChangeUsername());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.person,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Change Username".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => ChangePassword());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.password_outlined,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Change Password".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => Language());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.language_outlined,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Language".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => ChangeTheme());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.sunny,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Theme".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => ContactUs());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.call,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Contact Us".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => AboutUs());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.question_mark,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "About Us".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.to(() => PrivacyPolicy());
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.shield_sharp,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Privacy Policy".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () async {
                  await networkController.checkConnectivityManually();
                  isConnected = sharedPrefs.prefs.getBool('isConnected');
                  if (isConnected == true) {
                    sendLogOutData();
                    SharedPrefs.instance.prefs.clear();
                    Future.microtask(() {
                      Get.offAll(() => OnBoarding());
                    });
                  } else {
                    Get.snackbar(
                      "Connection error".tr,
                      "Connection access is needed".tr,
                    );
                  }
                },
                child: Card(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.logout_outlined,
                          size: 25,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 40, 41, 61)
                                  : Color.fromARGB(255, 210, 209, 224),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Log Out".tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

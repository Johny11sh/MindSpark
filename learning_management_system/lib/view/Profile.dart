// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:learning_management_system/core/classes/WatchList.dart';
import 'package:learning_management_system/view/HelpCenter.dart';
import 'package:learning_management_system/view/Management.dart';
import 'package:learning_management_system/view/MyInfo.dart';
import 'package:learning_management_system/view/Settings.dart';

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
  late String userName;

  // Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // _initSharedPreferences();
    sharedPrefs = SharedPrefs.instance;
    userName = sharedPrefs.prefs.getString("userName")!;
  }

  // Future<void> _initSharedPreferences() async {
  //   sharedPrefs = SharedPrefs.instance;
  // }

  // Future<void> _loadInitialData() async {
  //   // Try to load from cache first
  //   await _loadCachedProfile();
  //
  //   // Then try to fetch fresh data if online
  //   if (sharedPrefs.prefs.getBool('isConnected') == true) {
  //     await getProfileData();
  //   }
  // }
  //
  // Future<void> _loadCachedProfile() async {
  //   try {
  //     final cachedData = sharedPrefs.prefs.getString('cached_profile');
  //     if (cachedData != null) {
  //       final Map<String, dynamic> parsedData = jsonDecode(cachedData);
  //       setState(() {
  //         profileData = parsedData;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("Error loading cached profile: $e");
  //   }
  // }
  //
  // Future<void> _cacheProfile() async {
  //   try {
  //     await sharedPrefs.prefs.setString(
  //       'cached_profile',
  //       jsonEncode(profileData),
  //     );
  //   } catch (e) {
  //     debugPrint("Error caching profile: $e");
  //   }
  // }
  //
  // Future<void> getProfileData() async {
  //   final token = sharedPrefs.prefs.getString('token') ?? '';
  //   if (token.isEmpty) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Get.offAll(() => LogIn());
  //       showErrorSnackbar("Session expired. Please log in again.".tr);
  //     });
  //     return;
  //   }
  //
  //   try {
  //     var baseUrl = String.fromEnvironment(
  //       'API_BASE_URL',
  //       defaultValue: mainIP,
  //     );
  //     final APIurl = '$baseUrl/api/getuser';
  //
  //     final response = await http
  //         .get(
  //           Uri.parse(APIurl),
  //           headers: {
  //             'Authorization': "Bearer $token",
  //             'Content-Type': 'application/json; charset=UTF-8',
  //           },
  //         )
  //         .timeout(const Duration(seconds: 15));
  //
  //     if (response.statusCode == 200) {
  //       final responseBody = jsonDecode(response.body);
  //
  //       // Extract only the needed fields from the user object
  //       if (responseBody['user'] is Map) {
  //         final userData = Map<String, dynamic>.from(responseBody['user']);
  //
  //         // Remove unwanted fields
  //         userData.remove('subjects');
  //         userData.remove('created_at');
  //         userData.remove('updated_at');
  //
  //         // Keep all other fields including subs and lecturesNum
  //         if (mounted) {
  //           setState(() {
  //             profileData = userData;
  //           });
  //           await _cacheProfile();
  //         }
  //       }
  //     } else if (response.statusCode == 401) {
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         Get.offAll(() => LogIn());
  //       });
  //     } else {
  //       // If API fails but we have cached data, don't throw error
  //       if (profileData.isEmpty) {
  //         throw Exception("Failed to load profile: ${response.statusCode}");
  //       }
  //     }
  //   } on TimeoutException {
  //     // If we have cached data, just show a warning
  //     if (profileData.isEmpty) {
  //       showErrorSnackbar("Request timeout. Please try again.".tr);
  //     } else {
  //       showErrorSnackbar("Using cached data - connection is slow".tr);
  //     }
  //   } catch (e) {
  //     // If we have cached data, just show a warning
  //     if (profileData.isEmpty) {
  //       showErrorSnackbar("Failed to load profile".tr);
  //     } else {
  //       showErrorSnackbar("Using cached data - ${e.toString()}".tr);
  //     }
  //     debugPrint("Error fetching profile: $e");
  //   }
  // }

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
      print(token);
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
      await sharedPrefs.prefs.clear();

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
        // appBar: AppBar(title: Text("Profile".tr), centerTitle: true),
        body: Column(
          children: [
            // SizedBox(height: 50),
            Container(
              padding: EdgeInsets.only(top: 25),
              height: 120,
              color:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 40, 41, 61),
              // color: Colors.red,
              child: Center(
                child: Text(
                  "Profile".tr,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 40, 41, 61)
                          : Color.fromARGB(255, 210, 209, 224),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      child: Column(
                        children: [
                          Image.asset(
                            // ImageAssets.UserDarkMode,
                            ImageAssets.UserAvatar,
                            height: 130,
                            width: 130,
                          ),
                          // const SizedBox(height: 10),
                          Text(
                            userName,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await networkController
                                      .checkConnectivityManually();
                                  isConnected = sharedPrefs.prefs.getBool(
                                    'isConnected',
                                  );
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
                                child: Container(
                                  height: 36,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Log Out".tr,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.copyWith(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.to(MyInfo());
                                },
                                icon: Icon(Icons.edit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 30),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ListView(
                          shrinkWrap: true,
                          children: [

                            InkWell(
                              onTap: () {
                                Get.to(() => Management());
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
                                            ? Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        )
                                            : Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Management".tr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            color:
                                            themeController.initialTheme ==
                                                Themes.customLightTheme
                                                ? Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            )
                                                : Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 17,
                                        color:
                                        themeController.initialTheme ==
                                            Themes.customLightTheme
                                            ? Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        )
                                            : Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                            InkWell(
                              onTap: () {
                                Get.to(() => Settings());
                              },
                              child: Card(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.settings,
                                        size: 25,
                                        color:
                                        themeController.initialTheme ==
                                            Themes.customLightTheme
                                            ? Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        )
                                            : Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Settings".tr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            color:
                                            themeController.initialTheme ==
                                                Themes.customLightTheme
                                                ? Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            )
                                                : Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 17,

                                        color:
                                        themeController.initialTheme ==
                                            Themes.customLightTheme
                                            ? Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        )
                                            : Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: () {
                                Get.to(() => HelpCenter());
                              },
                              child: Card(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.help_center_outlined,
                                        size: 25,
                                        color:
                                        themeController.initialTheme ==
                                            Themes.customLightTheme
                                            ? Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        )
                                            : Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Help Center".tr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            color:
                                            themeController.initialTheme ==
                                                Themes.customLightTheme
                                                ? Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            )
                                                : Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 17,

                                        color:
                                        themeController.initialTheme ==
                                            Themes.customLightTheme
                                            ? Color.fromARGB(
                                          255,
                                          40,
                                          41,
                                          61,
                                        )
                                            : Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

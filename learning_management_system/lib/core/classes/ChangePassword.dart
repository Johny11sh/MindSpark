// ignore_for_file: non_constant_identifier_names, avoid_print, prefer_typing_uninitialized_variables, file_names

import 'dart:async';
import 'dart:convert';
import '../../view/NavBar.dart';
import '../../view/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../services/SharedPrefs.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../view/LogIn.dart';
import '../constants/ImageAssets.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final SharedPrefs sharedPrefs = SharedPrefs.instance;
  final NetworkController networkController = Get.find<NetworkController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  var TextAsAsterisks1;
  var TextAsAsterisks2;
  var TextAsAsterisks3;
  late Widget visibilityIcon1;
  late Widget invisibilityIcon1;
  late Widget visibilityIcon2;
  late Widget invisibilityIcon2;
  late Widget visibilityIcon3;
  late Widget invisibilityIcon3;
  late Widget temp;
  String? success;
  bool? isConnected;

  Future<Map<String, dynamic>?> changePasswordData() async {
    try {
      // 1. Token validation
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.".tr);
        });
        return null;
      }

      // 2. Input validation
      if (oldPasswordController.text.isEmpty ||
          passwordController.text.isEmpty) {
        showErrorSnackbar("Both old and new passwords are required".tr);
        return null;
      }

      // 3. Configurable API URL
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/changepassword';

      // 4. API request with timeout
      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'Bearer $token', // Changed from 'Authentication' to standard 'Authorization'
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'oldPassword': oldPasswordController.text.trim(),
              'newPassword': passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        "Change Password Response: ${response.statusCode} - ${response.body}",
      );

      // 5. Response handling
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        success = responseBody['success'];

        await sharedPrefs.prefs.setString('success', "true");
        showSuccessSnackbar("Password changed successfully".tr);
        return responseBody;
      } else if (response.statusCode == 401) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        success = responseBody['success'];

        await sharedPrefs.prefs.setString('success', "false");

        showErrorSnackbar("Invalid old password".tr);
      } else if (response.statusCode == 400) {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Invalid request'.tr;
        showErrorSnackbar(errorMessage);
      } else {
        throw Exception("Password change failed: ${response.statusCode}".tr);
      }
    } on TimeoutException {
      showErrorSnackbar("Request timeout. Please try again.".tr);
    } on http.ClientException catch (e) {
      showErrorSnackbar("Network error. Please check your connection.".tr);
      debugPrint("Network error: ${e.message}".tr);
    } catch (e) {
      showErrorSnackbar("Failed to change password".tr);
      debugPrint("Error changing password: $e".tr);
    }
    return null;
  }

  void showSuccessSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green[800]!,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
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
      debugPrint("Logout timeout but local session cleared");
      return {'success': true, 'message': 'Local session cleared'.tr};
    } catch (e) {
      // Still clear local data even on error
      await sharedPrefs.prefs.remove('token');
      await sharedPrefs.prefs.setBool('isLoggedIn', false);
      debugPrint("Logout error: $e");
      return {'success': true, 'message': 'Local session cleared'.tr};
    }
  }

  @override
  void initState() {
    TextAsAsterisks1 = true;
    TextAsAsterisks2 = true;
    TextAsAsterisks3 = true;
    visibilityIcon1 = const Icon(
      Icons.visibility,
      size: 25,
      color: Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon1 = const Icon(
      Icons.visibility_off,
      size: 25,
      color: Color.fromARGB(255, 210, 209, 224),
    );
    visibilityIcon2 = const Icon(
      Icons.visibility,
      size: 25,
      color: Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon2 = const Icon(
      Icons.visibility_off,
      size: 25,
      color: Color.fromARGB(255, 210, 209, 224),
    );
    visibilityIcon3 = const Icon(
      Icons.visibility,
      size: 25,
      color: Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon3 = const Icon(
      Icons.visibility_off,
      size: 25,
      color: Color.fromARGB(255, 210, 209, 224),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: localeController.initialLang,
      theme: themeController.initialTheme,
      home: Scaffold(
        appBar: AppBar(title: Text("Change Password".tr), centerTitle: true),
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
          },
          child: ListView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.all(20)),
                  Center(
                    child: Image.asset(
                      ImageAssets.AppIcon,
                      width: 220,
                      height: 220,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            height: 80,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: TextFormField(
                              controller: oldPasswordController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              cursorColor: const Color.fromARGB(
                                255,
                                254,
                                233,
                                204,
                              ),
                              maxLength: 35,
                              obscureText: TextAsAsterisks3,
                              obscuringCharacter: '*',
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 30,
                                ),
                                prefixIconColor: const Color.fromARGB(
                                  255,
                                  210,
                                  209,
                                  224,
                                ),
                                hintText: "Old Password".tr,
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    210,
                                    209,
                                    224,
                                  ),
                                ),
                                suffix: IconButton(
                                  onPressed: () {
                                    TextAsAsterisks3 = !TextAsAsterisks3;
                                    temp = visibilityIcon3;
                                    visibilityIcon3 = invisibilityIcon3;
                                    invisibilityIcon3 = temp;

                                    setState(() {});
                                  },
                                  icon: visibilityIcon3,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 210, 209, 224),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 23, 7),
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 255, 23, 7),
                                  ),
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Please enter your OLD Password".tr;
                                } else {
                                  if (val.length < 8) {
                                    return "Password must be at least 8 characters"
                                        .tr;
                                  }
                                  return null;
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 80,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: TextFormField(
                              controller: passwordController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              cursorColor: const Color.fromARGB(
                                255,
                                254,
                                233,
                                204,
                              ),
                              maxLength: 35,
                              obscureText: TextAsAsterisks1,
                              obscuringCharacter: '*',
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 30,
                                ),
                                prefixIconColor: const Color.fromARGB(
                                  255,
                                  210,
                                  209,
                                  224,
                                ),
                                hintText: "New Password".tr,
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    210,
                                    209,
                                    224,
                                  ),
                                ),
                                suffix: IconButton(
                                  onPressed: () {
                                    TextAsAsterisks1 = !TextAsAsterisks1;
                                    temp = visibilityIcon1;
                                    visibilityIcon1 = invisibilityIcon1;
                                    invisibilityIcon1 = temp;

                                    setState(() {});
                                  },
                                  icon: visibilityIcon1,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 210, 209, 224),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 23, 7),
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 255, 23, 7),
                                  ),
                                ),
                              ),
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Please enter a New Password".tr;
                                } else {
                                  if (val.length < 8) {
                                    return "Password must be at least 8 characters"
                                        .tr;
                                  }
                                  return null;
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 80,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: TextFormField(
                              controller: confirmPasswordController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              cursorColor: const Color.fromARGB(
                                255,
                                254,
                                233,
                                204,
                              ),
                              maxLength: 35,
                              obscureText: TextAsAsterisks2,
                              obscuringCharacter: '*',
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 30,
                                ),
                                prefixIconColor: const Color.fromARGB(
                                  255,
                                  210,
                                  209,
                                  224,
                                ),
                                hintText: "Confirm Password".tr,
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 210, 209, 224),
                                ),
                                suffix: IconButton(
                                  onPressed: () {
                                    TextAsAsterisks2 = !TextAsAsterisks2;
                                    temp = visibilityIcon2;
                                    visibilityIcon2 = invisibilityIcon2;
                                    invisibilityIcon2 = temp;

                                    setState(() {});
                                  },
                                  icon: visibilityIcon2,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 40, 41, 61),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 210, 209, 224),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 255, 23, 7),
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 255, 23, 7),
                                  ),
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please confirm your new password".tr;
                                }
                                if (val != passwordController.text) {
                                  return "Passwords do not match".tr;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 60),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              alignment: Alignment.center,
                              width: Get.width / 2.5,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: MaterialButton(
                                onPressed: () async {
                                  await networkController
                                      .checkConnectivityManually();
                                  isConnected = sharedPrefs.prefs.getBool(
                                    'isConnected',
                                  );
                                  if (isConnected == true) {
                                    if (formKey.currentState!.validate()) {
                                      changePasswordData();

                                      success = sharedPrefs.prefs.getString(
                                        'success',
                                      );

                                      if (success == "true") {
                                        Future.microtask(() {
                                          sendLogOutData();
                                          Future.microtask(() {
                                            setState(() {
                                              Get.offAll(() => SignUp());
                                            });
                                          });
                                        });
                                      } else {
                                        Get.snackbar(
                                          "Password changing failed".tr,
                                          "Old password is not correct".tr,
                                        );
                                      }
                                    } else {
                                      Get.snackbar(
                                        "Connection error".tr,
                                        "Password changing failed, connection access is needed"
                                            .tr,
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      "Connection error".tr,
                                      "Connection access is needed".tr,
                                    );
                                  }
                                  // } else {
                                  //   Get.snackbar("Error".tr,
                                  //       "failed to change the password".tr);
                                  // }
                                },
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                minWidth: Get.width / 2.5,
                                height: 35,
                                elevation: 5,
                                child: Text(
                                  "Confirm".tr,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 46, 48, 97),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

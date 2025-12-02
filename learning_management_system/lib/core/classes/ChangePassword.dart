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
import '../../controller/ProfileController.dart';
import '../constants/FontGlobals.dart';

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

  var TextAsAsterisks1 = true;
  var TextAsAsterisks2 = true;
  var TextAsAsterisks3 = true;
  late Widget visibilityIcon1;
  late Widget invisibilityIcon1;
  late Widget visibilityIcon2;
  late Widget invisibilityIcon2;
  late Widget visibilityIcon3;
  late Widget invisibilityIcon3;
  late Widget temp;
  String? success;
  bool? isConnected;
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    TextAsAsterisks1 = true;
    TextAsAsterisks2 = true;
    TextAsAsterisks3 = true;
    visibilityIcon1 = Icon(
      Icons.visibility,
      size: 25,
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon1 = Icon(
      Icons.visibility_off,
      size: 25,
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
    );
    visibilityIcon2 = Icon(
      Icons.visibility,
      size: 25,
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon2 = Icon(
      Icons.visibility_off,
      size: 25,
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
    );
    visibilityIcon3 = Icon(
      Icons.visibility,
      size: 25,
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon3 = Icon(
      Icons.visibility_off,
      size: 25,
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? const Color.fromARGB(255, 210, 209, 224)
              : const Color.fromARGB(255, 40, 41, 61),
    );
    super.initState();
  }

  Future<Map<String, dynamic>?> changePasswordData() async {
    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.".tr);
        });
        return null;
      }

      if (oldPasswordController.text.isEmpty ||
          passwordController.text.isEmpty) {
        showErrorSnackbar("Both old and new passwords are required".tr);
        return null;
      }

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/changepassword';

      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
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
      messageText: Text(
        message,
        style: TextStyle(fontFamily: globalFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green[800]!,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: TextStyle(fontFamily: globalFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = themeController.initialTheme == Themes.customLightTheme;
    final Color bgColor =
        isDark
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color fgColor =
        isDark
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Container(
          color: bgColor,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 30),
                height: 100,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back, color: fgColor),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: Get.width / 8),
                          child: Text(
                            "Change Password".tr,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontFamily: globalFontFamily,
                              color: fgColor,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 23
                                      : 23 - (globalFontSizeChange / 5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: fgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(30)),
                      Center(
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: ClipOval(
                            child: Image.asset(
                              SharedPrefs.instance.prefs.getString(
                                    "CurrentAvatar",
                                  ) ??
                                  ImageAssets.AppIcon,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.all(20)),
                      Container(
                        width: Get.width,
                        alignment: Alignment.center,
                        child: Card(
                          color: bgColor,
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Container(
                                  height: 80,
                                  padding: const EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                  ),
                                  child: TextFormField(
                                    controller: oldPasswordController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    cursorColor: fgColor,
                                    maxLength: 35,
                                    obscureText: TextAsAsterisks3,
                                    obscuringCharacter: '*',
                                    keyboardType: TextInputType.visiblePassword,
                                    style: TextStyle(color: fgColor),
                                    decoration: InputDecoration(
                                      helperStyle: TextStyle(
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 30,
                                      ),
                                      prefixIconColor: fgColor,
                                      hintText: "Old Password".tr,
                                      hintStyle: TextStyle(color: fgColor),
                                      suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            TextAsAsterisks3 =
                                                !TextAsAsterisks3;
                                          });
                                        },
                                        icon:
                                            TextAsAsterisks3
                                                ? visibilityIcon3
                                                : invisibilityIcon3,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: fgColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: fgColor),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            23,
                                            7,
                                          ),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            23,
                                            7,
                                          ),
                                        ),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Please enter your OLD Password"
                                            .tr;
                                      } else {
                                        if (val.length < 8) {
                                          return "Password must be at least 8 characters"
                                              .tr;
                                        }
                                        if (val == passwordController.text) {
                                          return "Old and New Passwords must not match"
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
                                  padding: const EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                  ),
                                  child: TextFormField(
                                    controller: passwordController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    cursorColor: fgColor,
                                    maxLength: 35,
                                    obscureText: TextAsAsterisks1,
                                    obscuringCharacter: '*',
                                    keyboardType: TextInputType.visiblePassword,
                                    style: TextStyle(color: fgColor),
                                    decoration: InputDecoration(
                                      helperStyle: TextStyle(
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 30,
                                      ),
                                      prefixIconColor: fgColor,
                                      hintText: "New Password".tr,
                                      hintStyle: TextStyle(color: fgColor),
                                      suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            TextAsAsterisks1 =
                                                !TextAsAsterisks1;
                                          });
                                        },
                                        icon:
                                            TextAsAsterisks1
                                                ? visibilityIcon1
                                                : invisibilityIcon1,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: fgColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: fgColor),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            23,
                                            7,
                                          ),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            23,
                                            7,
                                          ),
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
                                        if (val == oldPasswordController.text) {
                                          return "Old and New Passwords must not match"
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
                                  padding: const EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                  ),
                                  child: TextFormField(
                                    controller: confirmPasswordController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    cursorColor: fgColor,
                                    maxLength: 35,
                                    obscureText: TextAsAsterisks2,
                                    obscuringCharacter: '*',
                                    keyboardType: TextInputType.visiblePassword,
                                    style: TextStyle(color: fgColor),
                                    decoration: InputDecoration(
                                      helperStyle: TextStyle(
                                        color:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  210,
                                                  209,
                                                  224,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 30,
                                      ),
                                      prefixIconColor: fgColor,
                                      hintText: "Confirm Password".tr,
                                      hintStyle: TextStyle(color: fgColor),
                                      suffix: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            TextAsAsterisks2 =
                                                !TextAsAsterisks2;
                                          });
                                        },
                                        icon:
                                            TextAsAsterisks2
                                                ? visibilityIcon2
                                                : invisibilityIcon2,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: fgColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: BorderSide(color: fgColor),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            23,
                                            7,
                                          ),
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            23,
                                            7,
                                          ),
                                        ),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please confirm your new password"
                                            .tr;
                                      }
                                      if (val != passwordController.text) {
                                        return "Passwords do not match".tr;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
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
                                          if (formKey.currentState!
                                              .validate()) {
                                            changePasswordData();
                                            success = sharedPrefs.prefs
                                                .getString('success');

                                            if (success == "true") {
                                              Future.microtask(() {
                                                setState(() {
                                                  Get.offAll(() => SignUp());
                                                });
                                              });
                                            } else {
                                              Get.snackbar(
                                                "Password changing failed".tr,
                                                "Old password is not correct"
                                                    .tr,
                                              );
                                            }
                                          }
                                        } else {
                                          Get.snackbar(
                                            "Connection error".tr,
                                            "Connection access is needed".tr,
                                          );
                                        }
                                      },
                                      color: fgColor,
                                      minWidth: Get.width / 2.5,
                                      height: 35,
                                      elevation: 5,
                                      child: Text(
                                        "Confirm".tr,
                                        style: TextStyle(
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      20
                                                  : 20 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontFamily: globalFontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: bgColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
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

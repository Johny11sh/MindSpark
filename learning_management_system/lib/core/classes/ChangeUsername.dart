// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/ProfileController.dart';
import '../../controller/NetworkController.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../../view/Profile.dart';
import '../../controller/FontController.dart';
import '../constants/ImageAssets.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});

  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final ProfileController profileController = Get.find<ProfileController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final TextEditingController userNameController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  bool? isConnected;
  String? success;

  Future<Map<String, dynamic>?> changeUsernameData() async {
    try {
      final token =
          profileController.sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAll(() => LogIn());
          showErrorSnackbar("Session expired. Please log in again.".tr);
        });
        return null;
      }

      final newUsername = userNameController.text.trim();

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/changeusername';

      final response = await http
          .put(
            Uri.parse(APIurl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: jsonEncode({'userName': newUsername}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
        "Change Username Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        success = responseBody['success'];

        await profileController.sharedPrefs.prefs.setString(
          'success',
          success!,
        );

        if (responseBody['token'] != null) {
          await profileController.sharedPrefs.prefs.setString(
            'token',
            responseBody['token'],
          );
        }
        await profileController.getProfileData();

        showSuccessSnackbar("Username changed successfully".tr);
        return responseBody;
      } else if (response.statusCode == 409) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        success = responseBody['success'];

        await profileController.sharedPrefs.prefs.setString(
          'success',
          success!,
        );
        showErrorSnackbar("Username already taken".tr);
      } else if (response.statusCode == 401) {
        showErrorSnackbar("Session expired. Please log in again".tr);
      } else if (response.statusCode == 400) {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Invalid request'.tr;
        showErrorSnackbar(errorMessage);
      } else {
        throw Exception("Username change failed: ${response.statusCode}".tr);
      }
    } on TimeoutException {
      showErrorSnackbar("Request timeout. Please try again.".tr);
    } on http.ClientException catch (e) {
      showErrorSnackbar("Network error. Please check your connection.".tr);
      debugPrint("Network error: ${e.message}");
    } catch (e) {
      showErrorSnackbar("Failed to change username".tr);
      debugPrint("Error changing username: $e");
    }
    return null;
  }

  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: TextStyle(fontFamily: FontController().currentFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red[800]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  void showSuccessSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(
        message,
        style: TextStyle(fontFamily: FontController().currentFontFamily),
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green[800]!,
      icon: const Icon(Icons.check_circle, color: Colors.white),
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

    return Scaffold(
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
                          "Change Username".tr,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(
                            fontFamily: FontController().currentFontFamily,
                            color: fgColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 23,
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
                      child: Image.asset(
                        ImageAssets.AppLogo,
                        width: 180,
                        height: 180,
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
                                  controller: userNameController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  cursorColor: fgColor,
                                  obscureText: false,
                                  keyboardType: TextInputType.name,
                                  style: TextStyle(color: fgColor),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.perm_identity,
                                      size: 30,
                                    ),
                                    prefixIconColor: fgColor,
                                    hintText: "New Username".tr,
                                    hintStyle: TextStyle(color: fgColor),
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
                                      return "Please enter your User Name".tr;
                                    } else {
                                      if (val.length < 3) {
                                        return "User Name must be longer than 3 characters"
                                            .tr;
                                      } else if (val.length > 25) {
                                        return "User Name must be shorter than 25 characters"
                                            .tr;
                                      }
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
                                      isConnected = profileController
                                          .sharedPrefs
                                          .prefs
                                          .getBool('isConnected');
                                      if (isConnected == true) {
                                        if (formKey.currentState!.validate()) {
                                          changeUsernameData();
                                          success = profileController
                                              .sharedPrefs
                                              .prefs
                                              .getString('success');

                                          if (success == "true") {
                                            Future.microtask(() {
                                              setState(() {
                                                Get.offAll(() => Profile());
                                              });
                                            });
                                          } else {
                                            Get.snackbar(
                                              "Username changing failed".tr,
                                              "This username is already taken"
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
                                    color: bgColor,
                                    minWidth: Get.width / 2.5,
                                    height: 35,
                                    elevation: 5,
                                    child: Text(
                                      "Confirm".tr,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            FontController().currentFontFamily,
                                        fontStyle: FontStyle.normal,
                                        color: fgColor,
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
    );
  }
}

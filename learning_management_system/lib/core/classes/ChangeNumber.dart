// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../controller/NetworkController.dart';
import '../../controller/ProfileController.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../view/LogIn.dart';
import '../../view/NavBar.dart';
import '../../view/Profile.dart';
import '../../controller/FontController.dart';
import '../constants/ImageAssets.dart';

class ChangeNumber extends StatefulWidget {
  const ChangeNumber({super.key});

  @override
  State<ChangeNumber> createState() => _ChangeNumberState();
}

class _ChangeNumberState extends State<ChangeNumber> {
  @override
  Widget build(BuildContext context) {
    final NetworkController networkController = Get.find<NetworkController>();
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    final TextEditingController oldNumberController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

    bool? isConnected;
    String? success;

    GlobalKey<FormState> formKey = GlobalKey();

    final bool isDark = themeController.initialTheme == Themes.customLightTheme;
    final Color bgColor =
        isDark
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color fgColor =
        isDark
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

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

    Future<Map<String, dynamic>?> changeNumberData() async {
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

        var baseUrl = String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: mainIP,
        );
        final APIurl = '$baseUrl/api/changenumber';

        final response = await http
            .put(
              Uri.parse(APIurl),
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
              body: jsonEncode({'number': numberController.text.trim()}),
            )
            .timeout(const Duration(seconds: 15));

        debugPrint(
          "Change Number Response: ${response.statusCode} - ${response.body}",
        );

        if (response.statusCode == 200) {
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;
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

          showSuccessSnackbar("Number changed successfully".tr);
          return responseBody;
        } else if (response.statusCode == 409) {
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;
          success = responseBody['success'];

          await profileController.sharedPrefs.prefs.setString(
            'success',
            success!,
          );
          showErrorSnackbar("Number already taken".tr);
        } else if (response.statusCode == 401) {
          showErrorSnackbar("Session expired. Please log in again".tr);
        } else if (response.statusCode == 400) {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ?? 'Invalid request'.tr;
          showErrorSnackbar(errorMessage);
        } else {
          throw Exception("Number change failed: ${response.statusCode}".tr);
        }
      } on TimeoutException {
        showErrorSnackbar("Request timeout. Please try again.".tr);
      } on http.ClientException catch (e) {
        showErrorSnackbar("Network error. Please check your connection.".tr);
        debugPrint("Network error: ${e.message}");
      } catch (e) {
        showErrorSnackbar("Failed to change Number".tr);
        debugPrint("Error changing Number: $e");
      }
      return null;
    }

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
                          "Change Number".tr,
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
                                  style: TextStyle(color: fgColor),
                                  controller: numberController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  cursorColor: fgColor,
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.phone,
                                      size: 30,
                                    ),
                                    prefixIconColor: fgColor,
                                    hintText: "New Number".tr,
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
                                      return "Please enter your Phone Number"
                                          .tr;
                                    } else {
                                      if (val.length < 10 || val.length > 10) {
                                        return "Phone Number must be 10 digits"
                                            .tr;
                                      } else if (!val.startsWith('09')) {
                                        return "Phone Number must be : 09XXXXXXXX"
                                            .tr;
                                      } else if (val.hashCode.isNaN) {
                                        return "Phone Number must ONLY contain numbers"
                                            .tr;
                                      }
                                      return null;
                                    }
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
                                          changeNumberData();
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
                                              "Number changing failed".tr,
                                              "This Number is already taken".tr,
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
                                        fontFamily:
                                            FontController().currentFontFamily,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
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

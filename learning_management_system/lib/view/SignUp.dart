// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../themes/ThemeController.dart';
import 'OnBoarding.dart';
import 'NavBar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  var TextAsAsterisks1;
  var TextAsAsterisks2;
  late Widget visibilityIcon1;
  late Widget invisibilityIcon1;
  late Widget visibilityIcon2;
  late Widget invisibilityIcon2;
  bool? isConnected;
  late Widget temp;

  Future<Map<String, dynamic>?> sendSignUpData() async {
    // Use configurable base URL (should be in a config file)
    final baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://192.168.1.7:8000',
    );
    final APIurl = '$baseUrl/api/register';

    try {
      // Input validation
      final userName = userNameController.text.trim();
      final number = numberController.text.trim().replaceFirst(
        RegExp(r'0'),
        '',
      );
      final password = passwordController.text.trim();

      if (userName.isEmpty || number.isEmpty || password.isEmpty) {
        showErrorSnackbar('All fields are required'.tr);
        return null;
      }

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'userName': userName, 'number': number, 'password': password,
              // 'deviceId': deviceID
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('SignUp Response: ${response.statusCode} - ${response.body}');

      switch (response.statusCode) {
        case 200:
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;

          if (responseBody['token'] == null) {
            throw Exception('Token missing in response');
          }

          await sharedPrefs.prefs.setString('token', responseBody['token']);
          await sharedPrefs.prefs.setBool('isLoggedIn', true);

          return responseBody;

        case 422:
          final responseBody =
              jsonDecode(response.body) as Map<String, dynamic>;
          final errors = responseBody['errors'] ?? {};

          if (errors['userName'] != null && errors['number'] != null) {
            showErrorSnackbar('Username and number are already taken'.tr);
          } else if (errors['userName'] != null) {
            showErrorSnackbar('Username is already taken'.tr);
          } else if (errors['number'] != null) {
            showErrorSnackbar('Number is already taken'.tr);
          } else {
            showErrorSnackbar(
              'Validation failed: ${errors.values.join(', ')}'.tr,
            );
          }
          return null;

        default:
          showErrorSnackbar('Server error (${response.statusCode})'.tr);
          return null;
      }
    } on TimeoutException {
      showErrorSnackbar('Request timeout. Please try again.'.tr);
    } on http.ClientException catch (e) {
      showErrorSnackbar('Network error: ${e.message}'.tr);
    } on FormatException {
      showErrorSnackbar('Invalid server response'.tr);
    } catch (e) {
      showErrorSnackbar('An unexpected error occurred'.tr);
      print('SignUp Error: $e'.tr);
    }
    return null;
  }

  // Reusable snackbar method
  void showErrorSnackbar(String message) {
    Get.rawSnackbar(
      messageText: Text(message.tr),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: const Color.fromARGB(255, 210, 209, 224),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 35,
      ),
      margin: const EdgeInsets.all(5),
      borderRadius: 5,
      borderColor: const Color.fromARGB(255, 103, 103, 103),
    );
  }

  @override
  void initState() {
    TextAsAsterisks1 = true;
    TextAsAsterisks2 = true;
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LocaleController localeController = Get.put(LocaleController());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: localeController.initialLang,
      home: Scaffold(
        body: Container(
          width: Get.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 40, 41, 61),
                Color.fromARGB(255, 210, 209, 224),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: ListView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.all(30)),
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      child: Image.asset(
                        ImageAssets.AppIcon,
                        width: 220,
                        height: 220,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  Text(
                    "Sign Up".tr,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 40, 41, 61),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                          Container(
                            height: 80,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: TextFormField(
                              controller: userNameController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              cursorColor: const Color.fromARGB(
                                255,
                                254,
                                233,
                                204,
                              ),
                              obscureText: false,
                              keyboardType: TextInputType.name,
                              // onSaved: (val){username = val;},
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.perm_identity,
                                  size: 30,
                                ),
                                prefixIconColor: const Color.fromARGB(
                                  255,
                                  210,
                                  209,
                                  224,
                                ),
                                hintText: "User Name".tr,
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    210,
                                    209,
                                    224,
                                  ),
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
                                  return "Please enter A User Name".tr;
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
                          const SizedBox(height: 10),
                          Container(
                            height: 80,
                            padding: const EdgeInsets.only(right: 20, left: 20),
                            child: TextFormField(
                              controller: numberController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              cursorColor: const Color.fromARGB(
                                255,
                                254,
                                233,
                                204,
                              ),
                              obscureText: false,
                              keyboardType: TextInputType.number,
                              // onSaved: (val){phoneNumber = val;},
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.phone, size: 30),
                                prefixIconColor: const Color.fromARGB(
                                  255,
                                  210,
                                  209,
                                  224,
                                ),
                                hintText: "Number".tr,
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    210,
                                    209,
                                    224,
                                  ),
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
                                  return "Please enter your Phone Number".tr;
                                } else {
                                  if (val.length < 10 || val.length > 10) {
                                    return "Phone Number must be 10 digits".tr;
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
                          const SizedBox(height: 10),
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
                                hintText: "Password".tr,
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
                                  return "Please enter A Password".tr;
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
                          const SizedBox(height: 10),
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
                                  return "Please confirm your password".tr;
                                }
                                if (val != passwordController.text) {
                                  return "Passwords do not match".tr;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

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
                                      sendSignUpData();
                                      await Future.delayed(
                                        Duration(milliseconds: 1000),
                                      );

                                      Future.microtask(() {
                                        Get.offAll(() => NavBar());
                                      });
                                    } else {
                                      Get.snackbar(
                                        "Validation Error".tr,
                                        "Sign up failed, fill the textfields correctly"
                                            .tr,
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      "Connection error".tr,
                                      "Connection access is needed".tr,
                                    );
                                  }
                                },
                                color: Color.fromARGB(255, 40, 41, 61),
                                minWidth: Get.width / 2.5,
                                height: 35,
                                elevation: 5,
                                child: Text(
                                  "Sign Up".tr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    color: Color.fromARGB(255, 153, 151, 188),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?".tr,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.toNamed(
                                    "/LogIn",
                                    // arguments:{"locale" : "${localeController.initialLang}"}
                                  );
                                },
                                child: Text(
                                  "Log In".tr,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 40, 41, 61),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
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

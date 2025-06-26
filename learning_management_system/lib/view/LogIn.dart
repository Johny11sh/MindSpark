// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import 'NavBar.dart';
import 'OnBoarding.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  final NetworkController networkController = Get.find<NetworkController>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();

  var TextAsAsterisks;
  late Widget visibilityIcon;
  bool? isConnected;
  late Widget invisibilityIcon;
  late Widget temp;
  String supportTeamWhatsApp = "";
  String supportTeamTelegram = "";

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<Map<String, dynamic>?> sendLogInData() async {
    try {
      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = "$baseUrl/api/login";
      print(                                         APIurl);

      if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
        Get.snackbar("Error".tr, "Username and password are required".tr);
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
              'userName': userNameController.text.trim(),
              'password': passwordController.text.trim(),
              // 'deviceId': deviceID
            }),
          )
          .timeout(const Duration(seconds: 30));

      print("\nStatus Code: ${response.statusCode}\nBody: ${response.body}\n");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseBody['token'] == null) {
          throw Exception('Token not found in response');
        }

        final String token = responseBody['token'];

        await sharedPrefs.prefs.setString('token', token);
        await sharedPrefs.prefs.setString('userName', responseBody["user"]['userName']);
        await sharedPrefs.prefs.setBool('isLoggedIn', true);

        final savedToken = sharedPrefs.prefs.getString('token');
        print("Saved Token: $savedToken\n"); // Fixed print statement

        return responseBody;
      } else if (response.statusCode == 401) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        sharedPrefs.prefs.setString('reason', responseBody['reason']);
        if (sharedPrefs.prefs.getString('reason') == "Banned") {
          Get.snackbar(
            "Banned Account!".tr,
            "Contact the support team to restore this account.".tr,
          );
        } else if (sharedPrefs.prefs.getString('reason') ==
            "Invalid Credentials") {
          Get.snackbar(
            "Invalid Credentials".tr,
            "Please check your username and password".tr,
          );
        }
      } else {
        final errorResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage =
            errorResponse['message'] ?? 'Unknown error occurred'.tr;
        Get.snackbar("Error (${response.statusCode})", errorMessage);
      }
    } on http.ClientException catch (e) {
      print("Network error: ${e.message}");
      Get.snackbar(
        "Network Error".tr,
        "Could not connect to the server. Please check your connection.".tr,
      );
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Timeout".tr,
        "The request took too long. Please try again.".tr,
      );
    } on FormatException catch (_) {
      Get.snackbar("Error".tr, "Invalid server response".tr);
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar("Error".tr, "An unexpected error occurred".tr);
    }

    return null;
  }

  @override
  void initState() {
    TextAsAsterisks = true;
    visibilityIcon = const Icon(
      Icons.visibility,
      size: 25,
      color: Color.fromARGB(255, 40, 41, 61),
    );
    invisibilityIcon = const Icon(
      Icons.visibility_off,
      size: 25,
      color: Color.fromARGB(255, 210, 209, 224),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
                        ImageAssets.AppLogo,
                        width: 220,
                        height: 220,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(20)),
                  Text(
                    "Log In".tr,
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
                              obscureText: TextAsAsterisks,
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
                                    TextAsAsterisks = !TextAsAsterisks;
                                    temp = visibilityIcon;
                                    visibilityIcon = invisibilityIcon;
                                    invisibilityIcon = temp;

                                    setState(() {});
                                  },
                                  icon: visibilityIcon,
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
                                  return "Please enter your Password".tr;
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
                                    sendLogInData();
                                    await Future.delayed(
                                      Duration(milliseconds: 2000),
                                    );

                                    Future.microtask(() {
                                      Get.offAll(() => NavBar());
                                    });
                                  } else {
                                    Get.snackbar(
                                      "Validation Error".tr,
                                      "Log In failed, fill the textfields correctly"
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
                                "Log In".tr,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: Color.fromARGB(255, 153, 151, 188),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?".tr,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.toNamed("/SignUp");
                                },
                                child: Text(
                                  "Sign Up".tr,
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
                          SizedBox(height: 20),
                          Text(
                            "Support team".tr,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 40, 41, 61),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: TextButton(
                                  onPressed: () async {
                                    _launchURL(supportTeamWhatsApp);
                                  },
                                  child: Text(
                                    "WhatsApp".tr,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 210, 209, 224),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color.fromARGB(
                                        255,
                                        210,
                                        209,
                                        224,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: TextButton(
                                  onPressed: () async {
                                    _launchURL(supportTeamTelegram);
                                  },
                                  child: Text(
                                    "Telegram".tr,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 210, 209, 224),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color.fromARGB(
                                        255,
                                        210,
                                        209,
                                        224,
                                      ),
                                    ),
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

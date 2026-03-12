// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../controller/NetworkController.dart';
import '../core/classes/PrivacyPolicy.dart';
import '../core/classes/TermsOfService.dart';
import '../core/constants/FontGlobals.dart';
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
  int index = 0;

  List availableLanguages = [
    {"name": "English", "LangCode": "En", "flag": ImageAssets.EnglishFlag},
    {"name": "Arabic", "LangCode": "Ar", "flag": ImageAssets.ArabicFlag},
    {"name": "German", "LangCode": "De", "flag": ImageAssets.GermanFlag},
    {"name": "Spanish", "LangCode": "Es", "flag": ImageAssets.SpanishFlag},
    {"name": "French", "LangCode": "Fr", "flag": ImageAssets.FrenchFlag},
  ];
  bool isListExpanded = false;

  Future<Map<String, dynamic>?> sendSignUpData() async {
    // Use configurable base URL (should be in a config file)
    var baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: mainIP);
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
          await sharedPrefs.prefs.setInt('user_id', responseBody["user"]["id"]);
          await sharedPrefs.prefs.setBool('isLoggedIn', true);

          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await http.post(
              Uri.parse("$baseUrl/api/set_fcm_token"),
              headers: {
                "Authorization": "Bearer ${responseBody['token']}",
                "Content-Type": "application/json",
              },
              body: jsonEncode({"fcm_token": fcmToken}),
            );
            print(" Sent FCM token to backend: $fcmToken");
          }

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
      color: Color.fromARGB(255, 210, 209, 224),
    );
    invisibilityIcon1 = const Icon(
      Icons.visibility_off,
      size: 25,
      color: Color.fromARGB(255, 210, 209, 224),
    );
    visibilityIcon2 = const Icon(
      Icons.visibility,
      size: 25,
      color: Color.fromARGB(255, 210, 209, 224),
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

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: localeController.initialLang,
        home: Scaffold(
          body: Container(
            width: Get.width,

            color: Color.fromARGB(255, 210, 209, 224),
            child: ListView(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.all(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            Get.to(() => OnBoarding());
                          },
                          icon: Icon(
                            Icons.arrow_back_outlined,
                            size: 35,
                            color: Color.fromARGB(255, 40, 41, 61),
                          ),
                        ),
                        SizedBox(width: Get.width / 10),
                        Text(
                              "Create New Account".tr,
                              style: TextStyle(
                                color: Color.fromARGB(255, 40, 41, 61),
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 22
                                        : 22 - (globalFontSizeChange / 5),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            .animate(onPlay: (controller) => controller.loop())
                            .shimmer(
                              delay: Duration(seconds: 4),
                              duration: 800.ms,
                              color: Colors.white54,
                            ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(10)),

                    Container(
                      width: Get.width,
                      height: Get.height * 1.2,

                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 40, 41, 61),

                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(padding: const EdgeInsets.all(20)),
                          Center(
                            child: Image.asset(
                              ImageAssets.AppIconNoBackGround,
                              width: 140,
                              height: 140,
                            ),
                          ),
                          Padding(padding: const EdgeInsets.all(20)),

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
                                    padding: const EdgeInsets.only(
                                      right: 20,
                                      left: 20,
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            width: 2,
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                    padding: const EdgeInsets.only(
                                      right: 20,
                                      left: 20,
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
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
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          size: 30,
                                        ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            width: 2,
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                          return "Please enter your Phone Number"
                                              .tr;
                                        } else {
                                          if (val.length < 10 ||
                                              val.length > 10) {
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
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 80,
                                    padding: const EdgeInsets.only(
                                      right: 20,
                                      left: 20,
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
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
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      decoration: InputDecoration(
                                        helperStyle: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            210,
                                            209,
                                            224,
                                          ),
                                        ),
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
                                            TextAsAsterisks1 =
                                                !TextAsAsterisks1;
                                            temp = visibilityIcon1;
                                            visibilityIcon1 = invisibilityIcon1;
                                            invisibilityIcon1 = temp;

                                            setState(() {});
                                          },
                                          icon: visibilityIcon1,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            width: 2,
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                    padding: const EdgeInsets.only(
                                      right: 20,
                                      left: 20,
                                    ),
                                    child: TextFormField(
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                      ),
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
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      decoration: InputDecoration(
                                        helperStyle: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            210,
                                            209,
                                            224,
                                          ),
                                        ),
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
                                          color: Color.fromARGB(
                                            255,
                                            210,
                                            209,
                                            224,
                                          ),
                                        ),
                                        suffix: IconButton(
                                          onPressed: () {
                                            TextAsAsterisks2 =
                                                !TextAsAsterisks2;
                                            temp = visibilityIcon2;
                                            visibilityIcon2 = invisibilityIcon2;
                                            invisibilityIcon2 = temp;

                                            setState(() {});
                                          },
                                          icon: visibilityIcon2,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            width: 2,
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                          return "Please confirm your password"
                                              .tr;
                                        }
                                        if (val != passwordController.text) {
                                          return "Passwords do not match".tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  StatefulBuilder(
                                    builder: (context, setDState) {
                                      return PopupMenuButton(
                                        color: Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                        child: Container(
                                          width: Get.width / 1.2,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),

                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),

                                          child: ListTile(
                                            trailing: CircleAvatar(
                                              backgroundColor: Color.fromARGB(
                                                0,
                                                0,
                                                0,
                                                0,
                                              ),
                                              child: Image.asset(
                                                availableLanguages[index]["flag"]!,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            title: Text(
                                              textAlign: TextAlign.center,
                                              "Language".tr,
                                              style: TextStyle(
                                                fontFamily: globalFontFamily,
                                                color: Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                                fontSize:
                                                    globalFontSizeChange >= 17
                                                        ? (globalFontSizeChange /
                                                                5) +
                                                            18
                                                        : 18 -
                                                            (globalFontSizeChange /
                                                                5),
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            subtitle: Text(
                                              textAlign: TextAlign.center,
                                              "Choose a language".tr,
                                              style: TextStyle(
                                                fontFamily: globalFontFamily,
                                                color: Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
                                                fontSize:
                                                    globalFontSizeChange >= 17
                                                        ? (globalFontSizeChange /
                                                                5) +
                                                            16
                                                        : 16 -
                                                            (globalFontSizeChange /
                                                                5),
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                        ),
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                onTap: () {
                                                  setDState(() {
                                                    index = 0;
                                                    availableLanguages[index]["LangCode"] =
                                                        "En";
                                                    localeController.changeLang(
                                                      availableLanguages[index]['LangCode'],
                                                    );
                                                  });
                                                },
                                                value: 'English',
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      child: Image.asset(
                                                        availableLanguages[0]["flag"]!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Text(
                                                      "English".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        color: Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        ),
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    14
                                                                : 14 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                onTap: () {
                                                  setDState(() {
                                                    index = 1;
                                                    availableLanguages[index]["LangCode"] =
                                                        "Ar";
                                                    localeController.changeLang(
                                                      availableLanguages[index]['LangCode'],
                                                    );
                                                  });
                                                },
                                                value: 'Arabic',
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      child: Image.asset(
                                                        availableLanguages[1]["flag"]!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Text(
                                                      "Arabic".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        color: Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        ),
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    14
                                                                : 14 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                onTap: () {
                                                  setDState(() {
                                                    index = 2;
                                                    availableLanguages[index]["LangCode"] =
                                                        "De";
                                                    localeController.changeLang(
                                                      availableLanguages[index]['LangCode'],
                                                    );
                                                  });
                                                },
                                                value: 'German',
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      child: Image.asset(
                                                        availableLanguages[2]["flag"]!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Text(
                                                      "German".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        color: Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        ),
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    14
                                                                : 14 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                onTap: () {
                                                  setDState(() {
                                                    index = 3;
                                                    availableLanguages[index]["LangCode"] =
                                                        "Es";
                                                    localeController.changeLang(
                                                      availableLanguages[index]['LangCode'],
                                                    );
                                                  });
                                                },
                                                value: 'Spanish',
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      child: Image.asset(
                                                        availableLanguages[3]["flag"]!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Text(
                                                      "Spanish".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        color: Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        ),
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    14
                                                                : 14 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                onTap: () {
                                                  setDState(() {
                                                    index = 4;
                                                    availableLanguages[index]["LangCode"] =
                                                        "Fr";
                                                    localeController.changeLang(
                                                      availableLanguages[index]['LangCode'],
                                                    );
                                                  });
                                                },
                                                value: 'French',
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      child: Image.asset(
                                                        availableLanguages[4]["flag"]!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30),
                                                    Text(
                                                      "French".tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        color: Color.fromARGB(
                                                          255,
                                                          40,
                                                          41,
                                                          61,
                                                        ),
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    14
                                                                : 14 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: Get.width / 1.5,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          await networkController
                                              .checkConnectivityManually();
                                          isConnected = sharedPrefs.prefs
                                              .getBool('isConnected');
                                          if (isConnected == true) {
                                            if (formKey.currentState!
                                                .validate()) {
                                              // Await the signup call and navigate only on success
                                              final resp =
                                                  await sendSignUpData();
                                              if (resp != null) {
                                                Future.microtask(() {
                                                  Get.offAll(() => NavBar());
                                                });
                                              } else {
                                                // sendSignUpData shows snackbars on error
                                              }
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
                                        color: Color.fromARGB(
                                          255,
                                          210,
                                          209,
                                          224,
                                        ),
                                        minWidth: Get.width / 1.5,
                                        height: 35,
                                        child: Text(
                                          "Sign Up".tr,
                                          style: TextStyle(
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        22
                                                    : 22 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            color: const Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "If you sign up, you agree to our:".tr,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 210, 209, 224),
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 18
                                              : 18 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: TextButton(
                                          onPressed: () async {
                                            Get.to(() => TermsOfService());
                                          },
                                          child: Text(
                                            "Terms of Service".tr,
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                255,
                                                254,
                                                233,
                                                204,
                                              ),
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          17
                                                      : 17 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    254,
                                                    233,
                                                    204,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        child: TextButton(
                                          onPressed: () async {
                                            Get.to(() => PrivacyPolicy());
                                          },
                                          child: Text(
                                            "Privacy Policy".tr,
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                255,
                                                254,
                                                233,
                                                204,
                                              ),
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          17
                                                      : 17 -
                                                          (globalFontSizeChange /
                                                              5),
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    254,
                                                    233,
                                                    204,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account?".tr,
                                        style: TextStyle(
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      15
                                                  : 15 -
                                                      (globalFontSizeChange /
                                                          5),
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                          color: const Color.fromARGB(
                                            255,
                                            210,
                                            209,
                                            224,
                                          ),
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
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              254,
                                              233,
                                              204,
                                            ),
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        15
                                                    : 15 -
                                                        (globalFontSizeChange /
                                                            5),
                                            fontWeight: FontWeight.w400,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color.fromARGB(
                                              255,
                                              254,
                                              233,
                                              204,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

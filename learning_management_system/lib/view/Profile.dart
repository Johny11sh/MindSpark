// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:learning_management_system/controller/ProfileController.dart';
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

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.find to avoid re-instantiating the controller
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    final NetworkController networkController = Get.find<NetworkController>();

    return Scaffold(
        body: Obx(() {
          if (profileController.isLoading.value) {
            // Show spinner for a max of 10 seconds, then show fallback
            return FutureBuilder(
              future: Future.delayed(Duration(seconds: 10)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && profileController.isLoading.value) {
                  return Center(child: Text('Loading took too long. Please check your connection and try again.'.tr));
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                  ),
                );
              },
            );
          }
          if (profileController.profileData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No profile data available.'.tr),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await networkController.checkConnectivityManually();
                      await profileController.getProfileData();
                    },
                    child: Text('Retry'.tr),
                  ),
                ],
              ),
            );
          }
          final profileData = profileController.profileData;
          return RefreshIndicator(
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
                  await profileController.getProfileData();
                },
                child: Container(
      color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 40, 41, 61)
          : Color.fromARGB(255, 210, 209, 224),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 25),
            height: 100,
            child: Center(
              child: Text(
                "Profile".tr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color:
                          themeController.initialTheme == Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61),
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Obx(() {
                if (profileController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                if (profileController.profileData.isEmpty) {
                  return Center(child: Text('No profile data available.'.tr));
                }
                final profileData = profileController.profileData;
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      ImageAssets.UserAvatar,
                      height: 130,
                      width: 130,
                    ),
                    Text(
                      profileData['userName'] ?? 'UserName',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 22,
                            color: themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
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
                            bool? isConnected = profileController.sharedPrefs.prefs.getBool(
                              'isConnected',
                            );
                            if (isConnected == true) {
                              await profileController.sendLogOutData();
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
                                color: themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Log Out".tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontSize: 20,
                                      color: themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.to(() => MyInfo());
                          },
                          icon: Icon(
                            Icons.edit,
                            color: themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                          ),
                        ),
                      ],
                    ),
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
                                color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 40, 41, 61)
          : Color.fromARGB(255, 210, 209, 224),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.format_list_numbered_outlined,
                                        size: 25,
                                        color:
                                        themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
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
                                            themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 17,
                                        color:
                                        themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
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
                                color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 40, 41, 61)
          : Color.fromARGB(255, 210, 209, 224),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.settings,
                                        size: 25,
                                        color:
                                        themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
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
                                            themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 17,
                                        color:
                                        themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
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
                                color: themeController.initialTheme == Themes.customLightTheme
          ? Color.fromARGB(255, 40, 41, 61)
          : Color.fromARGB(255, 210, 209, 224),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(
                                        Icons.help_center_outlined,
                                        size: 25,
                                        color:
                                        themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
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
                                            themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        size: 17,
                                        color:
                                        themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61)
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
                );
              }),
            ),
          ),
        ],
      ),)
  );}));
  }
}

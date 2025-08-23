// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'dart:async';
import '../core/classes/AvatarPicker.dart';
import '../controller/FontController.dart';
import '../services/SharedPrefs.dart';
import '../controller/ProfileController.dart';
import '../view/HelpCenter.dart';
import '../view/Management.dart';
import '../view/MyInfo.dart';
import '../view/Settings.dart';
import '../../core/constants/ImageAssets.dart';
import 'package:get/get.dart';
import '../controller/NetworkController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    // final LocaleController localeController = Get.find<LocaleController>();
    final NetworkController networkController = Get.find<NetworkController>();

    return Scaffold(
      body: Obx(() {
        if (profileController.isLoading.value) {
          return FutureBuilder(
            future: Future.delayed(Duration(seconds: 10)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  profileController.isLoading.value) {
                return Center(
                  child: Text(
                    'Loading took too long. Please check your connection and try again.'
                        .tr,
                    style: TextStyle(
                      fontFamily: FontController().currentFontFamily,
                    ),
                  ),
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  color:
                      themeController.initialTheme == Themes.customLightTheme
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
                Text(
                  'No profile data available.'.tr,
                  style: TextStyle(
                    fontFamily: FontController().currentFontFamily,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await networkController.checkConnectivityManually();
                    await profileController.getProfileData();
                  },
                  child: Text(
                    'Retry'.tr,
                    style: TextStyle(
                      fontFamily: FontController().currentFontFamily,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
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
            color:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 25),
                  height: 100,
                  child: Center(
                    child: Text(
                      "Profile".tr,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontFamily: FontController().currentFontFamily,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
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
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
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
                        return Center(
                          child: Text(
                            'No profile data available.'.tr,
                            style: TextStyle(
                              fontFamily: FontController().currentFontFamily,
                            ),
                          ),
                        );
                      }
                      final profileData = profileController.profileData;
                      final Color fgColor =
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 210, 209, 224)
                              : Color.fromARGB(255, 40, 41, 61);
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AvatarPicker(),
                                    ),
                                  );
                                  // Refresh the profile to show updated avatar
                                  profileController.update();
                                },
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              )
                                              : Color.fromARGB(255, 40, 41, 61),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      SharedPrefs.instance.prefs.getString(
                                            "CurrentAvatar",
                                          ) ??
                                          ImageAssets.AppIcon,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
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
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 40, 41, 61)
                                            : Color.fromARGB(
                                              255,
                                              210,
                                              209,
                                              224,
                                            ),
                                    border: Border.all(
                                      color: fgColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AvatarPicker(),
                                        ),
                                      );
                                      // Refresh the profile to show updated avatar
                                      profileController.update();
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: fgColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Text(
                            profileData['userName'] ?? 'UserName',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontFamily: FontController().currentFontFamily,
                              fontSize: 22,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sparks:',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily:
                                      FontController().currentFontFamily,
                                  fontSize: 22,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                "${profileData['sparks'].toString()}/1000",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily:
                                      FontController().currentFontFamily,
                                  fontSize: 22,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "-",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily:
                                      FontController().currentFontFamily,
                                  fontSize: 22,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Sparkies:',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily:
                                      FontController().currentFontFamily,
                                  fontSize: 22,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                "${profileData['sparkies'].toString()}/5",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily:
                                      FontController().currentFontFamily,
                                  fontSize: 22,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await networkController
                                      .checkConnectivityManually();
                                  bool? isConnected = profileController
                                      .sharedPrefs
                                      .prefs
                                      .getBool('isConnected');
                                  if (isConnected == true) {
                                    Get.dialog(
                                      AlertDialog(
                                        title: Text("Log Out"),
                                        titleTextStyle: TextStyle(
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
                                          color: Color.fromARGB(
                                            255,
                                            40,
                                            41,
                                            61,
                                          ),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20,
                                        ),
                                        content: Text('Are you sure?'),
                                        contentTextStyle: TextStyle(
                                          fontFamily:
                                              FontController()
                                                  .currentFontFamily,
                                          color: Color.fromARGB(
                                            255,
                                            40,
                                            41,
                                            61,
                                          ),
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontFamily:
                                                    FontController()
                                                        .currentFontFamily,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Get.back();
                                              await profileController
                                                  .sendLogOutData();
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                fontFamily:
                                                    FontController()
                                                        .currentFontFamily,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
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
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Log Out".tr,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!.copyWith(
                                        fontFamily:
                                            FontController().currentFontFamily,
                                        fontSize: 20,
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
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => Management());
                                    },
                                    child: Card(
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Icon(
                                              Icons
                                                  .format_list_numbered_outlined,
                                              size: 25,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
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
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Management".tr,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color:
                                                      themeController
                                                                  .initialTheme ==
                                                              Themes
                                                                  .customLightTheme
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
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
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
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Icon(
                                              Icons.settings,
                                              size: 25,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
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
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Settings".tr,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color:
                                                      themeController
                                                                  .initialTheme ==
                                                              Themes
                                                                  .customLightTheme
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
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
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
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Icon(
                                              Icons.help_center_outlined,
                                              size: 25,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
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
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Help Center".tr,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontController()
                                                          .currentFontFamily,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  color:
                                                      themeController
                                                                  .initialTheme ==
                                                              Themes
                                                                  .customLightTheme
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
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
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
            ),
          ),
        );
      }),
    );
  }
}

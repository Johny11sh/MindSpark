// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
// import '../controller/MyInfoController.dart';
import '../controller/ProfileController.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/noDataLottie.dart';
import '../themes/ThemeController.dart';
import '../services/SharedPrefs.dart';
import '../core/classes/ChangePassword.dart';
import '../core/classes/ChangeNumber.dart';
import '../core/classes/ChangeUsername.dart';
import '../core/constants/ImageAssets.dart';
import '../themes/Themes.dart';

class MyInfo extends StatelessWidget {
  const MyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Container(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 30),
                height: 100,
                // color: Colors.red,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 210, 209, 224)
                                  : Color.fromARGB(255, 40, 41, 61),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: Get.width / 40),
                          child: Text(
                                " My Info ".tr,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily: globalFontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      globalFontSizeChange <= 17
                                          ? (globalFontSizeChange / 5) + 23
                                          : 23 - (globalFontSizeChange / 5),
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.loop(),
                              )
                              .shimmer(
                                delay: Duration(seconds: 4),
                                duration: 800.ms,
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Colors.grey.shade700
                                        : Colors.white54,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     Get.to(Favorites());
                      //   },
                      //   icon: Icon(Icons.favorite, color: Colors.red),
                      // ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 210, 209, 224)
                            : Color.fromARGB(255, 40, 41, 61),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child:
                      (profileController.profileData.isEmpty)
                          ? noDataLottie("No data available")
                          : SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Stack(
                                  fit: StackFit.passthrough,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      width: 150,
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
                                  ],
                                ),
                                const SizedBox(height: 30),
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(
                                    "User Name".tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: globalFontFamily,
                                    ),
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      Get.to(() => ChangeUsername());
                                    },
                                    child: Container(
                                      height: 25,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
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
                                      child: Center(
                                        child: Text(
                                          "Change UserName",
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        11
                                                    : 11 -
                                                        (globalFontSizeChange /
                                                            5),
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
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        "${profileController.profileData["userName"]}",
                                        style: TextStyle(
                                          fontFamily: globalFontFamily,
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      18
                                                  : 18 -
                                                      (globalFontSizeChange /
                                                          5),
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
                                const SizedBox(height: 10),
                                Divider(height: 10, color: Colors.black26),
                                ListTile(
                                  leading: const Icon(Icons.phone),
                                  title: Text(
                                    "Phone Number".tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: globalFontFamily,
                                    ),
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      Get.to(() => ChangeNumber());
                                    },
                                    child: Container(
                                      height: 25,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
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
                                      child: Center(
                                        child: Text(
                                          "Change Number",
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        11
                                                    : 11 -
                                                        (globalFontSizeChange /
                                                            5),
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
                                  ),
                                  subtitle: Text(
                                    // "${controller.profileData["number"] ?? ""}",
                                    "0${profileController.profileData["number"]}",
                                    // "09999999999999",
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 18
                                              : 18 - (globalFontSizeChange / 5),
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
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(height: 10, color: Colors.black26),
                                ListTile(
                                  leading: const Icon(Icons.password),
                                  title: Text(
                                    "Password".tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: globalFontFamily,
                                    ),
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      Get.to(() => ChangePassword());
                                    },
                                    child: Container(
                                      height: 25,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
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
                                      child: Center(
                                        child: Text(
                                          "Change Password",
                                          style: TextStyle(
                                            fontFamily: globalFontFamily,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        11
                                                    : 11 -
                                                        (globalFontSizeChange /
                                                            5),
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
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        "XXXXXXXXX",
                                        style: TextStyle(
                                          fontFamily: globalFontFamily,
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      18
                                                  : 18 -
                                                      (globalFontSizeChange /
                                                          5),
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
                                const SizedBox(height: 11),
                                Divider(height: 10, color: Colors.black26),
                                ListTile(
                                  leading: const Icon(Icons.category_outlined),
                                  title: Text(
                                    "Subscriptions".tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: globalFontFamily,
                                    ),
                                  ),
                                  subtitle: Wrap(
                                    children: [
                                      Text(
                                        profileController.profileData["subs"] ??
                                            "No Subscriptions",
                                        style: TextStyle(
                                          fontFamily: globalFontFamily,
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      18
                                                  : 18 -
                                                      (globalFontSizeChange /
                                                          5),
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
                                const SizedBox(height: 10),
                                Divider(height: 10, color: Colors.black26),
                              ],
                            ),
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

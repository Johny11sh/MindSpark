// ignore_for_file: file_names, non_constant_identifier_names, avoid_print

import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learning_management_system/core/function/settingsCard.dart';

import '../controller/BackButtonController.dart';
import '../core/classes/AvatarPicker.dart';
import '../core/function/noDataLottie.dart';
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
import '../core/constants/FontGlobals.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _avatarAnimationController;
  late AnimationController _sparksAnimationController;
  late AnimationController _editButtonAnimationController;
  late AnimationController _cardsAnimationController;

  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _sparksScaleAnimation;
  late AnimationController _editIconAnimationController;
  late Animation<double> _editIconScaleAnimation;
  final List<Animation<double>> _cardAnimations = [];

  final List<Map<String, dynamic>> cardData = [
    {
      'icon': Icons.format_list_numbered_outlined,
      'title': "Management".tr,
      'onTap': () => Get.to(() => Management()),
    },
    {
      'icon': Icons.settings,
      'title': "Settings".tr,
      'onTap': () => Get.to(() => Settings()),
    },
    {
      'icon': Icons.help_center_outlined,
      'title': "Help Center".tr,
      'onTap': () => Get.to(() => HelpCenter()),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Avatar bounce animation
    _avatarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _avatarScaleAnimation = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _avatarAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Title wave animation
    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _titleScaleAnimation = Tween(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: const Interval(0.0, 0.9, curve: Curves.decelerate),
        reverseCurve: Interval(0.0, 0.9),
      ),
    );

    // Sparks sequential animation
    _sparksAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _sparksScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _sparksAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Edit button continuous rotation animation
    _editButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // _editButtonRotationAnimation = Tween(begin: 3.14159*2, end:  3.14159).animate(
    //   CurvedAnimation(
    //     parent: _editButtonAnimationController,
    //     curve: Curves.linear,
    //   ),

    //  _editButtonRotationAnimation =    Tween<double>(
    //     begin: 1.0,
    //     end: 1.3, // حجم أكبر قليلاً
    //   ).animate(CurvedAnimation(
    //     parent: _editIconAnimationController,
    //     curve: Curves.easeInOut,
    //   )
    //   );

    // Cards list animation
    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: Duration(milliseconds: 200),
    );

    // Initialize card animations
    for (int i = 0; i < 3; i++) {
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsAnimationController,
          curve: Interval(0.3 + (i * 0.2), 1.0, curve: Curves.easeOut),
        ),
      );
      _cardAnimations.add(animation);
    }

    _cardsAnimationController.forward();

    // Start sparks animation after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _sparksAnimationController.forward();
      }
    });

    _editIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _editIconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3, // حجم أكبر قليلاً
    ).animate(
      CurvedAnimation(
        parent: _editIconAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _avatarAnimationController.dispose();
    _titleAnimationController.dispose();
    _sparksAnimationController.dispose();
    _editButtonAnimationController.dispose();
    _cardsAnimationController.dispose();
    _editIconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final ThemeController themeController = Get.find<ThemeController>();
    // final LocaleController localeController = Get.find<LocaleController>();
    final BackButtonController controller = Get.put(BackButtonController());

    final NetworkController networkController = Get.find<NetworkController>();

    return WillPopScope(
      onWillPop: controller.onWillPop,

      child: Scaffold(
        body: Obx(() {
          if (profileController.isLoading.value) {
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
              child: FutureBuilder(
                future: Future.delayed(Duration(seconds: 10)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      profileController.isLoading.value) {
                    return Center(
                      child: Text(
                        'Loading took too long. Please check your connection and try again.'
                            .tr,
                        style: TextStyle(fontFamily: globalFontFamily),
                      ),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(255, 40, 41, 61)
                              : Color.fromARGB(255, 210, 209, 224),
                    ),
                  );
                },
              ),
            );
          }
          if (profileController.profileData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No profile data available.'.tr,
                    style: TextStyle(fontFamily: globalFontFamily),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await networkController.checkConnectivityManually();
                      await profileController.getProfileData();
                    },
                    child: Text(
                      'Retry'.tr,
                      style: TextStyle(fontFamily: globalFontFamily),
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontFamily: globalFontFamily,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 210, 209, 224)
                                      : Color.fromARGB(255, 40, 41, 61),
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 23
                                      : 23 - (globalFontSizeChange / 5),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.loop())
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
                          return noDataLottie("No data available");
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
                                                : Color.fromARGB(
                                                  255,
                                                  40,
                                                  41,
                                                  61,
                                                ),
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
                                            builder:
                                                (context) => AvatarPicker(),
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
                                fontFamily: globalFontFamily,
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 22
                                        : 22 - (globalFontSizeChange / 5),
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
                                  'Sparks:'.tr,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
                                    fontFamily: globalFontFamily,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 22
                                            : 22 - (globalFontSizeChange / 5),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  "${profileData['sparks'].toString()}/1000".tr,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
                                    fontFamily: globalFontFamily,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 22
                                            : 22 - (globalFontSizeChange / 5),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "-",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
                                    fontFamily: globalFontFamily,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 22
                                            : 22 - (globalFontSizeChange / 5),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Sparkies:'.tr,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
                                    fontFamily: globalFontFamily,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 22
                                            : 22 - (globalFontSizeChange / 5),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  "${profileData['sparkies'].toString()}/15".tr,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(
                                    fontFamily: globalFontFamily,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 22
                                            : 22 - (globalFontSizeChange / 5),
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
                                            fontFamily: globalFontFamily,
                                            color: Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            ),
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        20
                                                    : 20 -
                                                        (globalFontSizeChange /
                                                            5),
                                          ),
                                          content: Text('Are you sure?'),
                                          contentTextStyle: TextStyle(
                                            fontFamily: globalFontFamily,
                                            color: Color.fromARGB(
                                              255,
                                              40,
                                              41,
                                              61,
                                            ),
                                            fontWeight: FontWeight.w300,
                                            fontSize:
                                                globalFontSizeChange <= 17
                                                    ? (globalFontSizeChange /
                                                            5) +
                                                        16
                                                    : 16 -
                                                        (globalFontSizeChange /
                                                            5),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontFamily: globalFontFamily,
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
                                                  fontFamily: globalFontFamily,
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
                                    width: Get.width / 3,
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
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Log Out".tr,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.copyWith(
                                          fontFamily: globalFontFamily,
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      20
                                                  : 20 -
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30),
                                ScaleTransition(
                                  scale: _editIconScaleAnimation,
                                  child: IconButton(
                                    onPressed: () {
                                      Get.to(() => MyInfo());
                                    },
                                    icon: Icon(
                                      Icons.edit,
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
                                    for (int i = 0; i < cardData.length; i++)
                                      AnimatedBuilder(
                                        animation: _cardAnimations[i],
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: _cardAnimations[i].value,
                                            child: Transform.translate(
                                              offset: Offset(
                                                0,
                                                50 *
                                                    (1 -
                                                        _cardAnimations[i]
                                                            .value),
                                              ),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: settingsCard(
                                          i,
                                          themeController,
                                          context,
                                          cardData,
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
      ),
    );
  }
}

// Widget _buildCardItem(
//   int index,
//   ThemeController themeController,
//   BuildContext context,
//   List<Map<String, dynamic>> Data,
// ) {
//   final List<Map<String, dynamic>> cardData = Data;

//   return InkWell(
//     onTap: cardData[index]['onTap'],
//     child: Card(
//       color:
//           themeController.initialTheme == Themes.customLightTheme
//               ? Color.fromARGB(255, 40, 41, 61)
//               : Color.fromARGB(255, 210, 209, 224),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Icon(
//               cardData[index]['icon'] as IconData,
//               size: 25,
//               color:
//                   themeController.initialTheme == Themes.customLightTheme
//                       ? Color.fromARGB(255, 210, 209, 224)
//                       : Color.fromARGB(255, 40, 41, 61),
//             ),
//           ),
//           Expanded(
//             flex: 2,
//             child: Container(
//               padding: const EdgeInsets.only(top: 10, bottom: 10),
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "${cardData[index]['title']}".tr,
//                 style: TextStyle(
//                   fontFamily: globalFontFamily,
//                   fontSize:
//                       globalFontSizeChange <= 17
//                           ? (globalFontSizeChange / 5) + 20
//                           : 20 - (globalFontSizeChange / 5),
//                   fontWeight: FontWeight.bold,
//                   fontStyle: FontStyle.normal,
//                   color:
//                       themeController.initialTheme == Themes.customLightTheme
//                           ? Color.fromARGB(255, 210, 209, 224)
//                           : Color.fromARGB(255, 40, 41, 61),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Icon(
//               Icons.arrow_forward_ios_outlined,
//               size: 17,
//               color:
//                   themeController.initialTheme == Themes.customLightTheme
//                       ? Color.fromARGB(255, 210, 209, 224)
//                       : Color.fromARGB(255, 40, 41, 61),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

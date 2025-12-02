// ignore_for_file: non_constant_identifier_names, file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:learning_management_system/view/OnBoarding.dart';

import '../core/constants/FontGlobals.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../services/CacheManager.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'FontSettingsPage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  List Languages = [
    {"name": "English", "LangCode": "En", "flag": ImageAssets.EnglishFlag},
    {"name": "Arabic", "LangCode": "Ar", "flag": ImageAssets.ArabicFlag},
    {"name": "German", "LangCode": "De", "flag": ImageAssets.GermanFlag},
    {"name": "Spanish", "LangCode": "Es", "flag": ImageAssets.SpanishFlag},
    {"name": "French", "LangCode": "Fr", "flag": ImageAssets.FrenchFlag},
  ];

  bool isExpanded = false;
  bool isExpanded2 = false;

  bool _isDarkMode =
      Get.find<ThemeController>().initialTheme == Themes.customDarkTheme;

  @override
  Widget build(BuildContext context) {
    final CacheManager cacheManager = CacheManager();

    cacheManager.init();
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
              // SizedBox(height: 50),
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
                          padding: EdgeInsets.only(right: Get.width / 8),

                          child: Text(
                                "Settings".tr,
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
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 210, 209, 224)
                            : Color.fromARGB(255, 40, 41, 61),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Get.to(() => Language());

                                  isExpanded = !isExpanded;

                                  setState(() {});
                                },
                                child: Card(
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.language_outlined,
                                          size: 25,
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
                                            "Language".tr,
                                            style: TextStyle(
                                              fontFamily: globalFontFamily,
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          20
                                                      : 20 -
                                                          (globalFontSizeChange /
                                                              5),
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
                                          isExpanded
                                              ? Icons.keyboard_arrow_up_outlined
                                              : Icons
                                                  .keyboard_arrow_down_outlined,
                                          size: 22,

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
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (isExpanded)
                                ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: Languages.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              localeController.changeLang(
                                                Languages[index]['LangCode'],
                                              );
                                            });
                                          },
                                          child: SizedBox(
                                            height: 100,
                                            child: Card(
                                              shadowColor: Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                              elevation: 3,
                                              color:
                                                  themeController
                                                              .initialTheme ==
                                                          Themes
                                                              .customLightTheme
                                                      ? Color.fromARGB(
                                                        255,
                                                        153,
                                                        151,
                                                        188,
                                                      )
                                                      : Color.fromARGB(
                                                        255,
                                                        46,
                                                        48,
                                                        97,
                                                      ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                      child: Image.asset(
                                                        Languages[index]["flag"]!,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      "${Languages[index]["name"]}"
                                                          .tr,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            globalFontFamily,
                                                        fontSize:
                                                            globalFontSizeChange >=
                                                                    17
                                                                ? (globalFontSizeChange /
                                                                        5) +
                                                                    18
                                                                : 18 -
                                                                    (globalFontSizeChange /
                                                                        5),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                        color:
                                                            themeController
                                                                        .initialTheme ==
                                                                    Themes
                                                                        .customLightTheme
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
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              const SizedBox(height: 20),

                              Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    const SizedBox(width: 10),

                                    Text(
                                      "Theme".tr,
                                      style: TextStyle(
                                        fontFamily: globalFontFamily,
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
                                        fontSize:
                                            globalFontSizeChange <= 17
                                                ? (globalFontSizeChange / 5) +
                                                    20
                                                : 20 -
                                                    (globalFontSizeChange / 5),
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 100),

                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Icon(
                                                    Icons.light_mode_rounded,
                                                    key: ValueKey('light'),
                                                    size: 22,
                                                    color:
                                                        themeController
                                                                    .initialTheme ==
                                                                Themes
                                                                    .customLightTheme
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
                                                  )
                                                  .animate()
                                                  .fadeIn(duration: 500.ms)
                                                  .slideX(begin: 2, end: 0)
                                              : SizedBox(
                                                key: ValueKey('light-space'),
                                                width: 22,
                                              ),
                                    ),
                                    Expanded(
                                      child: Switch(
                                        activeColor:
                                            themeController.initialTheme ==
                                                    Themes.customLightTheme
                                                ? Color.fromARGB(
                                                  255,
                                                  153,
                                                  151,
                                                  188,
                                                )
                                                : Color.fromARGB(
                                                  255,
                                                  254,
                                                  233,
                                                  204,
                                                ),
                                        value: _isDarkMode,
                                        onChanged: (bool value) async {
                                          setState(() {
                                            _isDarkMode = value;
                                          });

                                          themeController.toggleTheme(
                                            value ? "light" : "dark",
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ),

                                    AnimatedSwitcher(
                                      duration: Duration(milliseconds: 300),
                                      child:
                                          themeController.initialTheme ==
                                                  Themes.customDarkTheme
                                              ? Icon(
                                                    Icons.dark_mode_rounded,
                                                    key: ValueKey('dark'),
                                                    size: 22,
                                                    color:
                                                        themeController
                                                                    .initialTheme ==
                                                                Themes
                                                                    .customLightTheme
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
                                                  )
                                                  .animate()
                                                  .fadeIn(duration: 500.ms)
                                                  .slideX(begin: -2, end: 0)
                                              : SizedBox(
                                                key: ValueKey('dark-space'),
                                                width: 22,
                                              ),
                                    ),

                                    // themeController.initialTheme ==
                                    //         Themes.customLightTheme
                                    //     ? Icon(
                                    //       Icons.light_mode_rounded,
                                    //       size: 22,

                                    //       color:
                                    //           themeController.initialTheme ==
                                    //                   Themes.customLightTheme
                                    //               ? Color.fromARGB(
                                    //                 255,
                                    //                 40,
                                    //                 41,
                                    //                 61,
                                    //               )
                                    //               : Color.fromARGB(
                                    //                 255,
                                    //                 210,
                                    //                 209,
                                    //                 224,
                                    //               ),
                                    //     )
                                    //     : const SizedBox(width: 15),

                                    // Expanded(
                                    //   child: Switch(
                                    //     activeColor:
                                    //         themeController.initialTheme ==
                                    //                 Themes.customLightTheme
                                    //             ? Color.fromARGB(
                                    //               255,
                                    //               153,
                                    //               151,
                                    //               188,
                                    //             )
                                    //             : Color.fromARGB(
                                    //               255,
                                    //               254,
                                    //               233,
                                    //               204,
                                    //             ),
                                    //     value:
                                    //         themeController.initialTheme ==
                                    //         Themes.customDarkTheme,
                                    //     onChanged: (bool value) async {
                                    //       themeController.toggleTheme(
                                    //         value ? "light" : "dark",
                                    //       );
                                    //       setState(() {});
                                    //     },
                                    //   ),
                                    // ),
                                    // themeController.initialTheme ==
                                    //         Themes.customLightTheme
                                    //     ? const SizedBox(width: 15)
                                    //     : Icon(
                                    //       Icons.dark_mode_rounded,
                                    //       size: 22,

                                    //       color:
                                    //           themeController.initialTheme ==
                                    //                   Themes.customLightTheme
                                    //               ? Color.fromARGB(
                                    //                 255,
                                    //                 40,
                                    //                 41,
                                    //                 61,
                                    //               )
                                    //               : Color.fromARGB(
                                    //                 255,
                                    //                 210,
                                    //                 209,
                                    //                 224,
                                    //               ),
                                    //     ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              InkWell(
                                onTap: () async {
                                  isExpanded2 = !isExpanded2;
                                  showFontSettingsBottomSheet(context);
                                },
                                child: Card(
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.font_download_outlined,
                                          size: 25,
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
                                            "Fonts".tr,
                                            style: TextStyle(
                                              fontFamily: globalFontFamily,
                                              fontSize:
                                                  globalFontSizeChange <= 17
                                                      ? (globalFontSizeChange /
                                                              5) +
                                                          20
                                                      : 20 -
                                                          (globalFontSizeChange /
                                                              5),
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
                                          isExpanded2
                                              ? Icons.keyboard_arrow_up_outlined
                                              : Icons
                                                  .keyboard_arrow_down_outlined,
                                          size: 22,

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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              Obx(
                                () => SwitchListTile(
                                  activeColor:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 153, 151, 188)
                                          : Color.fromARGB(255, 254, 233, 204),
                                  title: Text(
                                    "Cache Data".tr,
                                    style: TextStyle(
                                      fontFamily: globalFontFamily,
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
                                      fontSize:
                                          globalFontSizeChange <= 17
                                              ? (globalFontSizeChange / 5) + 20
                                              : 20 - (globalFontSizeChange / 5),
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  value: cacheManager.isCacheEnabled.value,
                                  onChanged: (bool value) async {
                                    // print(
                                    //   'caching: ${cacheManager.isCacheEnabled.value}',
                                    // );
                                    // if (value == false) {
                                    //   final confirmed = await Get.dialog(
                                    //     AlertDialog(
                                    //       title: Text("Clear Cached Data?".tr),
                                    //       content: Text(
                                    //         "This will remove all locally cached data. Continue?"
                                    //             .tr,
                                    //       ),
                                    //       actions: [
                                    //         TextButton(
                                    //           onPressed:
                                    //               () => Get.back(result: false),
                                    //           child: Text("Cancel".tr),
                                    //         ),
                                    //         TextButton(
                                    //           onPressed:
                                    //               () => Get.back(result: true),
                                    //           child: Text("Clear".tr),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   );

                                    //   if (!confirmed) return;
                                    // }
                                    await cacheManager.setCacheEnabled(value);
                                    print(
                                      'caching: ${cacheManager.isCacheEnabled.value}',
                                    );

                                    if (cacheManager.isCacheEnabled.value ==
                                        false) {
                                      final List<String> cacheKeyPatterns = [
                                        // 'cached_profile',
                                        'cached_books',
                                        'cached_courses',
                                        'cached_recommended_books',
                                        'cached_top_rated_books',
                                        'cached_recent_books',
                                        'cached_scientific_subjects',
                                        'cached_literary_subjects',
                                        'cached_subscribed_courses',
                                        'cached_most_subscribed_courses',
                                        'cached_recent_courses',
                                        'cached_top_rated_courses',
                                        'cached_recommended_courses',
                                        'cached_my_courses',
                                        'cached_teachers',
                                        'cached_scientific_subjects',
                                        'cached_literary_subjects',
                                        'cached_teachers_',
                                        'cached_lectures_',
                                        'cached_recent_lessons_',
                                        'cached_top_rated_lessons_',
                                        'cached_courses_',
                                        'cached_recent_courses_',
                                        'cached_top_rated_courses_',
                                        'cached_subject_books_',
                                      ];

                                      final allKeys =
                                          sharedPrefs.prefs.getKeys();

                                      for (final key in allKeys) {
                                        final shouldRemove = cacheKeyPatterns
                                            .any(
                                              (pattern) =>
                                                  key.startsWith(pattern),
                                            );

                                        if (shouldRemove) {
                                          try {
                                            await sharedPrefs.prefs.remove(key);
                                            print('Removed cached data: $key');
                                          } catch (e) {
                                            print('Error removing $key: $e');
                                          }
                                        }
                                      }
                                    }

                                    Get.snackbar(
                                      colorText:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              )
                                              : Color.fromARGB(255, 40, 41, 61),
                                      "Setting Changed".tr,
                                      value
                                          ? "Data will be cached.".tr
                                          : "Caching disabled. All cached data has been cleared."
                                              .tr,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 20, top: 5),
                                child: Text(
                                  (cacheManager.isCacheEnabled.value == true)
                                      ? "Caching data will increase memory usage, but will allow you to study offline and enjoy all available features."
                                          .tr
                                      : "When caching is disabled you can only use the application in online mode."
                                          .tr,
                                  style: TextStyle(
                                    fontFamily: globalFontFamily,
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
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 12
                                            : 12 - (globalFontSizeChange / 5),
                                    fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
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

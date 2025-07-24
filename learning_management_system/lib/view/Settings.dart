import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../services/CacheManager.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
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
  @override
  Widget build(BuildContext context) {
    final CacheManager cacheManager = CacheManager();

    cacheManager.init();
    return Scaffold(
      body: Container(
        color:
            themeController.initialTheme == Themes.customLightTheme
                ? Color.fromARGB(255, 40, 41, 61)
                : Color.fromARGB(255, 210, 209, 224),
        child: Column(
          children: [
            // SizedBox(height: 50),
            Container(
              padding: EdgeInsets.only(top: 30),
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            InkWell(
                              onTap: () {
                                // Get.to(() => Language());

                                isExpanded = !isExpanded;

                                setState(() {});
                                print(isExpanded);
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
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Language".tr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
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
                                                      fontSize: 18,
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
                            SizedBox(height: 20),

                            //   InkWell(
                            //     onTap: () {
                            //       Get.to(() => ChangeTheme());
                            //     },
                            //     child: Card(
                            //       color:themeController.initialTheme == Themes.customLightTheme
                            // ? Color.fromARGB(255, 40, 41, 61)
                            // : Color.fromARGB(255, 210, 209, 224),
                            //       child: Row(
                            //         children: [
                            //           Expanded(
                            //             flex: 1,
                            //             child: Icon(
                            //               Icons.sunny,
                            //               size: 25,
                            //               color:
                            //                   themeController.initialTheme ==
                            //                       Themes.customLightTheme
                            //                   ? Color.fromARGB(255, 210, 209, 224)
                            //                   : Color.fromARGB(255, 40, 41, 61),
                            //             ),
                            //           ),
                            //           Expanded(
                            //             flex: 2,
                            //             child: Container(
                            //               padding: EdgeInsets.only(
                            //                 top: 10,
                            //                 bottom: 10,
                            //               ),
                            //               alignment: Alignment.centerLeft,
                            //               child: Text(
                            //                 "Theme".tr,
                            //                 style: TextStyle(
                            //                   fontSize: 20,
                            //                   fontWeight: FontWeight.bold,
                            //                   fontStyle: FontStyle.normal,
                            //                   color:
                            //                       themeController.initialTheme ==
                            //                       Themes.customLightTheme
                            //                   ? Color.fromARGB(255, 210, 209, 224)
                            //                   : Color.fromARGB(255, 40, 41, 61),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //           Expanded(
                            //             child: Icon(
                            //               size: 17,
                            //               Icons.arrow_forward_ios_outlined,
                            //               color:
                            //                   themeController.initialTheme ==
                            //                       Themes.customLightTheme
                            //                   ? Color.fromARGB(255, 210, 209, 224)
                            //                   : Color.fromARGB(255, 40, 41, 61),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                spacing: 10,
                                children: [
                                  SizedBox(width: 10,),

                                  Text(
                                        "Theme".tr,
                                        style: TextStyle(
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                      SizedBox(width: 100,),
                                      themeController.initialTheme ==
                                            Themes.customLightTheme ? Icon(
                                    Icons.light_mode_rounded,
                                    size: 22,

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
                                  )
                                  : SizedBox(width: 15,),

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
                                      value:
                                          themeController.initialTheme ==
                                          Themes.customDarkTheme,
                                      onChanged: (bool value) async {
                                        themeController.toggleTheme(
                                          value ? "light" : "dark",
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  themeController.initialTheme ==
                                            Themes.customLightTheme ? SizedBox(width: 15,) : Icon(
                                    Icons.dark_mode_rounded,
                                    size: 22,

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
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            //               SizedBox(
                            //   height: 80,
                            //   child: InkWell(
                            //     onTap: () {
                            //       // SharedPrefs.instance.Init();
                            //       // SharedPrefs.instance.prefs;
                            //       setState(() {
                            //         themeController.toggleTheme("dark");
                            //       });
                            //       themeController.onInit();
                            //     },
                            //     child: Card(
                            //       child: Row(
                            //         children: [
                            //           Expanded(
                            //             flex: 1,
                            //             child: Icon(
                            //               Icons.light_mode,
                            //               size: 25,
                            //               color:
                            //                   themeController.initialTheme ==
                            //                           Themes.customLightTheme
                            //                       ? Color.fromARGB(255, 40, 41, 61)
                            //                       : Color.fromARGB(255, 210, 209, 224),
                            //             ),
                            //           ),
                            //           Expanded(
                            //             flex: 3,
                            //             child: Container(
                            //               padding: EdgeInsets.only(top: 10, bottom: 10),
                            //               alignment: Alignment.centerLeft,
                            //               child: Text(
                            //                 "Light Mode".tr,
                            //                 style: TextStyle(
                            //                   fontSize: 20,
                            //                   fontWeight: FontWeight.bold,
                            //                   fontStyle: FontStyle.normal,
                            //                   color:
                            //                       themeController.initialTheme ==
                            //                               Themes.customLightTheme
                            //                           ? Color.fromARGB(255, 40, 41, 61)
                            //                           : Color.fromARGB(255, 210, 209, 224),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(height: 20),
                            // SizedBox(
                            //   height: 80,
                            //   child: InkWell(
                            //     onTap: () {
                            //       themeController.toggleTheme("light");
                            //       setState(() {});
                            //     },
                            //     child: Card(
                            //       child: Row(
                            //         children: [
                            //           Expanded(
                            //             flex: 1,
                            //             child: Icon(
                            //               Icons.dark_mode,
                            //               size: 25,
                            //               color:
                            //                   themeController.initialTheme ==
                            //                           Themes.customLightTheme
                            //                       ? Color.fromARGB(255, 40, 41, 61)
                            //                       : Color.fromARGB(255, 210, 209, 224),
                            //             ),
                            //           ),
                            //           Expanded(
                            //             flex: 3,
                            //             child: Container(
                            //               padding: EdgeInsets.only(top: 10, bottom: 10),
                            //               alignment: Alignment.centerLeft,
                            //               child: Text(
                            //                 "Dark Mode".tr,
                            //                 style: TextStyle(
                            //                   fontSize: 20,
                            //                   fontWeight: FontWeight.bold,
                            //                   fontStyle: FontStyle.normal,
                            //                   color:
                            //                       themeController.initialTheme ==
                            //                               Themes.customLightTheme
                            //                           ? Color.fromARGB(255, 40, 41, 61)
                            //                           : Color.fromARGB(255, 210, 209, 224),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            InkWell(
                              onTap: () {
                                // Get.to(() => ContactUs());
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
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Fonts".tr,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
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
                                      ),
                                    ),
                                    Expanded(
                                      child: Icon(
                                        size: 17,

                                        Icons.arrow_forward_ios_outlined,
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
                            SizedBox(height: 20),

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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                                value: cacheManager.isCacheEnabled.value,
                                onChanged: (bool value) async {
                                  await cacheManager.setCacheEnabled(value);
                                  Get.snackbar(
                                    colorText:
                                        themeController.initialTheme ==
                                                Themes.customLightTheme
                                            ? Color.fromARGB(255, 210, 209, 224)
                                            : Color.fromARGB(255, 40, 41, 61),
                                    "Setting Changed".tr,
                                    value
                                        ? "Data will be cached.".tr
                                        : "Caching disabled. Only live data will be used."
                                            .tr,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20),
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
    );
  }
}

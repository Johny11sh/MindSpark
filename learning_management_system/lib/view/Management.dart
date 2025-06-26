import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/classes/AboutUs.dart';
import '../core/classes/ChangeTheme.dart';
import '../core/classes/ContactUs.dart';
import '../core/classes/Language.dart';
import '../core/classes/PrivacyPolicy.dart';
import '../core/classes/WatchList.dart';
import '../themes/Themes.dart';
import 'NavBar.dart';

class Management extends StatelessWidget {
  const Management({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // SizedBox(height: 50),
          Container(
            padding: EdgeInsets.only(top: 30),
            height: 100,
            color:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 40, 41, 61),
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
                      color: Color.fromARGB(255, 210, 209, 224),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: Get.width / 8),

                      child: Text(
                        "Management".tr,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
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
                              Get.to(() => WatchList());
                            },
                            child: Card(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.format_list_numbered_outlined,
                                      size: 25,
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
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "WatchList".tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
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
                                  Expanded(
                                    child: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 17,
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
                          ),


                          InkWell(
                            onTap: () {
                            },
                            child: Card(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.task_outlined,
                                      size: 25,
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
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Task".tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
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
                                  Expanded(
                                    child: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 17,
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
      ),
    );
  }
}

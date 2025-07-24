// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/ImageAssets.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    // final LocaleController localeController = Get.find<LocaleController>();

    final bool isDark = themeController.initialTheme == Themes.customLightTheme;
    final Color bgColor = isDark
        ? const Color.fromARGB(255, 40, 41, 61)
        : const Color.fromARGB(255, 210, 209, 224);
    final Color fgColor = isDark
        ? const Color.fromARGB(255, 210, 209, 224)
        : const Color.fromARGB(255, 40, 41, 61);

    return Scaffold(
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30),
              height: 100,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: fgColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: Get.width / 8),
                        child: Text(
                          "About Us".tr,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: fgColor,
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
                  color: fgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(30)),
                    Center(
                      child: Image.asset(ImageAssets.AppIconNoBackGround, width: 180, height: 180),
                    ),
                    Padding(padding: EdgeInsets.all(20)),
                    Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      child: Card(
                        color: bgColor,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                "Welcome to MindSpark!".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: fgColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              )
                            ),
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                "The purpose of this app is to \"save effort, time, and costs\" (such as lecture halls and transportation expenses). All our courses will be available in this app as \"well-organized and beautifully structured videos\"."
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: fgColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              )
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
    );
  }
}

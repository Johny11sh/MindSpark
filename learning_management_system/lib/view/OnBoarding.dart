// ignore_for_file: file_names, non_constant_identifier_names, unused_local_variable

import 'package:lottie/lottie.dart';

import '../controller/OnBoardingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/FontGlobals.dart';
import '../core/constants/ImageAssets.dart';
import '../model/OnBoardingModel.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../themes/ThemeController.dart';

final SharedPrefs sharedPrefs = SharedPrefs.instance;

List<OnBoardingModel> OnBoardingList = [
  OnBoardingModel(
    title: "Simplicity".tr,
    subtitle:
        "With the rise of complicated courses and infinite ways to study them, this app with its unique UI presents you with your very own repository of your favorite courses published by your favorite teachers."
            .tr,
    image: ImageAssets.OnBoardingLottie1,
  ),
  OnBoardingModel(
    title: "Convenience".tr,
    subtitle:
        "All lectures, all courses, all the information you could possibly need is all here. Just log in, and continue where you left off in the latest courses made by the most reputable tutors."
            .tr,
    image: ImageAssets.OnBoardingLottie2,
  ),
  OnBoardingModel(
    title: "Guarantee".tr,
    subtitle:
        "With no unnecessary or bloated info, this application is a sure-fire way to leave the exam hall feeling self-confidence. Just tune in to whatever course you're in need of, and rest assured, you'll leave more informed than before."
            .tr,
    image: ImageAssets.OnBoardingLottie3,
  ),
];

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    final OnboardingController onBoardingController = Get.put(
      OnboardingController(),
    );

    return Scaffold(
      body: Container(
        width: Get.width,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [
        //       Color.fromARGB(255, 40, 41, 61),
        //       Color.fromARGB(255, 210, 209, 224),
        //     ],
        //     begin: Alignment.bottomLeft,
        //     end: Alignment.topRight,
        //   ),
        // ),
        color: Color.fromARGB(255, 40, 41, 61),
        child: Column(
          children: [
            const SizedBox(height: 50),

            Container(
              alignment: Alignment.topRight,
              child: MaterialButton(
                onPressed: () {
                  onBoardingController.onSkip(2);
                },
                child: Text(
                  "Skip".tr,
                  style: TextStyle(color: Color.fromARGB(255, 210, 209, 224)),
                ),
              ),
            ),

            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: onBoardingController.pageController,
                onPageChanged: (val) {
                  onBoardingController.onPageChanged(val);
                },
                itemCount: OnBoardingList.length,
                itemBuilder:
                    (context, i) => Column(
                      children: [
                        Container(
                          width: Get.width,
                          alignment: Alignment.center,
                          child: Lottie.asset(
                            OnBoardingList[i].image!,
                            width: 300,
                            height: 300,
                          ),
                          // Image.asset(
                          //   OnBoardingList[i].image!,
                          //   height: 300,
                          //   width: 300,
                          // ),
                        ),
                        Container(
                          width: Get.width,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: Text(
                              OnBoardingList[i].title!.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 20
                                        : 20 - (globalFontSizeChange / 5),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: Get.width,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 30,
                              right: 30,
                              top: 20,
                            ),
                            child: Text(
                              OnBoardingList[i].subtitle!.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    globalFontSizeChange <= 17
                                        ? (globalFontSizeChange / 5) + 16
                                        : 16 - (globalFontSizeChange / 5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              ),
            ),
            SizedBox(height: Get.height / 100),
            Expanded(
              flex: 3,
              child: GetBuilder<OnboardingController>(
                builder:
                    (controller) => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(
                              OnBoardingList.length,
                              (index) => AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                margin: const EdgeInsets.all(3),
                                width: controller.currentPage == index ? 30 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    210,
                                    209,
                                    224,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Get.height / 12),
                        MaterialButton(
                          onPressed: () {
                            onBoardingController.next();
                          },
                          minWidth: Get.width / 1.5,
                          height: 40,
                          disabledColor: const Color.fromARGB(
                            255,
                            153,
                            151,
                            188,
                          ),
                          color: Color.fromARGB(255, 210, 209, 224),
                          clipBehavior: Clip.hardEdge,
                          child: Text(
                            controller.currentPage == OnBoardingList.length - 1
                                ? "Get Started".tr
                                : "Next".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 40, 41, 61),
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  globalFontSizeChange <= 17
                                      ? (globalFontSizeChange / 5) + 20
                                      : 20 - (globalFontSizeChange / 5),
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

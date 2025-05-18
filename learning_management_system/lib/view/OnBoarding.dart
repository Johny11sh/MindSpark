// ignore_for_file: file_names, non_constant_identifier_names, unused_local_variable

import '../controller/OnBoardingController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/ImageAssets.dart';
import '../model/OnBoardingModel.dart';
import '../locale/LocaleController.dart';
import '../services/SharedPrefs.dart';
import '../themes/ThemeController.dart';

final SharedPrefs sharedPrefs = SharedPrefs.instance;

List<OnBoardingModel> OnBoardingList = [
  OnBoardingModel(
    title:
        "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves that are conclusive of your learning process, guaranteeing progress and utter improvement."
            .tr,
    image: ImageAssets.OnBoarding1,
  ),
  OnBoardingModel(
    title:
        "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking."
            .tr,
    image: ImageAssets.OnBoarding2,
  ),
  OnBoardingModel(
    title:
        "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline."
            .tr,
    image: ImageAssets.OnBoarding3,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 40, 41, 61),
              Color.fromARGB(255, 210, 209, 224),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: onBoardingController.pageController,
                onPageChanged: (val) {
                  onBoardingController.onPageChanged(val);
                },
                itemCount: OnBoardingList.length,
                itemBuilder: (context, i) => Column(
                  children: [
                    SizedBox(height: 70),
                    Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      child: Image.asset(
                        OnBoardingList[i].image!,
                        height: 300,
                        width: 300,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      child: Card(
                        shadowColor: const Color.fromARGB(255, 46, 48, 97),
                        elevation: 8,
                        color: const Color.fromARGB(255, 210, 209, 224),
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            OnBoardingList[i].title!.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 46, 48, 97),
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GetBuilder<OnboardingController>(
                builder: (controller) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                          OnBoardingList.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            margin: EdgeInsets.all(3),
                            width: controller.currentPage == index ? 30 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 210, 209, 224),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    MaterialButton(
                      onPressed:
                          controller.currentPage == OnBoardingList.length - 1
                              ? () {
                                  onBoardingController.next();
                                }
                              : null,
                      minWidth: Get.width / 3,
                      height: 40,
                      disabledColor: const Color.fromARGB(255, 153, 151, 188),
                      color: const Color.fromARGB(255, 40, 41, 61),
                      elevation: 6,
                      focusElevation: 8,
                      disabledElevation: 4,
                      clipBehavior: Clip.hardEdge,
                      child: Text(
                        controller.currentPage == OnBoardingList.length - 1
                            ? "Get Started".tr
                            : "Continue".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 210, 209, 224),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
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

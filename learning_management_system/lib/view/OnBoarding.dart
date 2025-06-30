// ignore_for_file: file_names, non_constant_identifier_names, unused_local_variable

import 'package:lottie/lottie.dart';

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
    title: "shdfksdh",
    subtitle:
        "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves that are conclusive of your learning process, guaranteeing progress and utter improvement."
            .tr,
    image: ImageAssets.OnBoardingLottie1,
  ),
  OnBoardingModel(
    title: "shdfksdh",
    subtitle:
        "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking."
            .tr,
    image: ImageAssets.OnBoardingLottie2,
  ),
  OnBoardingModel(
    title: "shdfksdh",
    subtitle:
        "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline."
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
            SizedBox(height: 50),
            
             Container(
              alignment: Alignment.topRight,
              child: MaterialButton(onPressed: (){
                onBoardingController.onSkip(2);
              },
              child: Text("Skip",style:TextStyle(color: Color.fromARGB(255, 210, 209, 224),) ),
              )),
              
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
                          child: 
                          Lottie.asset(OnBoardingList[i].image!,width: 300,height:300)
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
                              padding: EdgeInsets.only(left:30,right:30),
                              child: Text(
                                OnBoardingList[i].title!.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                        ),
                        Container(
                          width: Get.width,
                          alignment: Alignment.center,
                          child: Container(
                              padding: EdgeInsets.only(left:30,right:30,top:20),
                              child: Text(
                                OnBoardingList[i].subtitle!.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 210, 209, 224),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
              ),
            ),
            SizedBox(height:Get.height/100),
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
                                margin: EdgeInsets.all(3),
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
                        SizedBox(height: Get.height/12,),
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
                              fontSize: 20,
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

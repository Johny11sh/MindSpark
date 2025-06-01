// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../services/SharedPrefs.dart';
import '../view/OnBoarding.dart';
import '../view/SignUp.dart';

class OnboardingController extends GetxController {
  PageController pageController = PageController();
  final SharedPrefs sharedPrefs = SharedPrefs.instance;

  int currentPage = 0;
  next() {
    currentPage++;
    if (currentPage > OnBoardingList.length - 1) {
      // sharedPrefs.prefs.setBool('isFirstEntry', false);
      Get.offAll(() => SignUp());
    }
    else{
      pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 900),
          curve: Curves.easeInOut);

    }
    update();
  }

  onPageChanged(int index) {
    currentPage = index;
    update();
  }
}

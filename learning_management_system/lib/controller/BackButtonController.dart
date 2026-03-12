import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_management_system/view/SignUp.dart';
import '../core/constants/FontGlobals.dart';
import '../view/OnBoarding.dart';

class BackButtonController extends GetxController {
  late bool? ban;
  DateTime? lastBackButtonTime;

  BackButtonController({this.ban});

  Future<bool> onWillPop() async {
    if (ban == true) {
      Navigator.pop;
      Get.offAll(() => SignUp());
      sharedPrefs.prefs.clear();
      return true;
    }
    final currentTime = DateTime.now();

    bool shouldReset =
        lastBackButtonTime != null &&
        currentTime.difference(lastBackButtonTime!) > Duration(seconds: 2);

    if (lastBackButtonTime == null || shouldReset) {
      lastBackButtonTime = currentTime;
      CustomFunction();

      Get.rawSnackbar(
        title: "Press back again".tr,
        messageText: Text(
          "Tap back button again to exit".tr,
          style: TextStyle(fontFamily: globalFontFamily),
        ),
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(milliseconds: 1000),
        backgroundColor: const Color.fromARGB(255, 232, 191, 43),
        icon: const Icon(
          Icons.priority_high_outlined,
          color: Colors.white,
          size: 35,
        ),
        margin: const EdgeInsets.all(5),
        borderRadius: 5,
        borderColor: Colors.grey[700]!,
      );
      return false;
    } else {
      // Second press within 500ms - exit app
      return true;
    }
  }

  void CustomFunction() {
    print('Back button pressed - first time');
  }
}

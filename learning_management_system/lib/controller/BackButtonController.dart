import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/FontGlobals.dart';

class BackButtonController extends GetxController {
  DateTime? lastBackButtonTime;

  Future<bool> onWillPop() async {
    final currentTime = DateTime.now();

    // Check if the last press was more than 2 seconds ago (reset if too old)
    bool shouldReset =
        lastBackButtonTime != null &&
        currentTime.difference(lastBackButtonTime!) > Duration(seconds: 2);

    if (lastBackButtonTime == null || shouldReset) {
      // Reset if it's been more than 2 seconds
      lastBackButtonTime = currentTime;
      yourCustomFunction();

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

  void yourCustomFunction() {
    print('Back button pressed - first time');
  }
}

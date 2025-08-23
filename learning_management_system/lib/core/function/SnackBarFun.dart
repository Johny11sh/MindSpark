// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/FontController.dart';

void showErrorSnackbar(String message) {
  Get.rawSnackbar(
    messageText: Text(
      message.tr,
      style: TextStyle(fontFamily: FontController().currentFontFamily),
    ),
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.red[800]!,
    icon: const Icon(Icons.error_outline, color: Colors.white),
  );
}

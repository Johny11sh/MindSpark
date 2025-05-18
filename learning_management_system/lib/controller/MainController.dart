// ignore_for_file: file_names, unnecessary_overrides

import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import 'package:get/get.dart';


class MainController extends GetxController {

  final LocaleController localeController = Get.put(LocaleController());
  final ThemeController themeController = Get.put(ThemeController());
  @override
  void onInit() {
    super.onInit();
    
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  
}
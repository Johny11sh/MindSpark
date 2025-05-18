// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:learning_management_system/view/SignUp.dart';

import 'controller/MainController.dart';
import 'controller/NetworkController.dart';
import 'locale/LocaleController.dart';
import 'locale/Locale.dart';
import 'themes/ThemeController.dart';
import 'view/NavBar.dart';
import 'services/SharedPrefs.dart';
import 'core/classes/ChangeTheme.dart';
import 'core/classes/Language.dart';
import 'core/classes/ChangeUsername.dart';
import 'core/classes/ChangePassword.dart';
import 'core/classes/ContactUs.dart';
import 'core/classes/AboutUs.dart';
import 'view/Profile.dart';
import 'core/classes/PrivacyPolicy.dart';
import 'view/LogIn.dart';
import 'view/OnBoarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'view/VideoPlayerScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.instance.Init();
  final SharedPrefs sharedPrefs = SharedPrefs.instance;
  final isLoggedIn = sharedPrefs.prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final MainController mainController = Get.put(MainController());
  final bool isLoggedIn;
  MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final localeController = Get.find<LocaleController>();
      Get.put(NetworkController());

      return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: Locale(),
          locale: localeController.initialLang,
          theme: themeController.initialTheme,
          home: 
          // OnBoarding()
          isLoggedIn ? NavBar() : OnBoarding(),
          // navigatorKey: NavigationService.navigatorKey, // Add this line
          getPages: [
            GetPage(name: "/OnBoarding", page: () => OnBoarding()),
            GetPage(name: "/SignUp", page: () => SignUp()),
            GetPage(name: "/LogIn", page: () => LogIn()),
            GetPage(name: "/NavigationBar", page: () => NavBar()),
            GetPage(name: "/Profile", page: () => Profile()),
            GetPage(name: "/ChangeUsername", page: () => ChangeUsername()),
            GetPage(name: "/ChangePassword", page: () => ChangePassword()),
            GetPage(name: "/Language", page: () => Language()),
            GetPage(name: "/Theme", page: () => ChangeTheme()),
            GetPage(name: "/ContactUs", page: () => ContactUs()),
            GetPage(name: "/AboutUs", page: () => AboutUs()),
            GetPage(name: "/PrivacyPolicy", page: () => PrivacyPolicy()),
          ]
          );
    });
  }
}



// class NavigationService {
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
//   static NavigatorState get navigator => navigatorKey.currentState!;
// }



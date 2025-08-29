// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learning_management_system/controller/FontController.dart';

import 'controller/NetworkController.dart';
import 'core/classes/ChangePassword.dart';
import 'core/classes/ChangeUsername.dart';
import 'firebase_options.dart';
import 'locale/LocaleController.dart';
import 'locale/Locale.dart';
import 'themes/ThemeController.dart';
import 'view/LogIn.dart';
import 'view/NavBar.dart';
import 'services/SharedPrefs.dart';
import 'view/OnBoarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ProfileController.dart';
import 'view/Profile.dart';
import 'view/SignUp.dart';
import 'NotificationService.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SharedPrefs.instance.Init();
  final SharedPrefs sharedPrefs = SharedPrefs.instance;
  final isLoggedIn = sharedPrefs.prefs.getBool('isLoggedIn') ?? false;

  Get.lazyPut(() => LocaleController());
  Get.lazyPut(() => ThemeController());
  Get.lazyPut(() => FontController());
  Get.put(NetworkController(), permanent: true);
  Get.put(ProfileController(), permanent: true);

  runApp(MyApp(isLoggedIn: isLoggedIn));
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
        home: isLoggedIn ? NavBar() : OnBoarding(),
        getPages: [
          GetPage(name: "/OnBoarding", page: () => OnBoarding()),
          GetPage(name: "/SignUp", page: () => SignUp()),
          GetPage(name: "/LogIn", page: () => LogIn()),
          GetPage(name: "/NavigationBar", page: () => NavBar()),
          GetPage(name: "/Profile", page: () => Profile()),
          GetPage(name: "/ChangeUsername", page: () => ChangeUsername()),
          GetPage(name: "/ChangePassword", page: () => ChangePassword()),
          // GetPage(name: "/ContactUs", page: () => ContactUs()),
          // GetPage(name: "/AboutUs", page: () => AboutUs()),
          // GetPage(name: "/PrivacyPolicy", page: () => PrivacyPolicy()),
        ],
      );
    });
  }
}

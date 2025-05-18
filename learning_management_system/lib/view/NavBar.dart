// ignore_for_file: file_names

import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:get/get.dart';

import '../view/HomePage.dart';
import '../view/Favorites.dart';
import 'Profile.dart';
import '../view/Teachers.dart';
import '../core/classes/CustomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

final ThemeController themeController = Get.find<ThemeController>();
final LocaleController localeController = Get.find<LocaleController>();

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      home: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: HomePage(),
            item: ItemConfig(
              activeForegroundColor: Color.fromARGB(255, 40, 41, 61),
              inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
              inactiveBackgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              icon: Icon(Icons.home),
              title: "Home".tr,
            ),
          ),
          PersistentTabConfig(
            screen: Teachers(),
            item: ItemConfig(
              activeForegroundColor:Color.fromARGB(255, 40, 41, 61),
              inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
              inactiveBackgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              icon: Icon(Icons.person),
              title: "Teachers".tr,
            ),
          ),
          PersistentTabConfig(
            screen: Favorites(),
            item: ItemConfig(
              activeForegroundColor:Color.fromARGB(255, 40, 41, 61),
              inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
              inactiveBackgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              icon: Icon(Icons.favorite),
              title: "Favorites".tr,
            ),
          ),
          PersistentTabConfig(
            screen: Profile(),
            item: ItemConfig(
              activeForegroundColor:Color.fromARGB(255, 40, 41, 61),
              inactiveForegroundColor: Color.fromARGB(255, 153, 151, 188),
              inactiveBackgroundColor:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 46, 48, 97),
              icon: Icon(Icons.person),
              title: "Profile".tr,
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) =>
            CustomNavBar(navBarConfig: navBarConfig),
      ),
    );
  }
}

// ignore_for_file: file_names

import 'package:google_nav_bar/google_nav_bar.dart';
import '../core/classes/ChatBot.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:get/get.dart';
import '../view/HomePage.dart';
import '../core/classes/Library.dart';
import 'Profile.dart';
import '../view/Teachers.dart';
import 'package:flutter/material.dart';

final ThemeController themeController = Get.find<ThemeController>();
final LocaleController localeController = Get.find<LocaleController>();
// String mainIP = "http://192.168.216.214:8000";
String mainIP = "http://127.0.0.1:8000";

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<StatefulWidget> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  List pageName = [
    {"Name": "HomePage", "Icon": Icons.home_filled},

    {"Name": "Teachers", "Icon": Icons.person},

    {"Name": "Library", "Icon": Icons.local_library_rounded},

    {"Name": "ChatBot", "Icon": Icons.assistant},

    {"Name": "Profile", "Icon": Icons.account_circle_outlined},
  ];

  List<Widget> page = [HomePage(), Teachers(), Library(), ChatBot(), Profile()];

  int currentPage = 0;

  changePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 120,
        // margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 46, 48, 97)
                  : Color.fromARGB(255, 210, 209, 224),
          borderRadius: BorderRadius.circular(15),
          // color: Color.fromARGB(255, 210, 209, 224),
          boxShadow: [
            BoxShadow(
              color:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 46, 48, 97)
                      : Color.fromARGB(255, 210, 209, 224),
              offset: Offset(0, -1),
              spreadRadius: 0,
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: GNav(
            curve: Curves.easeOutExpo,
            duration: Duration(milliseconds: 200),
            gap: 2,
            color:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 46, 48, 97),
            // color: Color.fromARGB(255, 210, 209, 224),
            activeColor:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 46, 48, 97)
                    : Color.fromARGB(255, 210, 209, 224),

            // Color.fromARGB(255, 210, 209, 224),
            iconSize: 26,
            tabBackgroundColor:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 210, 209, 224)
                    : Color.fromARGB(255, 46, 48, 97),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            onTabChange: (index) {
              changePage(index);
            },
            tabs: [
              ...List.generate(page.length, (index) {
                return GButton(
                  text: pageName[index]["Name"],

                  icon: pageName[index]["Icon"],
                );
              }),
            ],
          ),
        ),
      ),
      body: page.elementAt(currentPage),
    );
  }
}

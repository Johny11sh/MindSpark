import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/FontGlobals.dart';

Widget settingsCard(
  int index,
  ThemeController themeController,
  BuildContext context,
  List<Map<String, dynamic>> Data,
) {
  final List<Map<String, dynamic>> cardData = Data;

  return InkWell(
    onTap: cardData[index]['onTap'],
    child: Card(
      color:
          themeController.initialTheme == Themes.customLightTheme
              ? Color.fromARGB(255, 40, 41, 61)
              : Color.fromARGB(255, 210, 209, 224),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Icon(
              cardData[index]['icon'] as IconData,
              size: 25,
              color:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 40, 41, 61),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              alignment: Alignment.centerLeft,
              child: Text(
                "${cardData[index]['title']}".tr,
                style: TextStyle(
                  fontFamily: globalFontFamily,
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 20
                          : 20 - (globalFontSizeChange / 5),
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color:
                      themeController.initialTheme == Themes.customLightTheme
                          ? Color.fromARGB(255, 210, 209, 224)
                          : Color.fromARGB(255, 40, 41, 61),
                ),
              ),
            ),
          ),
          Expanded(
            child: Icon(
              Icons.arrow_forward_ios_outlined,
              size: 17,
              color:
                  themeController.initialTheme == Themes.customLightTheme
                      ? Color.fromARGB(255, 210, 209, 224)
                      : Color.fromARGB(255, 40, 41, 61),
            ),
          ),
        ],
      ),
    ),
  );
}

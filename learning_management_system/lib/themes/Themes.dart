// ignore_for_file: use_full_hex_values_for_flutter_colors, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';

class Themes {
  Color DeepBlue = const Color.fromARGB(255, 46, 48, 97);
  Color DarkSlate = const Color.fromARGB(255, 40, 41, 61);
  Color MutedPurple = const Color.fromARGB(255, 85, 81, 132);
  Color LavenderGray = const Color.fromARGB(255, 153, 151, 188);
  Color SoftViolet = const Color.fromARGB(255, 210, 209, 224);
  Color PalePeach = const Color.fromARGB(255, 254, 233, 204);

  static ThemeData customDarkTheme = ThemeData().copyWith(
    textTheme: TextTheme(
      bodySmall: TextStyle(
          fontSize: 15,
          color: Color.fromARGB(255, 210, 209, 224)),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 40, 41, 61),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 85, 81, 132),
      foregroundColor: Color.fromARGB(255, 40, 41, 61),
      elevation: 6,
      shadowColor: Color.fromARGB(255, 254, 233, 204),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(255, 210, 209, 224),
      ),
      iconTheme: IconThemeData(
        size: 25,
        color: Color.fromARGB(255, 210, 209, 224),
      ),
    ),
    disabledColor: const Color.fromARGB(255, 210, 209, 224),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 40, 41, 61),
      elevation: 6,
      selectedIconTheme: IconThemeData(
        size: 25,
        weight: 8,
        color: Color.fromARGB(255, 46, 48, 97),
      ),
      unselectedIconTheme: IconThemeData(
        size: 20,
        weight: 6,
        color: Color.fromARGB(255, 189, 189, 189),
      ),
      selectedLabelStyle: TextStyle(
        color: Color.fromARGB(255, 46, 48, 97),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        color: Color.fromARGB(255, 189, 189, 189),
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: false,
    ),
    cardTheme: const CardTheme(
      margin: EdgeInsets.all(8),
      color: Color.fromARGB(255, 40, 41, 61),
      surfaceTintColor: Color.fromARGB(255, 153, 151, 188),
      elevation: 4,
      shadowColor: Color.fromARGB(255, 210, 209, 224),
    ),
  );

  static ThemeData customLightTheme = ThemeData().copyWith(
    textTheme: TextTheme(
      bodySmall: TextStyle(
          fontSize: 15,
          color: Color.fromARGB(255, 40, 41, 61)),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 210, 209, 224),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 40, 41, 61),
      foregroundColor: Color.fromARGB(255, 210, 209, 224),
      elevation: 6,
      shadowColor: Color.fromARGB(255, 46, 48, 97),
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: Color.fromARGB(255, 210, 209, 224),
      ),
      iconTheme: IconThemeData(
        size: 25,
        color: Color.fromARGB(255, 210, 209, 224),
      ),
    ),
    disabledColor: const Color.fromARGB(255, 153, 151, 188),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 210, 209, 224),
      elevation: 6,
      selectedIconTheme: IconThemeData(
        size: 30,
        weight: 10,
        color: Color.fromARGB(255, 40, 41, 61),
      ),
      unselectedIconTheme: IconThemeData(
        size: 20,
        weight: 6,
        color: Color.fromARGB(255, 85, 81, 132),
      ),
      selectedLabelStyle: TextStyle(
        color: Color.fromARGB(255, 40, 41, 61),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        color: Color.fromARGB(255, 85, 81, 132),
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: false,
    ),
    cardTheme: const CardTheme(
      margin: EdgeInsets.all(8),
      color: Color.fromARGB(255, 210, 209, 224),
      surfaceTintColor: Color.fromARGB(255, 85, 81, 132),
      elevation: 4,
      shadowColor: Color.fromARGB(255, 40, 41, 61),
    ),
  );
}

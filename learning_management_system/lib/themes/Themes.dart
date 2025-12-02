// ignore_for_file: use_full_hex_values_for_flutter_colors, non_constant_identifier_names, file_names

import 'package:flutter/material.dart';

import '../core/constants/FontGlobals.dart';

class Themes {
  Color DeepBlue = const Color.fromARGB(255, 46, 48, 97);
  Color DarkSlate = const Color.fromARGB(255, 40, 41, 61);
  Color MutedPurple = const Color.fromARGB(255, 85, 81, 132);
  Color LavenderGray = const Color.fromARGB(255, 153, 151, 188);
  Color SoftViolet = const Color.fromARGB(255, 210, 209, 224);
  Color PalePeach = const Color.fromARGB(255, 254, 233, 204);

  Color DarkTeal = Color.fromARGB(255, 32, 34, 80);
  Color DeepIndigo = Color.fromARGB(255, 55, 48, 107);
  Color RichBurgundy = Color.fromARGB(255, 120, 40, 80);
  Color DarkEmerald = Color.fromARGB(255, 25, 80, 60);
  Color DeepCoral = Color.fromARGB(255, 180, 60, 80);
  Color MidnightBlue = Color.fromARGB(255, 20, 30, 60);
  Color DarkViolet = Color.fromARGB(255, 70, 40, 90);
  Color DeepRust = Color.fromARGB(255, 100, 50, 40);

  // New softer colors
  Color SoftCream = Color.fromARGB(255, 252, 248, 240);
  Color WarmBeige = Color.fromARGB(255, 245, 242, 235);
  Color GentleGray = Color.fromARGB(255, 240, 238, 235);
  Color SoftBlue = Color.fromARGB(255, 235, 240, 250);
  Color MutedGreen = Color.fromARGB(255, 230, 245, 235);
  Color SoftPink = Color.fromARGB(255, 250, 235, 240);

  // Enhanced blue colors for watchlist dark theme
  Color WatchlistDarkBlue = Color.fromARGB(255, 15, 25, 45);
  Color WatchlistMidBlue = Color.fromARGB(255, 25, 35, 55);
  Color WatchlistLightBlue = Color.fromARGB(255, 35, 45, 65);
  Color WatchlistAccentBlue = Color.fromARGB(255, 70, 130, 180);
  Color WatchlistBrightBlue = Color.fromARGB(255, 100, 150, 200);
  Color WatchlistSoftBlue = Color.fromARGB(255, 120, 160, 220);
  Color WatchlistTextBlue = Color.fromARGB(255, 180, 200, 240);
  Color WatchlistBorderBlue = Color.fromARGB(255, 50, 70, 100);

  // Additional beautiful blue variations
  Color WatchlistOceanBlue = Color.fromARGB(255, 30, 60, 90);
  Color WatchlistSkyBlue = Color.fromARGB(255, 135, 206, 235);
  Color WatchlistNavyBlue = Color.fromARGB(255, 25, 25, 112);
  Color WatchlistRoyalBlue = Color.fromARGB(255, 65, 105, 225);
  Color WatchlistSteelBlue = Color.fromARGB(255, 70, 130, 180);
  Color WatchlistLightSteelBlue = Color.fromARGB(255, 176, 196, 222);

  // Enhanced light theme colors for watchlist
  Color WatchlistLightGradient1 = Color.fromARGB(255, 240, 238, 250);
  Color WatchlistLightGradient2 = Color.fromARGB(255, 220, 215, 240);
  Color WatchlistLightCard = Color.fromARGB(255, 255, 255, 255);
  Color WatchlistLightBorder = Color.fromARGB(255, 200, 195, 220);
  Color WatchlistLightAccent = Color.fromARGB(255, 100, 95, 150);
  Color WatchlistLightText = Color.fromARGB(255, 60, 55, 85);
  Color WatchlistLightSecondary = Color.fromARGB(255, 120, 115, 160);

  static ThemeData customDarkTheme = ThemeData().copyWith(
    scaffoldBackgroundColor: const Color.fromARGB(255, 40, 41, 61),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 85, 81, 132),
      foregroundColor: const Color.fromARGB(255, 40, 41, 61),
      elevation: 6,
      shadowColor: const Color.fromARGB(255, 254, 233, 204),
      titleTextStyle: TextStyle(
        fontSize:
            globalFontSizeChange <= 17
                ? (globalFontSizeChange / 5) + 22
                : 22 - (globalFontSizeChange / 5),
        fontWeight: FontWeight.w500,
        color: const Color.fromARGB(255, 210, 209, 224),
      ),
      iconTheme: const IconThemeData(
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
        fontSize:
            globalFontSizeChange <= 17
                ? (globalFontSizeChange / 5) + 16
                : 16 - (globalFontSizeChange / 5),
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        color: Color.fromARGB(255, 189, 189, 189),
        fontSize:
            globalFontSizeChange <= 17
                ? (globalFontSizeChange / 5) + 12
                : 12 - (globalFontSizeChange / 5),
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
    scaffoldBackgroundColor: const Color.fromARGB(255, 210, 209, 224),
    appBarTheme: AppBarTheme(
      backgroundColor: Color.fromARGB(255, 40, 41, 61),
      foregroundColor: Color.fromARGB(255, 210, 209, 224),
      elevation: 6,
      shadowColor: Color.fromARGB(255, 46, 48, 97),
      titleTextStyle: TextStyle(
        fontSize:
            globalFontSizeChange <= 17
                ? (globalFontSizeChange / 5) + 22
                : 22 - (globalFontSizeChange / 5),
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
        fontSize:
            globalFontSizeChange <= 17
                ? (globalFontSizeChange / 5) + 16
                : 16 - (globalFontSizeChange / 5),
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        color: Color.fromARGB(255, 85, 81, 132),
        fontSize:
            globalFontSizeChange <= 17
                ? (globalFontSizeChange / 5) + 12
                : 12 - (globalFontSizeChange / 5),
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

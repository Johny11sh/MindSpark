// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../themes/Themes.dart';
import '../../view/NavBar.dart';
import '../constants/FontGlobals.dart';

Widget buildRatingBar(
  int rating,
  bool areBarsVisible,
  Map<String, dynamic> data,
) {
  final ratingBreakdown = data;
  final totalReviews =
      (int.tryParse(ratingBreakdown["5"].toString()) ?? 0) +
      (int.tryParse(ratingBreakdown["4"].toString()) ?? 0) +
      (int.tryParse(ratingBreakdown["3"].toString()) ?? 0) +
      (int.tryParse(ratingBreakdown["2"].toString()) ?? 0) +
      (int.tryParse(ratingBreakdown["1"].toString()) ?? 0);

  final count =
      int.tryParse(ratingBreakdown[rating.toString()].toString()) ?? 0;
  final percent = totalReviews > 0 ? count / totalReviews : 0.0;
  return AnimatedContainer(
    duration: Duration(milliseconds: 400 + (rating * 100)),
    curve: Curves.easeInOutBack,
    margin: EdgeInsets.symmetric(vertical: 4),
    transform: Matrix4.translationValues(areBarsVisible ? 0 : 250, 0, 0),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(20, 40, 41, 61)
                  : Color.fromARGB(20, 210, 209, 224),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 600),
                opacity: 1.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // AnimatedContainer(
                      //   duration: Duration(milliseconds: 500),
                      //   curve: Curves.elasticOut,
                      //   child: Icon(Icons.star, color: Colors.amber, size: 16),
                      // ),
                      // SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rating == 5
                              ? "Excellent".tr
                              : rating == 4
                              ? "Good".tr
                              : rating == 3
                              ? "Average".tr
                              : rating == 2
                              ? "Below Average".tr
                              : "Poor".tr,
                          style: TextStyle(
                            fontFamily: globalFontFamily,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                            fontSize:
                                globalFontSizeChange <= 17
                                    ? (globalFontSizeChange / 5) + 15
                                    : 15 - (globalFontSizeChange / 5),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeOutQuart,
                    height: 10,
                    decoration: BoxDecoration(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(100, 210, 209, 224)
                              : Color.fromARGB(100, 40, 41, 61),
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 1000 + (rating * 200)),
                        curve: Curves.elasticOut,
                        width: percent * constraints.maxWidth,
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade600,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child:
                            percent > 0.1
                                ? Align(
                                  alignment: Alignment.centerRight,
                                  child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 800),
                                    opacity: percent > 0.3 ? 1.0 : 0.0,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      margin: EdgeInsets.only(right: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                )
                                : null,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              flex: 1,
              child: AnimatedScale(
                duration: Duration(milliseconds: 600),
                scale: 1.0,
                curve: Curves.elasticOut,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          themeController.initialTheme ==
                                  Themes.customLightTheme
                              ? Color.fromARGB(40, 40, 41, 61)
                              : Color.fromARGB(40, 210, 209, 224),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontFamily: globalFontFamily,
                        color:
                            themeController.initialTheme ==
                                    Themes.customLightTheme
                                ? Color.fromARGB(255, 40, 41, 61)
                                : Color.fromARGB(255, 210, 209, 224),
                        fontSize:
                            globalFontSizeChange <= 17
                                ? (globalFontSizeChange / 5) + 13
                                : 13 - (globalFontSizeChange / 5),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

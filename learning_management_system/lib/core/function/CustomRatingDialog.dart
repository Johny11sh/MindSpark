// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants/ImageAssets.dart';
import 'package:rating_dialog/rating_dialog.dart';
import '../../themes/Themes.dart';
import '../../view/NavBar.dart';
import '../constants/FontGlobals.dart';

List<Map<String, dynamic>> newRatingData = [];
Map<String, dynamic> newRatingsBreakingDown = {};
double userRating = 0;
String? newRating;
String? userReview;
bool isCreated = true;

void showRatingDailog(
  BuildContext context,
  int courseId,
  String token,
  String url,
  VoidCallback onRated,
  var rating,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (context) => RatingDialog(
          initialRating: rating,
          // your app's name?
          title: Text(
            'Rating Dialog'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 25
                      : 25 - (globalFontSizeChange / 5),
              fontWeight: FontWeight.bold,
              fontFamily: globalFontFamily,
            ),
          ),
          // encourage your user to leave a high rating?
          message: Text(
            'Tap a star to set your rating. Add more description here if you want.'
                .tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  globalFontSizeChange <= 17
                      ? (globalFontSizeChange / 5) + 15
                      : 15 - (globalFontSizeChange / 5),
              fontFamily: globalFontFamily,
            ),
          ),
          // your app's logo?
          image: Image.asset(ImageAssets.AppLogo, height: 160),
          submitButtonText: 'Submit'.tr,
          submitButtonTextStyle: TextStyle(
            color:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),

            fontSize:
                globalFontSizeChange <= 17
                    ? (globalFontSizeChange / 5) + 17
                    : 17 - (globalFontSizeChange / 5),
          ),

          commentHint: 'Enter Your Rating'.tr,
          onCancelled: () => print('cancelled'),
          onSubmitted: (response) {
            print('rating: ${response.rating}, comment: ${response.comment}');

            submitRating(
              courseId,
              response.rating,
              response.comment,
              token,
              url,
              onRated,
            );
          },
        ),
  );
}

submitRating(
  int courseId,
  double rating,
  String? comment,
  String token,
  String url,
  VoidCallback onRated,
) async {
  var response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': "Bearer $token",
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    },
    body: json.encode({"rating": rating, "review": comment}),
  );
  if (response.statusCode == 200) {
    var responseBody = json.decode(response.body);
    print(responseBody);

    final List<dynamic> newRatingDataList =
        responseBody is List
            ? responseBody
            : (responseBody['featuredRatings'] ?? [responseBody]);
    newRatingData = List<Map<String, dynamic>>.from(newRatingDataList);
    newRatingsBreakingDown = responseBody['rating_breakdown'] ?? {};
    isCreated = responseBody['created'];
    userReview = comment.toString();
    userRating = rating.toDouble();
    newRating =
        (responseBody['courseRating'] != null)
            ? responseBody['courseRating'].toString()
            : (responseBody['resourceRating'] != null)
            ? responseBody['resourceRating'].toString()
            : (responseBody['teacherRating'] != null)
            ? responseBody['teacherRating'].toString()
            : responseBody['lectureRating'].toString();
    print(newRatingData);
    print(newRatingsBreakingDown);
    print(newRating);
    print(userRating);
    print(userReview);
    print(isCreated);
    Get.snackbar("Success".tr, "Rating submitted successfully".tr);

    onRated();
  } else {
    print("fail");
    Get.snackbar("Error".tr, "Failed to submit rating".tr);
  }
}

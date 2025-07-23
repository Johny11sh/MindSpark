import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/core/constants/ImageAssets.dart';
import 'package:rating_dialog/rating_dialog.dart';

import '../../themes/Themes.dart';
import '../../view/NavBar.dart';

void showRatingDailog(BuildContext context, int courseId,String token,String url,  VoidCallback onRated,var rating) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder:
        (context) => RatingDialog(

          initialRating:rating,
          // your app's name?
          title: Text(
            'Rating Dialog'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          // encourage your user to leave a high rating?
          message: Text(
            'Tap a star to set your rating. Add more description here if you want.'
                .tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          // your app's logo?
          image: Image.asset(ImageAssets.AppLogo, height: 160),
          submitButtonText: 'Submit',
          submitButtonTextStyle: TextStyle(
            color:
                themeController.initialTheme == Themes.customLightTheme
                    ? Color.fromARGB(255, 40, 41, 61)
                    : Color.fromARGB(255, 210, 209, 224),

            fontSize: 17,
          ),

          commentHint: 'Enter Your Rating',
          onCancelled: () => print('cancelled'),
          onSubmitted: (response) {
            print('rating: ${response.rating}, comment: ${response.comment}');

            submitRating(courseId, response.rating, response.comment,token,url,onRated);
          },
        ),
  );
}

submitRating(
  int courseId,
  double rating,
  String? comment,
  String token,
  String url, VoidCallback onRated,
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
    onRated();
  } else {
    var responseBody = json.decode(response.body);
    print(responseBody);
    print("fail");
    Get.snackbar("Error", "Failed to submit rating");
  }
}


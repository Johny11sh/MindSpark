// ignore_for_file: file_names, avoid_print, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/FontGlobals.dart';
import '../services/SharedPrefs.dart';
import '../view/NavBar.dart';

class LikesController extends GetxController {
  late SharedPrefs sharedPrefs;

  late String token;
  late bool isLiked;
  late bool isDisliked;
  late bool isHelpful;
  late bool isUnhelpful;

  late int likesCount;
  late int dislikesCount;
  late int helpfulCount;
  late int unhelpfulCount;
  late int viewsCount;

  Future<Map<String, dynamic>?> reportReview(
    String type,
    String reviewID,
    List reasons,
    String? message,
  ) async {
    try {
      final token = sharedPrefs.prefs.getString('token') ?? '';
      if (token.isEmpty) {
        debugPrint("No token found, already logged out");
        return null;
      }

      var baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: mainIP,
      );
      final APIurl = '$baseUrl/api/report';

      final response = await http
          .post(
            Uri.parse(APIurl),
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              type: reviewID,
              'reasons': reasons,
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
        "Subscription confirmation API response: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Get.rawSnackbar(
          messageText: Text(
            "Your report has been sent successfully".tr,
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          isDismissible: true,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          icon: const Icon(Icons.check, color: Colors.white, size: 35),
          margin: const EdgeInsets.all(5),
          borderRadius: 5,
          borderColor: Colors.green[700]!,
        );
      } else {
        final data = json.decode(response.body);
        Get.rawSnackbar(
          title: "Failed to send the report".tr,
          messageText: Text(
            data['message'].toString().tr,
            style: TextStyle(fontFamily: globalFontFamily),
          ),
          isDismissible: true,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          icon: const Icon(
            Icons.priority_high_outlined,
            color: Colors.white,
            size: 35,
          ),
          margin: const EdgeInsets.all(5),
          borderRadius: 5,
          borderColor: Colors.grey[700]!,
        );
      }
    } on http.ClientException catch (e) {
      print("Network error: ${e.message}");
      Get.snackbar(
        "Network Error".tr,
        "Could not connect to the server. Please check your connection.".tr,
      );
    } on TimeoutException catch (_) {
      Get.snackbar(
        "Timeout".tr,
        "The request took too long. Please try again.".tr,
      );
    } on FormatException catch (_) {
      Get.snackbar("Error".tr, "Invalid server response".tr);
    } catch (e) {
      print("Unexpected error: $e");
      Get.snackbar("Error".tr, "An unexpected error occurred".tr);
    }
    return null;
  }

  Future<void> toggleLikes(String id) async {
    final url = Uri.parse('$mainIP/api/togglelike');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'lecture_id': id}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      likesCount = data['likes'];
      dislikesCount = data['dislikes'];
      isLiked = data['isLiked'];
      isDisliked = data['isDisliked'];
      update();
    } else {
      print('Error : ${response.body}');
    }
  }

  Future<void> toggleDisLikes(String id) async {
    final url = Uri.parse('$mainIP/api/toggledislike');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'lecture_id': id}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      likesCount = data['likes'];
      dislikesCount = data['dislikes'];
      isLiked = data['isLiked'];
      isDisliked = data['isDisliked'];
      update();
    } else {
      print('Error : ${response.body}');
    }
  }

  Future<void> toggleHelpful(Map<String, dynamic> message) async {
    final url = Uri.parse('$mainIP/api/togglehelpful');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      helpfulCount = data['helpfulCount'];
      unhelpfulCount = data['unhelpfulCount'];
      isHelpful = data['isHelpful'];
      isUnhelpful = data['isUnhelpful'];
      print(jsonEncode(message));

      update();
    } else {
      print('Error : ${response.body}');
    }
  }

  Future<void> toggleUnhelpful(Map<String, dynamic> message) async {
    final url = Uri.parse('$mainIP/api/toggleunhelpful');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      helpfulCount = data['helpfulCount'];
      unhelpfulCount = data['unhelpfulCount'];
      isHelpful = data['isHelpful'];
      isUnhelpful = data['isUnhelpful'];
      print(jsonEncode(message));

      update();
    } else {
      print('Error : ${response.body}');
    }
  }

  @override
  void onInit() {
    super.onInit();
    sharedPrefs = SharedPrefs.instance;
    token = sharedPrefs.prefs.getString("token") ?? "";
    // print(token);
  }
}

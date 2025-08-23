// ignore_for_file: file_names, avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/CFavoriteModel.dart';
import '../model/TFavoriteModel.dart';
import '../services/SharedPrefs.dart';
import 'package:http/http.dart' as http;
import '../view/NavBar.dart';

class ViewFavoriteController extends GetxController {
  bool loading = true;
  bool loading2 = true;

  List<TFavoriteModel> tFav = [];
  List<CFavoriteModel> cFav = [];

  late String token;

  late SharedPrefs sharedPrefs;

  String favCh = "teacher";

  change(val) {
    favCh = val;
    update();
  }

  getTFavorite() async {
    tFav.clear();
    var response = await http.get(
      Uri.parse("$mainIP/api/getfavoriteteachers"),
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("response statusCode = ${response.statusCode}");
      var responseBody = jsonDecode(response.body);
      List responseData = responseBody["favorites"];
      print(responseData);
      tFav.addAll(responseData.map((e) => TFavoriteModel.fromJson(e)));
      loading = false;
      update();
    } else {
      Get.defaultDialog(
        title: "Error".tr,
        backgroundColor: Colors.red,
        middleText: "Check Connections".tr,
      );
      Get.snackbar(
        "Error".tr,
        "Check Connections".tr,
        backgroundColor: Colors.red,
      );
    }
  }

  getCFavorite() async {
    cFav.clear();
    var response = await http.get(
      Uri.parse("$mainIP/api/getfavoritecourses"),
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print("response statusCode = ${response.statusCode}");
      var responseBody = jsonDecode(response.body);
      List responseData = responseBody["favorites"];
      cFav.addAll(responseData.map((e) => CFavoriteModel.fromJson(e)));
      loading2 = false;
      update();
    } else {
      Get.defaultDialog(
        title: "Error".tr,
        backgroundColor: Colors.red,
        middleText: "Check Connections".tr,
      );
      Get.snackbar(
        "Error".tr,
        "Check Connections".tr,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    sharedPrefs = SharedPrefs.instance;
    token = sharedPrefs.prefs.getString("token")!;
    print(token);
    getTFavorite();
    // getCFavorite();
  }
}

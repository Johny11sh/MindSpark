import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:learning_management_system/main.dart';

import '../services/SharedPrefs.dart';
import '../view/NavBar.dart';

class FavoriteController extends GetxController {
  late SharedPrefs sharedPrefs;

  late String token;

  Map isFavorite = {};

  Future<void> toggleFavorite(String id) async {
    final url = Uri.parse('$mainIP/api/teacher/$id/favorite');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      isFavorite[id] = data['is_favorited'];
      update();
    } else {
      print('Error : ${response.body}');
    }
  }

  Future<void> getTFavorite() async {
    final response = await http.get(
      Uri.parse("$mainIP/api/getfavoriteteachers"),
      headers: {
        'Authorization': "Bearer $token",
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("response statusCode = ${response.statusCode}");
      final responseBody = jsonDecode(response.body);

      final List favorites = responseBody["favorites"];

      for (var teacher in favorites) {
        final String id = teacher["id"].toString();
        isFavorite[id] = true;
      }
      update();
    } else {
      Get.defaultDialog(
        title: "Error",
        backgroundColor: Colors.red,
        middleText: "Check Connections",
      );
      Get.snackbar("Error", "Check Connections", backgroundColor: Colors.red);
    }
  }

  @override
  void onInit() {
    super.onInit();
    sharedPrefs = SharedPrefs.instance;
    token = sharedPrefs.prefs.getString("token")!;
    print(token);
    getTFavorite();
  }
}

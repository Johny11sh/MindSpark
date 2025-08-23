// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/FontController.dart';
import '../constants/ImageAssets.dart';
import 'package:lottie/lottie.dart';

Widget noDataLottie([String? textTitle]) {
  return Center(
    child: Column(
      children: [
        Lottie.asset(ImageAssets.noDataLottie, width: 250, height: 250),
        Text(
          textTitle?.tr ?? "",
          style: TextStyle(fontFamily: FontController().currentFontFamily),
        ),
      ],
    ),
  );
}

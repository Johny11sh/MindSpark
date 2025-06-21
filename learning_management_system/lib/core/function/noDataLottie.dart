import 'package:flutter/material.dart';
import 'package:learning_management_system/core/constants/ImageAssets.dart';
import 'package:lottie/lottie.dart';

Widget noDataLottie([String? textTitle]) {
  return Center(
    child: Column(
      children: [
        Lottie.asset(ImageAssets.noDataLottie, width: 250, height: 250),
        Text(textTitle?? ""),
      ],
    ),
  );
}

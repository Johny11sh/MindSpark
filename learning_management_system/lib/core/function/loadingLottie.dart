import 'package:flutter/material.dart';
import 'package:learning_management_system/core/constants/ImageAssets.dart';
import 'package:lottie/lottie.dart';

Widget loadingLottie() {
  return Center(
    child: Lottie.asset(ImageAssets.loadingLottie, width: 250, height: 250),
  );
}

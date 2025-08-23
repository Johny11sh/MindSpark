// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../constants/ImageAssets.dart';
import 'package:lottie/lottie.dart';

Widget loadingLottie() {
  return Center(
    child: Lottie.asset(ImageAssets.loadingLottie, width: 250, height: 250),
  );
}

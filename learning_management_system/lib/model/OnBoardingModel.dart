// ignore_for_file: file_names

import 'package:get/get.dart';

class OnBoardingModel {
  final String? title;
  final String? subtitle;
  final String? image;
  final String? body;

  OnBoardingModel({
    String? title,
    String? subtitle,
    String? image,
    String? body,
  }) : title = title?.tr,
       subtitle = subtitle?.tr,
       image = image,
       body = body?.tr;
}

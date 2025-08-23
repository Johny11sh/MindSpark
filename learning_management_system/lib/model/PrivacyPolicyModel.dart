// ignore_for_file: file_names

import 'package:get/get.dart';

class PrivacyPolicyModel {
  final String? title;
  final String? subtitle;

  PrivacyPolicyModel({String? title, String? subtitle})
    : title = title?.tr,
      subtitle = subtitle?.tr;
}

// ignore_for_file: file_names

import 'package:get/get.dart';

class FaqModel {
  final String question;
  final String answer;

  FaqModel({required String question, required String answer})
    : question = question.tr,
      answer = answer.tr;
}

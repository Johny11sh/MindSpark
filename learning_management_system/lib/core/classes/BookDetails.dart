// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
// import '../constants/ImageAssets.dart';

class BookDetails extends StatefulWidget {
  final Map<String, dynamic> BookData;
  final Uint8List? bookImage;

  const BookDetails({
    super.key,
   required this.BookData,
    required this.bookImage});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    Uint8List? imageBytes = widget.bookImage;

    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Book Details".tr), centerTitle: true),
        body:
            widget.BookData == null || widget.BookData.isEmpty
                ? Center(
                  child: CircularProgressIndicator(
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 40, 41, 61)
                            : Color.fromARGB(255, 210, 209, 224),
                  ),
                )
                : ListView(
                  scrollDirection: Axis.vertical,
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
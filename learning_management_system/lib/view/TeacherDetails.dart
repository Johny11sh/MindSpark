// ignore_for_file: non_constant_identifier_names, file_names, unnecessary_null_comparison

import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
// import '../controller/NetworkController.dart';
import '../core/constants/ImageAssets.dart';
import '../locale/LocaleController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherDetails extends StatelessWidget {
  final Map<String, dynamic> TeacherData;

  final Uint8List? teacherImage;

  const TeacherDetails({
    super.key,
    required this.TeacherData,
    required this.teacherImage,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LocaleController localeController = Get.find<LocaleController>();
    Uint8List? imageBytes = teacherImage;

    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Teacher Profile".tr), centerTitle: true),
        body:
            TeacherData == null || TeacherData.isEmpty
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
                        Container(
                          padding: EdgeInsets.only(top: 30),
                          alignment: Alignment.topCenter,
                          child:
                              imageBytes != null
                                  ? Image.memory(
                                    imageBytes,
                                    width: Get.width * (4 / 10),
                                    height: Get.width * (4 / 10),
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        ImageAssets.teacher,
                                        height: 125,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    ImageAssets.teacher,
                                    width: Get.width * (4 / 10),
                                    height: Get.width * (4 / 10),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "${TeacherData["name"]}".tr,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            color:
                                themeController.initialTheme ==
                                        Themes.customLightTheme
                                    ? Color.fromARGB(255, 40, 41, 61)
                                    : Color.fromARGB(255, 210, 209, 224),
                          ),
                        ),
                        SizedBox(height: 20),
                        Card(
                          // margin:EdgeInsets.all(3),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                              strokeAlign: BorderSide.strokeAlignOutside,
                              width: 3,
                              color:
                                  themeController.initialTheme ==
                                          Themes.customLightTheme
                                      ? Color.fromARGB(255, 40, 41, 61)
                                      : Color.fromARGB(255, 210, 209, 224),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "● Subjects:".tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                              Text(
                                {TeacherData["subjects"]}.isEmpty ||
                                        TeacherData["subjects"] == null
                                    ? "Non".tr
                                    : "\n  ${TeacherData["subjects"]}\n".tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                              Text(
                                "● Majors:".tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                              Text(
                                {TeacherData["universities"]}.isEmpty ||
                                        TeacherData["universities"] == null
                                    ? "Non".tr
                                    : "\n  ${TeacherData["universities"]}\n".tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 40, 41, 61)
                                          : Color.fromARGB(255, 210, 209, 224),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "● Number:".tr,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(255, 210, 209, 224),
                                    ),
                                  ),
                                  Text(
                                    {TeacherData["number"]}.isEmpty ||
                                            TeacherData["number"] == null
                                        ? "Non".tr
                                        : " 0${TeacherData["number"]}".tr,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(255, 210, 209, 224),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TeacherData["facebook"] == null
                                      ? SizedBox()
                                      : IconButton(
                                        onPressed: () async {
                                          _launchURL(TeacherData["facebook"]);
                                        },
                                        icon: Icon(
                                          Icons.facebook_rounded,
                                          size: 40,
                                          color:
                                              themeController.initialTheme ==
                                                      Themes.customLightTheme
                                                  ? Color.fromARGB(
                                                    255,
                                                    40,
                                                    41,
                                                    61,
                                                  )
                                                  : Color.fromARGB(255, 210, 209, 224)
                                        ),
                                      ),
                                  TeacherData["telegram"] == null
                                      ? SizedBox()
                                      : IconButton(
                                        onPressed: () async {
                                          _launchURL(TeacherData["telegram"]);
                                        },
                                        icon: Icon(
                                          Icons.telegram_rounded,
                                          size: 40,
                                          color:
                                              themeController.initialTheme ==
                                                      Themes.customLightTheme
                                                  ? Color.fromARGB(
                                                    255,
                                                    40,
                                                    41,
                                                    61,
                                                  )
                                                  : Color.fromARGB(255, 210, 209, 224),
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }
}

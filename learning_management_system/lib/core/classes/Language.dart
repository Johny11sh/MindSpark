// ignore_for_file: non_constant_identifier_names, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/ImageAssets.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();
  List Languages = [
    {"name": "English", "LangCode": "En", "flag": ImageAssets.EnglishFlag},
    {"name": "Arabic", "LangCode": "Ar", "flag": ImageAssets.ArabicFlag},
    {"name": "German", "LangCode": "De", "flag": ImageAssets.GermanFlag},
    {"name": "Spanish", "LangCode": "Es", "flag": ImageAssets.SpanishFlag},
    {"name": "French", "LangCode": "Fr", "flag": ImageAssets.FrenchFlag},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: localeController.initialLang,
      theme: themeController.initialTheme,
      home: Scaffold(
        appBar: AppBar(title: Text("Language".tr), centerTitle: true),
        body: Column(
          children: [
            SizedBox(height: 50),
            Text(
              "Choose application's language".tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color:
                    themeController.initialTheme == Themes.customLightTheme
                        ? Color.fromARGB(255, 40, 41, 61)
                        : Color.fromARGB(255, 210, 209, 224),
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: Languages.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            localeController.changeLang(
                              Languages[index]['LangCode'],
                            );
                          });
                        },
                        child: SizedBox(
                          height: 100,
                          child: Card(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CircleAvatar(
                                    backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                    child: Image.asset(
                                      Languages[index]["flag"]!,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "${Languages[index]["name"]}".tr,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.normal,
                                      color:
                                          themeController.initialTheme ==
                                                  Themes.customLightTheme
                                              ? Color.fromARGB(255, 40, 41, 61)
                                              : Color.fromARGB(
                                                255,
                                                210,
                                                209,
                                                224,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

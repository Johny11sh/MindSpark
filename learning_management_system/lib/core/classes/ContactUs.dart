// ignore_for_file: file_names, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers

// import 'package:everything/controller/NetworkController.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../locale/LocaleController.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/ImageAssets.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    String? whatsAppOriginUrl = "";
    String? whatsAppQuestionsUrl = "";
    String? telegramUrl = "";
    String? telegramOriginUrl = "";

    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
    }

    final ThemeController themeController = Get.find<ThemeController>();
    // final NetworkController networkController = Get.find<NetworkController>();
    final LocaleController localeController = Get.find<LocaleController>();
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Contact Us".tr), centerTitle: true),
        body: Column(
          children: [
            Padding(padding: EdgeInsets.all(30)),
            Center(
              child: Image.asset(ImageAssets.AppLogo, width: 180, height: 180),
            ),
            Padding(padding: EdgeInsets.all(20)),
            Container(
              width: Get.width,
              alignment: Alignment.center,
              child: Card(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: Get.width / 16),
                            Text(
                              "Announcements:".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: Get.width / 10),
                            whatsAppOriginUrl == null
                                ? SizedBox()
                                : IconButton(
                                  onPressed: () async {
                                    _launchURL(whatsAppOriginUrl);
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 35,
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: Get.width / 16),
                            Text(
                              "Announcements:".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: Get.width / 10),
                            telegramOriginUrl == null
                                ? SizedBox()
                                : IconButton(
                                  onPressed: () async {
                                    _launchURL(telegramOriginUrl);
                                  },
                                  icon: Icon(
                                    Icons.telegram_rounded,
                                    size: 35,
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: Get.width / 16),
                            Text(
                              "Support team:".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: Get.width / 10),
                            whatsAppQuestionsUrl == null
                                ? SizedBox()
                                : IconButton(
                                  onPressed: () async {
                                    _launchURL(whatsAppQuestionsUrl);
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 35,
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
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: Get.width / 16),
                            Text(
                              "Support team:".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: Get.width / 10),
                            telegramUrl == null
                                ? SizedBox()
                                : IconButton(
                                  onPressed: () async {
                                    _launchURL(telegramUrl);
                                  },
                                  icon: Icon(
                                    Icons.telegram_rounded,
                                    size: 35,
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
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

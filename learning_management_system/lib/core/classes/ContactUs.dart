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
    final LocaleController localeController = Get.find<LocaleController>();

    final bool isDark = themeController.initialTheme == Themes.customLightTheme;
    final Color bgColor = isDark
        ? const Color.fromARGB(255, 40, 41, 61)
        : const Color.fromARGB(255, 210, 209, 224);
    final Color fgColor = isDark
        ? const Color.fromARGB(255, 210, 209, 224)
        : const Color.fromARGB(255, 40, 41, 61);

    return Scaffold(
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30),
              height: 100,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: fgColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: Get.width / 8),
                        child: Text(
                          "Contact Us".tr,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: fgColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: fgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(30)),
                    Center(
                      child: Image.asset(ImageAssets.AppIconNoBackGround, width: 180, height: 180),
                    ),
                    Padding(padding: EdgeInsets.all(20)),
                    Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      child: Card(
                        color: bgColor,
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
                                        color: fgColor,
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
                                              color: fgColor,
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
                                        color: fgColor,
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
                                              color: fgColor,
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
                                        color: fgColor,
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
                                              color: fgColor,
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
                                        color: fgColor,
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
                                              color: fgColor,
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
            ),
          ],
        ),
      ),
    );
  }
}

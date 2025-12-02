// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../model/PrivacyPolicyModel.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/FontGlobals.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    String? editionDate = "August 20, 2025".tr;
    List<PrivacyPolicyModel> termsOfServiceList = [
      PrivacyPolicyModel(
        title: "1. Who We Are".tr,
        subtitle:
            "MindSpark is an educational app designed to help Syrian baccalaureate students (typically aged 17–18) manage and interact with academic content, courses, and school-provided resources. While currently operated without a formal company, we may partner with schools for broader deployment."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "2. Who Can Use MindSpark".tr,
        subtitle:
            "To use MindSpark, you must:\n\nBe at least 17 years old.\n\nRegister using a valid phone number, username, and password.\n\nAgree to these Terms and our Privacy Policy.\n\nMindSpark is intended for use within Syria."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "3. User Roles and Access".tr,
        subtitle:
            "a. Students\n\nView and subscribe to courses using the in-app currency “Sparky.”\n\nAccess lessons (PDFs/videos) after subscribing to a course.\n\nComplete quizzes to earn Sparkies.\n\nRate and comment on courses, teachers, lessons, and school resources.\n\nReport inappropriate or offensive content.\n\nb. Teachers (via web portal)\n\nUpload courses and lesson content (subject to admin approval).\n\nManage their own materials hosted on school-owned servers.\n\nc. Admins (via web portal)\n\nModerate reported content.\n\nWarn or ban users for violating these Terms.\n\nDelete user accounts upon request or when necessary."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "4. In-App Currency (Sparky)".tr,
        subtitle:
            "Sparkies are the app’s virtual currency used to subscribe to courses. You can earn them by:\n\nCompleting quizzes on subscribed courses.\n\nPurchasing them physically at your school’s library.\n\nSparkies have no monetary value outside the App and cannot be exchanged for real currency."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "5. Account Management".tr,
        subtitle:
            "You are responsible for keeping your username and password secure.\n\nYou may request deletion of your account by contacting an admin.\n\nAdmins may delete or ban accounts for misconduct or violation of these Terms."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "6. User Content & Conduct".tr,
        subtitle:
            "a. Content Ownership\n\nAll course materials uploaded by teachers remain their intellectual property but are hosted by the school’s infrastructure.\n\nStudent comments and ratings are part of the App’s content and may be removed or moderated if found inappropriate.\n\nb. Prohibited Content\n\nUsers must not upload, share, or post content that:\n\nIs abusive, offensive, or harassing.\n\nViolates the rights of others.\n\nContains spam, viruses, or harmful code.\n\nMisleads or impersonates others.\n\nAdmins reserve the right to remove any content or ban users who violate this policy."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "7. Reporting & Moderation".tr,
        subtitle:
            "Users can report comments they find offensive.\n\nAdmins review reports and may choose to warn or ban the reported user.\n\nDecisions by admins are final."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "8. Privacy & Data Collection".tr,
        subtitle:
            "We only collect your phone number and username.\n\nNo third-party services or advertising tools are integrated.\n\nAll user data is stored securely on a school-owned SQLite server.\n\nFor more details, please refer to our Privacy Policy."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "9. Limitation of Liability".tr,
        subtitle:
            "MindSpark is an educational aid and does not guarantee academic performance.\n\nWe are not liable for any loss of data, access issues, or damages arising from use of the App.\n\nThe App and its content are provided “as is” without warranties."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "10. Modifications".tr,
        subtitle:
            "We may update these Terms from time to time. We will notify users via the App or website. Continued use of the App after changes means you accept the new Terms."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "11. Contact Us".tr,
        subtitle:
            "For questions, concerns, or account issues, contact your school’s appointed administrator or email us at: [Insert contact email]"
                .tr,
      ),
    ];

    final ThemeController themeController = Get.find<ThemeController>();
    // final LocaleController localeController = Get.find<LocaleController>();

    final bool isDark = themeController.initialTheme == Themes.customLightTheme;
    final Color bgColor =
        isDark
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 210, 209, 224);
    final Color fgColor =
        isDark
            ? const Color.fromARGB(255, 210, 209, 224)
            : const Color.fromARGB(255, 40, 41, 61);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
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
                        icon: Icon(Icons.arrow_back, color: fgColor),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: Get.width / 8),
                          child: Text(
                                "Privacy Policy".tr,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily: globalFontFamily,

                                  color: fgColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      globalFontSizeChange <= 17
                                          ? (globalFontSizeChange / 5) + 23
                                          : 23 - (globalFontSizeChange / 5),
                                ),
                              )
                              .animate(
                                onPlay: (controller) => controller.loop(),
                              )
                              .shimmer(
                                delay: Duration(seconds: 4),
                                duration: 800.ms,
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Colors.grey.shade700
                                        : Colors.white54,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Effective Date: $editionDate".tr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontFamily: globalFontFamily,
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                  fontSize:
                      globalFontSizeChange <= 17
                          ? (globalFontSizeChange / 5) + 20
                          : 20 - (globalFontSizeChange / 5),
                ),
              ),
              // const SizedBox(height: 25),
              // Text(
              //   "Welcome to MindSpark. These Terms of Service (\"Terms\") govern your use of the MindSpark mobile application (the \"App\") and its associated services. By using MindSpark, you agree to these Terms. If you do not agree, please do not use the App."
              //       .tr,
              //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
              //     fontFamily: globalFontFamily,
              //     color: fgColor,
              //     fontWeight: FontWeight.w600,
              //     fontSize:
              //         globalFontSizeChange <= 17
              //             ? (globalFontSizeChange / 5) + 20
              //             : 20 - (globalFontSizeChange / 5),
              //   ),
              // ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: fgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: termsOfServiceList.length,
                      itemBuilder:
                          (context, i) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(height: 30),
                              Text(
                                termsOfServiceList[i].title!.tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: globalFontFamily,
                                  color: bgColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      globalFontSizeChange <= 17
                                          ? (globalFontSizeChange / 5) + 22
                                          : 22 - (globalFontSizeChange / 5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  termsOfServiceList[i].subtitle!.tr,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: globalFontFamily,
                                    color: bgColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize:
                                        globalFontSizeChange <= 17
                                            ? (globalFontSizeChange / 5) + 18
                                            : 18 - (globalFontSizeChange / 5),
                                  ),
                                ),
                              ),
                              if (i < termsOfServiceList.length - 1)
                                const Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Divider(height: 30, thickness: 1),
                                ),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

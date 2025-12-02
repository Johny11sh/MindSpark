// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../model/PrivacyPolicyModel.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/FontGlobals.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    String? editionDate = "August 20, 2025".tr;
    List<PrivacyPolicyModel> privacyPolicyList = [
      PrivacyPolicyModel(
        title: "1. Information We Collect".tr,
        subtitle:
            "We collect the following information when you use MindSpark:\n\nPersonal Information: Your username (which can be randomly generated) and phone number, which you provide when creating an account. You may choose to use a pseudonym or a non-personal phone number, as these are not verified.\n\nApp Usage Data: Information about the courses you subscribe to, quiz scores, task progress, and in-app currency earned through quizzes. This data is used to personalize your learning experience and recommend relevant courses."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "2. How We Use Your Information".tr,
        subtitle:
            "We use your information to:\n\nProvide access to courses, quizzes, and tasks within the app.\n\nDisplay your quiz scores and task progress in your profile.\n\nRecommend courses based on your subscribed courses.\n\nManage your in-app currency earned through quiz completion.\n\nImprove the app’s functionality and user experience.\n\nWe do not use your information for marketing or any purposes beyond what is necessary to operate the app."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "3. Data Storage and Security".tr,
        subtitle:
            "Storage: Some data (such as your language preference, theme, and font settings) is stored locally on your device. Other user data, including your phone number, course subscriptions, quiz scores, task progress, and in-app currency, is stored securely on a school-owned server.\n\nSecurity: We use Laravel's built-in encryption and Blade for secure API routes to protect data transmitted between the app and its backend. While we take reasonable measures to safeguard your information, no system is completely secure. You are responsible for maintaining the security of your device.\n\nOffline Access: The app uses caching to store course and lecture content on your device for offline access. This cached data is only accessible within the app and is not shared externally."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "4. Data Sharing".tr,
        subtitle:
            "We do not share your personal information or usage data with any third parties. Your data is used solely by MindSpark and its administrators to provide and improve the app’s services, including course recommendations."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "5. Your Choices and Control".tr,
        subtitle:
            "You have control over your information:\n\nProfile Management: You can edit your username and phone number at any time through your profile settings in the app.\n\nData Deletion: To fully delete your account (including your server-side data), you must request deletion from an admin. You can also remove cached data and settings by uninstalling the app or clearing the app’s data through your device settings."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "6. No Third-Party Services".tr,
        subtitle:
            "MindSpark does not use third-party services, such as payment gateways or analytics tools, and therefore does not share your data with any external providers."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "7. No Cookies or Tracking Technologies".tr,
        subtitle:
            "The app does not use cookies, tracking pixels, or similar technologies for analytics or other purposes."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "8. Children’s Privacy".tr,
        subtitle:
            "MindSpark is designed for baccalaureate students in Syria, typically aged 17-18. We do not knowingly collect personal information from users under 16. If we learn that a user under 16 has provided information, we will take steps to delete it."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "9. Changes to This Privacy Policy".tr,
        subtitle:
            "We may update this Privacy Policy to reflect changes in the app’s features or data practices (e.g., if we transition to server-based storage). We will notify you of significant changes through the app or by updating the effective date at the top of this policy. Please review this policy periodically."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "10. Contact Us".tr,
        subtitle:
            "If you have questions or concerns about this Privacy Policy or how we handle your data, please contact your school’s designated administrator or reach out to us at:\n\nEmail: [Insert your support email]\n\nAddress: [Insert your physical address, if applicable]"
                .tr,
      ),
      PrivacyPolicyModel(
        title: "11. Your Rights".tr,
        subtitle:
            "You have the following rights regarding your personal data:\n\nAccess: You can request access to your data, including the information stored on your profile, quiz scores, and task progress.\n\nCorrection: If your data is incorrect, you can request corrections to it via your profile settings or by contacting the admin.\n\nDeletion: You can request that your account and data be deleted. An admin must manually process this request.\n\nWithdrawal of Consent: If we ask for your consent to process your data, you can withdraw that consent at any time by contacting the admin."
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

              // Text(
              //   textAlign: TextAlign.center,
              //   "Welcome to MindSpark, a learning management app designed to help baccalaureate students in Syria access educational courses, take quizzes, track tasks, and earn in-app rewards. We value your privacy and are committed to protecting the personal information you provide while using our app. This Privacy Policy explains how we collect, use, store, and protect your information."
              //       .tr,
              //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
              //     fontFamily: globalFontFamily,
              //     color: fgColor,
              //     fontWeight: FontWeight.w400,
              //     fontSize:
              //         globalFontSizeChange <= 17
              //             ? (globalFontSizeChange / 5) + 18
              //             : 18 - (globalFontSizeChange / 5),
              //   ),
              // ),
              // const SizedBox(height: 25),
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
                      itemCount: privacyPolicyList.length,
                      itemBuilder:
                          (context, i) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(height: 30),
                              Text(
                                privacyPolicyList[i].title!.tr,
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
                                  privacyPolicyList[i].subtitle!.tr,
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
                              if (i < privacyPolicyList.length - 1)
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

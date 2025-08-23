// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/PrivacyPolicyModel.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../../controller/FontController.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    String? editionDate = "August 20, 2025".tr;
    List<PrivacyPolicyModel> privacyPolicyList = [
      PrivacyPolicyModel(
        title: "1. Information We Collect".tr,
        subtitle:
            "We collect the following information when you use MindSpark:\n- Personal Information: Your name and phone number, which you provide when creating an account. You may choose to use a pseudonym or a non-personal phone number, as these are not verified.\n- App Usage Data: Information about the courses you subscribe to, your quiz scores, task progress, and in-app currency earned through quizzes. This data is used to personalize your learning experience and recommend relevant courses"
                .tr,
      ),
      PrivacyPolicyModel(
        title: "2. How We Use Your Information".tr,
        subtitle:
            "We use your information to:\n- Provide access to courses, quizzes, and tasks within the app.\n- Display your quiz scores and task progress in your profile.\n- Recommend courses based on your subscribed courses.\n- Manage your in-app currency earned through quiz completion.\n- Improve the app’s functionality and user experience.\nWe do not use your information for marketing or any purposes beyond what is necessary to operate the app."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "3. Data Storage and Security".tr,
        subtitle:
            "- Storage: All data, including your name, phone number, course subscriptions, quiz scores, task progress, and in-app currency, is currently stored locally on your device. In the future, we may transition to server-based storage, and we will update this Privacy Policy to reflect any changes.\n- Security: We use Laravel’s built-in encryption and secure API routes to protect data transmitted between the app and its backend. We take reasonable measures to safeguard your information, but no system is completely secure. You are responsible for maintaining the security of your device.\n- Offline Access: The app uses caching to store course and lecture content on your device for offline access. This cached data is only accessible within the app and is not shared externally."
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
            "You have control over your information:\n- Profile Management: You can edit your name, username, and phone number at any time through your profile settings in the app.\n- Data Deletion: Since data is stored locally on your device, you can delete your information by uninstalling the app or clearing the app’s data through your device settings. Contact us if you need assistance."
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
            "We may update this Privacy Policy to reflect changes in the app’s features or data practices (e.g., if we transition to server-based storage). We will notify you of significant changes through the app or by updating the effective date at the top of this policy.\nPlease review this policy periodically."
                .tr,
      ),
      PrivacyPolicyModel(
        title: "10. Contact Us".tr,
        subtitle:
            "If you have questions or concerns about this Privacy Policy or how we handle your data, please contact us at:\nEmail: "
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
                            fontFamily: FontController().currentFontFamily,

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
            Text(
              "Effective Date: $editionDate".tr,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontFamily: FontController().currentFontFamily,
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
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
                                fontFamily: FontController().currentFontFamily,
                                color: bgColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                privacyPolicyList[i].subtitle!.tr,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily:
                                      FontController().currentFontFamily,
                                  color: bgColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18,
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
    );
  }
}

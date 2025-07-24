// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../locale/LocaleController.dart';
import '../../model/PrivacyPolicyModel.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    List<PrivacyPolicyModel> privacyPolicyList = [
      PrivacyPolicyModel(
        title: "1. Information We Collect",
        subtitle:
            "When you register, we collect the following:\n- Username: (to identify your account).\n- Password: (stored securely in hashed form for authentication).\n- Phone Number: (used for account identification and subscription management).",
      ),
      PrivacyPolicyModel(
        title: "2. How We Use Your Information",
        subtitle:
            "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We do not use your data for marketing, analytics, or third-party sharing.",
      ),
      PrivacyPolicyModel(
        title: "3. Data Storage & Security",
        subtitle:
            "- Your password is hashed (encrypted) and cannot be accessed even by administrators.\n- Phone numbers and usernames are stored securely in our database.\n- Only authorized administrators can access user data for management purposes.",
      ),
      PrivacyPolicyModel(
        title: "4. No Third-Party Sharing",
        subtitle:
            "- We do not share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.",
      ),
      PrivacyPolicyModel(
        title: "5. Your Rights",
        subtitle:
            "- You can request to:\n- View the personal data we store (username/phone number).\n- Update or delete your account (subject to admin approval).\n- Since passwords are hashed, they cannot be retrieved—only reset.",
      ),
      PrivacyPolicyModel(
        title: "6. Account Usage & Device Restrictions",
        subtitle:
            "- Each account can only be used on one device at a time.\n- If you switch devices, you must contact our team to delete the old account before signing up again.\n- Subscriptions tied to your old account will be manually reinstated by our team after verification.",
      ),
      PrivacyPolicyModel(
        title: "7. Data Retention",
        subtitle:
            "- When you request an account deletion (to migrate to a new device), your phone number, username, and subscription data may be retained temporarily to facilitate manual recovery.\n- Fully deleted accounts are irrecoverable unless you re-register and contact support.",
      ),
      PrivacyPolicyModel(
        title: "8. Changes to This Policy",
        subtitle:
            "Updates will be posted here with a new \"Last Updated\" date.",
      ),
    ];

    final ThemeController themeController = Get.find<ThemeController>();
    // final LocaleController localeController = Get.find<LocaleController>();

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
                          "Privacy Policy".tr,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: privacyPolicyList.length,
                    itemBuilder: (context, i) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        Text(
                          privacyPolicyList[i].title!.tr,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: bgColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            privacyPolicyList[i].subtitle!.tr,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: bgColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                          ),
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

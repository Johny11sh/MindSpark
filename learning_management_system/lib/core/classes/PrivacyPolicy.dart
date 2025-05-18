// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locale/LocaleController.dart';
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
    final LocaleController localeController = Get.find<LocaleController>();
    return MaterialApp(
      theme: themeController.initialTheme,
      locale: localeController.initialLang,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.all(8),
          width: Get.width,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: privacyPolicyList.length,
                  itemBuilder:
                      (context, i) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          SizedBox(
                            width: Get.width,
                            child: Text(
                              privacyPolicyList[i].title!.tr,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: Get.width,
                            padding: EdgeInsets.only(left: 4),
                            child: Text(
                              privacyPolicyList[i].subtitle!.tr,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color:
                                    themeController.initialTheme ==
                                            Themes.customLightTheme
                                        ? Color.fromARGB(255, 40, 41, 61)
                                        : Color.fromARGB(255, 210, 209, 224),
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
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
      ),
    );
  }
}

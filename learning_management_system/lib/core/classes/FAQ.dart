// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../locale/LocaleController.dart';
import '../../model/FaqModel.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  State<FAQ> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  final ThemeController themeController = Get.find<ThemeController>();
  final LocaleController localeController = Get.find<LocaleController>();

  List<FaqModel> faqList = [
    FaqModel(
      question: "What is MindSpark?",
      answer:
          "MindSpark is an educational platform that delivers high-quality video courses to save time, cost, and effort.",
    ),
    FaqModel(
      question: "Can I use MindSpark on multiple devices?",
      answer:
          "No. Each account is restricted to one device at a time. For device changes, contact support.",
    ),
    FaqModel(
      question: "Is my personal information safe?",
      answer:
          "Absolutely. Your password is securely hashed, and we do not share your data with third parties.",
    ),
    FaqModel(
      question: "How can I reset my password?",
      answer:
          "You can request a password reset from the login screen. A new password will be sent to your registered phone.",
    ),
    FaqModel(
      question: "Do you offer certificates?",
      answer:
          "Currently, we focus on course quality. Certificates will be introduced in future updates.",
    ),
  ];

  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    isExpandedList = List.generate(faqList.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back, color: fgColor),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: Get.width / 8),
                        child: Text(
                          "FAQ".tr,
                          style: TextStyle(
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
                child: ListView.builder(
                  itemCount: faqList.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, i) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isExpandedList[i] = !isExpandedList[i];
                            });
                          },
                          child: Card(
                            color: bgColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      faqList[i].question.tr,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: fgColor,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpandedList[i]
                                        ? Icons.keyboard_arrow_up_outlined
                                        : Icons.keyboard_arrow_down_outlined,
                                    color: fgColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isExpandedList[i])
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              faqList[i].answer.tr,
                              style: TextStyle(
                                fontSize: 18,
                                color: bgColor,
                            ),
                          ),
                          )
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

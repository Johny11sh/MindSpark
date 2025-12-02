// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../locale/LocaleController.dart';
import '../../model/FaqModel.dart';
import '../../themes/ThemeController.dart';
import '../../themes/Themes.dart';
import '../constants/FontGlobals.dart';

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
      question: "What is MindSpark?".tr,
      answer:
          "MindSpark is an educational platform that delivers high-quality video and PDF courses delivered by well-trusted teachers to save time, cost, and effort."
              .tr,
    ),
    // FaqModel(
    //   question: "Can I use MindSpark on multiple devices?".tr,
    //   answer:
    //       "No. Each account is restricted to one device at a time. For device changes, contact support."
    //           .tr,
    // ),
    FaqModel(
      question: "Is my personal information safe?".tr,
      answer:
          "Absolutely. Your password is securely hashed, and we do not share your data with third parties."
              .tr,
    ),
    FaqModel(
      question: "How can I subscribe to a course?".tr,
      answer:
          "There are 2 methods. The first, which doesn't apply to all courses, is to use your sparkies to get them for free after answering enough quizzes. The second is to go to one of our libraries and pay up-front for the course which will then register you as subscribed."
              .tr,
    ),
    FaqModel(
      question: "What if I have feedback for a certain course?".tr,
      answer:
          "You can either leave a review on that course, or one of its lectures. You can also send a message directly to the teacher of that subject using any of their social media links to ensure your voice is heard."
              .tr,
    ),
    FaqModel(
      question: "How can I gain Sparkies?".tr,
      answer:
          "Sparkies can be gained by completing quizzes in the lectures of any course you're subscribed to. You need to gain 1000 sparks to get one Sparky."
              .tr,
    ),
    FaqModel(
      question: "What can I use my Sparkies for?".tr,
      answer:
          "Sparkies can be used to subscribe to certain courses, free of charge. In a future update, we plan to implement the ability to change the theme of the application using said sparkies for a fresh new look."
              .tr,
    ),
    FaqModel(
      question: "How many Sparks do I get with each quiz?".tr,
      answer:
          "Depending on the question difficulty, you get 1 (Easy), 3 (Medium) or 5 (Hard) for each question you answer. Answering every question of the quiz flawlessly grants you a bonus."
              .tr,
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
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faqList[i].question.tr,
                                        style: TextStyle(
                                          fontFamily: globalFontFamily,
                                          fontSize:
                                              globalFontSizeChange <= 17
                                                  ? (globalFontSizeChange / 5) +
                                                      20
                                                  : 20 -
                                                      (globalFontSizeChange /
                                                          5),
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
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                faqList[i].answer.tr,
                                style: TextStyle(
                                  fontSize:
                                      globalFontSizeChange <= 17
                                          ? (globalFontSizeChange / 5) + 18
                                          : 18 - (globalFontSizeChange / 5),
                                  color: bgColor,
                                  fontFamily: globalFontFamily,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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

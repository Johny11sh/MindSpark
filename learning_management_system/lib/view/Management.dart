// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
// import 'package:learning_management_system/view/Watchlist.dart';

// import '../core/classes/AboutUs.dart';
// import '../core/classes/ChangeTheme.dart';
// import '../core/classes/ContactUs.dart';
// import '../core/classes/Language.dart';
// import '../core/classes/PrivacyPolicy.dart';
import '../core/classes/TasksScreen.dart';
// import '../core/classes/WatchList.dart';
import '../core/constants/FontGlobals.dart';
import '../core/function/SettingsCard.dart';
import '../themes/Themes.dart';
import 'NavBar.dart';

class Management extends StatefulWidget {
  const Management({super.key});

  @override
  State<Management> createState() => _ManagementState();
}

class _ManagementState extends State<Management> with TickerProviderStateMixin {
  late AnimationController _cardsAnimationController;

  final List<Animation<double>> _cardAnimations = [];

  final List<Map<String, dynamic>> managementData = [
    // {
    //   'icon': Icons.format_list_numbered_rounded,
    //   'title': "WatchList".tr,
    //   'onTap': () => Get.to(() => Watchlist()),
    // },
    {
      'icon': Icons.task_outlined,
      'title': "Tasks".tr,
      'onTap': () => Get.to(() => TasksScreen()),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      reverseDuration: Duration(milliseconds: 200),
    );

    // Initialize card animations
    final int n = managementData.length;
    for (int i = 0; i < n; i++) {
      final double step = 0.2;
      double start = 0.3 + (i * step);
      if (start >= 1.0) start = 0.9;

      double end = (start + 0.3) > 1.0 ? 1.0 : (start + 0.3);

      if (end <= start) {
        start = (end - 0.1).clamp(0.0, 1.0);
      }

      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsAnimationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
      _cardAnimations.add(animation);
    }

    _cardsAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Container(
          color:
              themeController.initialTheme == Themes.customLightTheme
                  ? Color.fromARGB(255, 40, 41, 61)
                  : Color.fromARGB(255, 210, 209, 224),
          child: Column(
            children: [
              // SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.only(top: 30),
                height: 100,
                // color: Colors.red,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              themeController.initialTheme ==
                                      Themes.customLightTheme
                                  ? Color.fromARGB(255, 210, 209, 224)
                                  : Color.fromARGB(255, 40, 41, 61),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: Get.width / 8),

                          child: Text(
                                "Management".tr,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  fontFamily: globalFontFamily,
                                  color:
                                      themeController.initialTheme ==
                                              Themes.customLightTheme
                                          ? Color.fromARGB(255, 210, 209, 224)
                                          : Color.fromARGB(255, 40, 41, 61),
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
                    color:
                        themeController.initialTheme == Themes.customLightTheme
                            ? Color.fromARGB(255, 210, 209, 224)
                            : Color.fromARGB(255, 40, 41, 61),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              for (int i = 0; i < managementData.length; i++)
                                AnimatedBuilder(
                                  animation: _cardAnimations[i],
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _cardAnimations[i].value,
                                      child: Transform.translate(
                                        offset: Offset(
                                          0,
                                          50 * (1 - _cardAnimations[i].value),
                                        ),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: settingsCard(
                                    i,
                                    themeController,
                                    context,
                                    managementData,
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
            ],
          ),
        ),
      ),
    );
  }
}

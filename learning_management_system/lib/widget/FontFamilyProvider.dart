import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/FontController.dart';

class FontFamilyProvider extends StatelessWidget {
  final Widget child;

  const FontFamilyProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FontController fontController = Get.find<FontController>();

    return Obx(() {
      final currentFontFamily = fontController.currentFontFamily;
      final delta = fontController.currentFontSizeDelta;

      return Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: currentFontFamily,
            fontSizeDelta: delta,
          ),
          primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
            fontFamily: currentFontFamily,
            fontSizeDelta: delta,
          ),
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
            titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle
                ?.copyWith(fontFamily: currentFontFamily),
          ),
          bottomNavigationBarTheme: Theme.of(
            context,
          ).bottomNavigationBarTheme.copyWith(
            selectedLabelStyle: Theme.of(context)
                .bottomNavigationBarTheme
                .selectedLabelStyle
                ?.copyWith(fontFamily: currentFontFamily),
            unselectedLabelStyle: Theme.of(context)
                .bottomNavigationBarTheme
                .unselectedLabelStyle
                ?.copyWith(fontFamily: currentFontFamily),
          ),
        ),
        child: child,
      );
    });
  }
}

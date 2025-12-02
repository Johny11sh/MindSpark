import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/FontController.dart';
import '../core/constants/FontGlobals.dart';

class FontFamilyProvider extends StatelessWidget {
  final Widget child;

  const FontFamilyProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FontController>(
      builder: (fontController) {
        // Use reactive variables from the controller
        final currentFontFamily = fontController.currentFontFamily;
        final delta = fontController.currentFontSizeDelta;

        debugPrint(
          "🎨 FontFamilyProvider: Applying font $currentFontFamily with size delta $delta",
        );

        return Theme(
          data: Theme.of(context).copyWith(
            // Apply font settings to all text themes
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: currentFontFamily,
              fontSizeDelta: delta,
            ),
            primaryTextTheme: Theme.of(context).primaryTextTheme.apply(
              fontFamily: currentFontFamily,
              fontSizeDelta: delta,
            ),
            // Update app bar theme
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
              titleTextStyle: Theme.of(
                context,
              ).appBarTheme.titleTextStyle?.copyWith(
                fontFamily: currentFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 20
                        : (Theme.of(
                                  context,
                                ).appBarTheme.titleTextStyle?.fontSize ??
                                22) +
                            delta -
                            (globalFontSizeChange / 5),
              ),
            ),
            // Update bottom navigation bar theme
            bottomNavigationBarTheme: Theme.of(
              context,
            ).bottomNavigationBarTheme.copyWith(
              selectedLabelStyle: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedLabelStyle?.copyWith(
                fontFamily: currentFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 20
                        : (Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .selectedLabelStyle
                                    ?.fontSize ??
                                16) +
                            delta -
                            (globalFontSizeChange / 5),
              ),
              unselectedLabelStyle: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedLabelStyle?.copyWith(
                fontFamily: currentFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 20
                        : (Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .unselectedLabelStyle
                                    ?.fontSize ??
                                12) +
                            delta -
                            (globalFontSizeChange / 5),
              ),
            ),
            // Update input decoration theme
            inputDecorationTheme: Theme.of(
              context,
            ).inputDecorationTheme.copyWith(
              labelStyle: Theme.of(
                context,
              ).inputDecorationTheme.labelStyle?.copyWith(
                fontFamily: currentFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 20
                        : (Theme.of(
                                  context,
                                ).inputDecorationTheme.labelStyle?.fontSize ??
                                16) +
                            delta -
                            (globalFontSizeChange / 5),
              ),
              hintStyle: Theme.of(
                context,
              ).inputDecorationTheme.hintStyle?.copyWith(
                fontFamily: currentFontFamily,
                fontSize:
                    globalFontSizeChange <= 17
                        ? (globalFontSizeChange / 5) + 20
                        : (Theme.of(
                                  context,
                                ).inputDecorationTheme.hintStyle?.fontSize ??
                                16) +
                            delta -
                            (globalFontSizeChange / 5),
              ),
            ),
          ),
          child: child,
        );
      },
    );
  }
}

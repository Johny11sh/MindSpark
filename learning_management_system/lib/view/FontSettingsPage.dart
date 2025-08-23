// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/FontController.dart';

// // Show font settings as a bottom sheet
// void showFontSettingsBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     isDismissible: true,
//     enableDrag: true,
//     barrierColor: Colors.black54,
//     elevation: 20,
//     builder: (context) => const FontSettingsPage(),
//   );
// }

// class FontSettingsPage extends StatefulWidget {
//   const FontSettingsPage({super.key});

//   @override
//   State<FontSettingsPage> createState() => _FontSettingsPageState();
// }

// class _FontSettingsPageState extends State<FontSettingsPage> {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<FontController>();
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.7,
//       decoration: BoxDecoration(
//         color:
//             isDark
//                 ? const Color.fromARGB(255, 18, 18, 25)
//                 : const Color.fromARGB(255, 252, 248, 240),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 20,
//             spreadRadius: 5,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 12, bottom: 8),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey[600] : Colors.grey[400],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Title
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.font_download_rounded,
//                   color:
//                       isDark
//                           ? const Color.fromARGB(255, 120, 180, 255)
//                           : const Color.fromARGB(255, 70, 80, 120),
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Font Settings',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color:
//                         isDark
//                             ? const Color.fromARGB(255, 240, 240, 245)
//                             : const Color.fromARGB(255, 40, 40, 50),
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: Icon(
//                     Icons.close_rounded,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Content
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Font family selector
//                   _buildSectionTitle('Font Family', isDark),
//                   const SizedBox(height: 12),
//                   _buildFontFamilySelector(controller, isDark),
//                   const SizedBox(height: 24),

//                   // Font size controls
//                   _buildSectionTitle('Font Size', isDark),
//                   const SizedBox(height: 12),
//                   _buildFontSizeControls(controller, isDark),
//                   const SizedBox(height: 24),

//                   // Font test preview
//                   _buildSectionTitle('Preview', isDark),
//                   const SizedBox(height: 12),
//                   _buildFontTestPreview(controller, isDark),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, bool isDark) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color:
//             isDark
//                 ? const Color.fromARGB(255, 240, 240, 245)
//                 : const Color.fromARGB(255, 40, 40, 50),
//       ),
//     );
//   }

//   Widget _buildFontFamilySelector(FontController controller, bool isDark) {
//     return Obx(() {
//       final currentFont = controller.currentFontFamily;
//       final fonts = controller.availableFonts;

//       return Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children:
//             fonts.map((f) {
//               final isSelected = f == currentFont;

//               return InkWell(
//                 borderRadius: BorderRadius.circular(16),
//                 onTap: () => controller.updateFontFamily(f),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     color:
//                         isSelected
//                             ? (isDark
//                                 ? const Color.fromARGB(255, 120, 180, 255)
//                                 : const Color.fromARGB(255, 70, 80, 120))
//                             : (isDark
//                                 ? const Color.fromARGB(255, 30, 30, 40)
//                                 : const Color.fromARGB(255, 245, 242, 235)),
//                     border: Border.all(
//                       color:
//                           isSelected
//                               ? (isDark
//                                   ? const Color.fromARGB(255, 120, 180, 255)
//                                   : const Color.fromARGB(255, 70, 80, 120))
//                               : (isDark
//                                   ? Colors.grey[600]!
//                                   : Colors.grey[400]!),
//                       width: isSelected ? 2.0 : 1.0,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         isSelected ? Icons.check_circle : Icons.circle_outlined,
//                         color:
//                             isSelected
//                                 ? (isDark
//                                     ? const Color.fromARGB(255, 120, 180, 255)
//                                     : const Color.fromARGB(255, 70, 80, 120))
//                                 : (isDark
//                                     ? Colors.grey[600]
//                                     : Colors.grey[400]),
//                         size: isSelected ? 24 : 20,
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         f,
//                         style: TextStyle(
//                           fontFamily: f,
//                           fontWeight:
//                               isSelected ? FontWeight.w700 : FontWeight.w500,
//                           color:
//                               isSelected
//                                   ? (isDark
//                                       ? const Color.fromARGB(255, 240, 240, 245)
//                                       : const Color.fromARGB(255, 40, 40, 50))
//                                   : (isDark
//                                       ? Colors.grey[300]
//                                       : Colors.grey[600]),
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//       );
//     });
//   }

//   Widget _buildFontSizeControls(FontController controller, bool isDark) {
//     return Obx(() {
//       final delta = controller.currentFontSizeDelta;

//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color:
//               isDark
//                   ? const Color.fromARGB(255, 30, 30, 40)
//                   : const Color.fromARGB(255, 245, 242, 235),
//           border: Border.all(
//             color: (isDark
//                     ? const Color.fromARGB(255, 120, 180, 255)
//                     : const Color.fromARGB(255, 70, 80, 120))
//                 .withOpacity(0.25),
//           ),
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: () => controller.updateFontSize(delta - 0.5),
//                   icon: Icon(
//                     Icons.remove_circle_outline,
//                     color:
//                         isDark
//                             ? const Color.fromARGB(255, 120, 180, 255)
//                             : const Color.fromARGB(255, 70, 80, 120),
//                     size: 28,
//                   ),
//                 ),
//                 Expanded(
//                   child: SliderTheme(
//                     data: SliderTheme.of(context).copyWith(
//                       activeTrackColor:
//                           isDark
//                               ? const Color.fromARGB(255, 120, 180, 255)
//                               : const Color.fromARGB(255, 70, 80, 120),
//                       inactiveTrackColor:
//                           isDark
//                               ? const Color.fromARGB(
//                                 255,
//                                 60,
//                                 60,
//                                 70,
//                               ).withOpacity(0.3)
//                               : const Color.fromARGB(
//                                 255,
//                                 70,
//                                 80,
//                                 120,
//                               ).withOpacity(0.3),
//                       thumbColor:
//                           isDark
//                               ? const Color.fromARGB(255, 120, 180, 255)
//                               : const Color.fromARGB(255, 70, 80, 120),
//                     ),
//                     child: Slider(
//                       min: -6.0,
//                       max: 6.0,
//                       divisions: 24,
//                       value: delta,
//                       onChanged: (v) => controller.updateFontSize(v),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => controller.updateFontSize(delta + 0.5),
//                   icon: Icon(
//                     Icons.add_circle_outline,
//                     color:
//                         isDark
//                             ? const Color.fromARGB(255, 120, 180, 255)
//                             : const Color.fromARGB(255, 70, 80, 120),
//                     size: 28,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color:
//                     isDark
//                         ? const Color.fromARGB(
//                           255,
//                           120,
//                           180,
//                           255,
//                         ).withOpacity(0.2)
//                         : const Color.fromARGB(
//                           255,
//                           70,
//                           80,
//                           120,
//                         ).withOpacity(0.15),
//               ),
//               child: Text(
//                 'Current Size: ${(16 + delta).toStringAsFixed(1)}',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color:
//                       isDark
//                           ? const Color.fromARGB(255, 240, 240, 245)
//                           : const Color.fromARGB(255, 40, 40, 50),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildFontTestPreview(FontController controller, bool isDark) {
//     return Obx(() {
//       final currentFont = controller.currentFontFamily;
//       final delta = controller.currentFontSizeDelta;
//       final fontSize = 16 + delta;

//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color:
//               isDark
//                   ? const Color.fromARGB(255, 30, 30, 40)
//                   : const Color.fromARGB(255, 245, 242, 235),
//           border: Border.all(
//             color: (isDark
//                     ? const Color.fromARGB(255, 120, 180, 255)
//                     : const Color.fromARGB(255, 70, 80, 120))
//                 .withOpacity(0.25),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color:
//                     isDark
//                         ? const Color.fromARGB(255, 40, 40, 50).withOpacity(0.3)
//                         : const Color.fromARGB(
//                           255,
//                           255,
//                           255,
//                           255,
//                         ).withOpacity(0.8),
//                 border: Border.all(
//                   color: (isDark
//                           ? const Color.fromARGB(255, 120, 180, 255)
//                           : const Color.fromARGB(255, 70, 80, 120))
//                       .withOpacity(0.2),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'The quick brown fox jumps over the lazy dog',
//                     style: TextStyle(
//                       fontFamily: currentFont,
//                       fontSize: fontSize,
//                       fontWeight: FontWeight.w500,
//                       color:
//                           isDark
//                               ? const Color.fromARGB(255, 240, 240, 245)
//                               : const Color.fromARGB(255, 40, 40, 50),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '0123456789',
//                     style: TextStyle(
//                       fontFamily: currentFont,
//                       fontSize: fontSize,
//                       fontWeight: FontWeight.w400,
//                       color:
//                           isDark
//                               ? const Color.fromARGB(255, 200, 200, 205)
//                               : const Color.fromARGB(255, 80, 80, 90),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
//                     style: TextStyle(
//                       fontFamily: currentFont,
//                       fontSize: fontSize,
//                       fontWeight: FontWeight.w300,
//                       color:
//                           isDark
//                               ? const Color.fromARGB(255, 180, 180, 185)
//                               : const Color.fromARGB(255, 100, 100, 110),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/FontController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';

// Show font settings as a bottom sheet
void showFontSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black54,
    elevation: 20,
    builder: (context) => const FontSettingsPage(),
  );
}

class FontSettingsPage extends StatefulWidget {
  const FontSettingsPage({super.key});

  @override
  State<FontSettingsPage> createState() => _FontSettingsPageState();
}

class _FontSettingsPageState extends State<FontSettingsPage> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FontController>();
    final bool isLightTheme =
        themeController.initialTheme == Themes.customLightTheme;

    // Color scheme with proper contrast
    final Color bgColor =
        isLightTheme
            ? const Color.fromARGB(255, 245, 244, 249)
            : const Color.fromARGB(255, 30, 31, 51);
    final Color cardColor =
        isLightTheme
            ? const Color.fromARGB(255, 255, 255, 255)
            : const Color.fromARGB(255, 45, 46, 66);
    final Color primaryTextColor =
        isLightTheme
            ? const Color.fromARGB(255, 40, 41, 61)
            : const Color.fromARGB(255, 240, 240, 245);
    final Color secondaryTextColor =
        isLightTheme
            ? const Color.fromARGB(255, 100, 101, 121)
            : const Color.fromARGB(255, 180, 180, 200);
    final Color accentColor =
        isLightTheme
            ? const Color.fromARGB(255, 70, 130, 180)
            : const Color.fromARGB(255, 100, 180, 255);
    final Color borderColor =
        isLightTheme
            ? const Color.fromARGB(255, 220, 220, 230)
            : const Color.fromARGB(255, 60, 61, 81);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryTextColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.font_download_rounded, color: accentColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Font Settings'.tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                    fontFamily: controller.currentFontFamily,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close_rounded, color: secondaryTextColor),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Font family selector
                    _buildSectionTitle(
                      'Font Family',
                      primaryTextColor,
                      controller,
                    ),
                    const SizedBox(height: 16),
                    _buildFontFamilySelector(
                      controller,
                      accentColor,
                      primaryTextColor,
                      cardColor,
                      borderColor,
                    ),
                    const SizedBox(height: 24),

                    // Font size controls
                    _buildSectionTitle(
                      'Font Size',
                      primaryTextColor,
                      controller,
                    ),
                    const SizedBox(height: 16),
                    _buildFontSizeControls(
                      controller,
                      accentColor,
                      primaryTextColor,
                      borderColor,
                    ),
                    const SizedBox(height: 24),

                    // Font test preview
                    _buildSectionTitle('Preview', primaryTextColor, controller),
                    const SizedBox(height: 16),
                    _buildFontTestPreview(
                      controller,
                      primaryTextColor,
                      secondaryTextColor,
                      borderColor,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    Color color,
    FontController controller,
  ) {
    return Text(
      title.tr,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: controller.currentFontFamily,
      ),
    );
  }

  Widget _buildFontFamilySelector(
    FontController controller,
    Color accentColor,
    Color primaryTextColor,
    Color cardColor,
    Color borderColor,
  ) {
    return Obx(() {
      final currentFont = controller.currentFontFamily;
      final fonts = controller.availableFonts;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cardColor,
          border: Border.all(color: borderColor),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              fonts.map((f) {
                final isSelected = f == currentFont;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => controller.updateFontFamily(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected ? accentColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? accentColor : borderColor,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? Colors.white : accentColor,
                          size: isSelected ? 24 : 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          f,
                          style: TextStyle(
                            fontFamily: f,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : primaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      );
    });
  }

  Widget _buildFontSizeControls(
    FontController controller,
    Color accentColor,
    Color primaryTextColor,
    Color borderColor,
  ) {
    return Obx(() {
      final delta = controller.currentFontSizeDelta;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.updateFontSize(delta - 0.5),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: accentColor,
                      inactiveTrackColor: accentColor.withOpacity(0.3),
                      thumbColor: accentColor,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                    ),
                    child: Slider(
                      min: -6.0,
                      max: 6.0,
                      divisions: 24,
                      value: delta,
                      onChanged: (v) => controller.updateFontSize(v),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => controller.updateFontSize(delta + 0.5),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: accentColor,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: accentColor.withOpacity(0.2),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                'Current Size: ${(16 + delta).toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                  fontFamily: controller.currentFontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFontTestPreview(
    FontController controller,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Obx(() {
      final currentFont = controller.currentFontFamily;
      final delta = controller.currentFontSizeDelta;
      final fontSize = 16 + delta;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: primaryTextColor.withOpacity(0.05),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: TextStyle(
                      fontFamily: currentFont,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0123456789',
                    style: TextStyle(
                      fontFamily: currentFont,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                    style: TextStyle(
                      fontFamily: currentFont,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w300,
                      color: secondaryTextColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

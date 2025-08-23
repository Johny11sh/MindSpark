// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../controller/FontController.dart';
// // import '../themes/Themes.dart';

// // class FontSettingsBottomSheet extends StatelessWidget {
// //   const FontSettingsBottomSheet({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final controller = Get.find<FontController>();
// //     final colorScheme = Theme.of(context).colorScheme;
// //     final isDark = Theme.of(context).brightness == Brightness.dark;

// //     return Container(
// //       decoration: BoxDecoration(
// //         color:
// //             isDark
// //                 ? const Color.fromARGB(255, 40, 41, 61)
// //                 : const Color.fromARGB(255, 210, 209, 224),
// //         borderRadius: const BorderRadius.only(
// //           topLeft: Radius.circular(24),
// //           topRight: Radius.circular(24),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.3),
// //             blurRadius: 20,
// //             spreadRadius: 5,
// //             offset: const Offset(0, -5),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           // Handle bar
// //           Container(
// //             margin: const EdgeInsets.only(top: 12, bottom: 8),
// //             width: 40,
// //             height: 4,
// //             decoration: BoxDecoration(
// //               color: isDark ? Colors.grey[600] : Colors.grey[400],
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),

// //           // Title
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   Icons.font_download_rounded,
// //                   color: isDark ? Colors.amber : colorScheme.primary,
// //                   size: 28,
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Text(
// //                   'Font Settings',
// //                   style: TextStyle(
// //                     fontSize: 24,
// //                     fontWeight: FontWeight.bold,
// //                     color:
// //                         isDark
// //                             ? Colors.white
// //                             : const Color.fromARGB(255, 40, 41, 61),
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 IconButton(
// //                   onPressed: () => Get.back(),
// //                   icon: Icon(
// //                     Icons.close_rounded,
// //                     color: isDark ? Colors.grey[400] : Colors.grey[600],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           // Content
// //           Flexible(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.symmetric(horizontal: 24),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Font family selector
// //                   _buildSectionTitle(context, 'Font Family', isDark),
// //                   const SizedBox(height: 12),
// //                   _buildFontFamilyGrid(
// //                     context,
// //                     controller,
// //                     isDark,
// //                     colorScheme,
// //                   ),

// //                   const SizedBox(height: 24),

// //                   // Font size controls
// //                   _buildSectionTitle(context, 'Font Size', isDark),
// //                   const SizedBox(height: 12),
// //                   _buildFontSizeControls(
// //                     context,
// //                     controller,
// //                     isDark,
// //                     colorScheme,
// //                   ),

// //                   const SizedBox(height: 24),

// //                   // Preview
// //                   _buildSectionTitle(context, 'Preview', isDark),
// //                   const SizedBox(height: 12),
// //                   _buildPreviewSection(
// //                     context,
// //                     controller,
// //                     isDark,
// //                     colorScheme,
// //                   ),

// //                   const SizedBox(height: 24),

// //                   // Action buttons
// //                   _buildActionButtons(context, controller, isDark, colorScheme),

// //                   const SizedBox(height: 32),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
// //     return Text(
// //       title,
// //       style: TextStyle(
// //         fontSize: 18,
// //         fontWeight: FontWeight.w600,
// //         color: isDark ? Colors.amber : const Color.fromARGB(255, 40, 41, 61),
// //       ),
// //     );
// //   }

// //   Widget _buildFontFamilyGrid(
// //     BuildContext context,
// //     FontController controller,
// //     bool isDark,
// //     ColorScheme colorScheme,
// //   ) {
// //     return Obx(() {
// //       final selected = controller.currentFontFamily;
// //       final fonts = controller.availableFonts;

// //       return GridView.builder(
// //         shrinkWrap: true,
// //         physics: const NeverScrollableScrollPhysics(),
// //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 2,
// //           childAspectRatio: 3.0,
// //           crossAxisSpacing: 12,
// //           mainAxisSpacing: 12,
// //         ),
// //         itemCount: fonts.length,
// //         itemBuilder: (context, index) {
// //           final f = fonts[index];
// //           final isSelected = f == selected;

// //           // Enhanced color scheme with new colors
// //           final Color borderColor =
// //               isSelected
// //                   ? (isDark ? Colors.amber : colorScheme.primary)
// //                   : (isDark ? Colors.grey[600]! : Colors.grey[400]!);

// //           final List<Color> bgColors =
// //               isSelected
// //                   ? (isDark
// //                       ? [
// //                         const Color.fromARGB(255, 120, 40, 80), // RichBurgundy
// //                         const Color.fromARGB(255, 70, 40, 90), // DarkViolet
// //                       ]
// //                       : [
// //                         colorScheme.primary.withOpacity(0.18),
// //                         colorScheme.secondary.withOpacity(0.14),
// //                       ])
// //                   : (isDark
// //                       ? [
// //                         const Color.fromARGB(255, 32, 34, 80), // DarkTeal
// //                         const Color.fromARGB(255, 55, 48, 107), // DeepIndigo
// //                       ]
// //                       : [
// //                         colorScheme.surfaceContainerHighest.withOpacity(0.10),
// //                         colorScheme.surface.withOpacity(0.06),
// //                       ]);

// //           return InkWell(
// //             borderRadius: BorderRadius.circular(16),
// //             onTap: () => controller.updateFontFamily(f),
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 300),
// //               curve: Curves.elasticOut,
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //               decoration: BoxDecoration(
// //                 borderRadius: BorderRadius.circular(16),
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                   colors: bgColors,
// //                 ),
// //                 border: Border.all(
// //                   color: borderColor.withOpacity(0.65),
// //                   width: isSelected ? 2.0 : 1.0,
// //                 ),
// //                 boxShadow:
// //                     isSelected
// //                         ? [
// //                           BoxShadow(
// //                             color: (isDark ? Colors.amber : colorScheme.primary)
// //                                 .withOpacity(isDark ? 0.40 : 0.25),
// //                             blurRadius: 20,
// //                             spreadRadius: 2,
// //                             offset: const Offset(0, 8),
// //                           ),
// //                         ]
// //                         : [],
// //               ),
// //               child: Row(
// //                 children: [
// //                   AnimatedSwitcher(
// //                     duration: const Duration(milliseconds: 300),
// //                     transitionBuilder: (
// //                       Widget child,
// //                       Animation<double> animation,
// //                     ) {
// //                       return ScaleTransition(scale: animation, child: child);
// //                     },
// //                     child:
// //                         isSelected
// //                             ? Icon(
// //                               Icons.check_circle_rounded,
// //                               key: ValueKey('sel_$f'),
// //                               color:
// //                                   isDark ? Colors.amber : colorScheme.primary,
// //                               size: 24,
// //                             )
// //                             : Icon(
// //                               Icons.circle_outlined,
// //                               key: ValueKey('unsel_$f'),
// //                               color: borderColor,
// //                               size: 20,
// //                             ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: AnimatedDefaultTextStyle(
// //                       duration: const Duration(milliseconds: 300),
// //                       style: TextStyle(
// //                         fontFamily: f,
// //                         fontWeight:
// //                             isSelected ? FontWeight.w700 : FontWeight.w500,
// //                         color:
// //                             isSelected
// //                                 ? (isDark
// //                                     ? Colors.white
// //                                     : colorScheme.onSurface)
// //                                 : (isDark
// //                                     ? Colors.grey[300]
// //                                     : colorScheme.onSurface.withOpacity(0.85)),
// //                         fontSize: 16,
// //                       ),
// //                       child: Text(f, overflow: TextOverflow.ellipsis),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       );
// //     });
// //   }

// //   Widget _buildFontSizeControls(
// //     BuildContext context,
// //     FontController controller,
// //     bool isDark,
// //     ColorScheme colorScheme,
// //   ) {
// //     return Obx(() {
// //       final delta = controller.currentFontSizeDelta;

// //       return Container(
// //         padding: const EdgeInsets.all(20),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(20),
// //           gradient: LinearGradient(
// //             colors:
// //                 isDark
// //                     ? [
// //                       const Color.fromARGB(
// //                         255,
// //                         25,
// //                         80,
// //                         60,
// //                       ).withOpacity(0.15), // DarkEmerald
// //                       const Color.fromARGB(
// //                         255,
// //                         20,
// //                         30,
// //                         60,
// //                       ).withOpacity(0.12), // MidnightBlue
// //                     ]
// //                     : [
// //                       colorScheme.secondary.withOpacity(0.08),
// //                       colorScheme.tertiary.withOpacity(0.06),
// //                     ],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //           border: Border.all(
// //             color: (isDark
// //                     ? const Color.fromARGB(255, 25, 80, 60)
// //                     : colorScheme.secondary)
// //                 .withOpacity(0.25),
// //           ),
// //         ),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 IconButton(
// //                   tooltip: 'Smaller',
// //                   onPressed: () => controller.updateFontSize((delta - 0.5)),
// //                   icon: Icon(
// //                     Icons.remove_circle_outline,
// //                     color: isDark ? Colors.amber : colorScheme.primary,
// //                     size: 28,
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: SliderTheme(
// //                     data: SliderTheme.of(context).copyWith(
// //                       activeTrackColor:
// //                           isDark ? Colors.amber : colorScheme.primary,
// //                       inactiveTrackColor:
// //                           isDark
// //                               ? const Color.fromARGB(
// //                                 255,
// //                                 70,
// //                                 40,
// //                                 90,
// //                               ).withOpacity(0.3)
// //                               : colorScheme.primary.withOpacity(0.3),
// //                       thumbColor: isDark ? Colors.amber : colorScheme.primary,
// //                       overlayColor: (isDark
// //                               ? Colors.amber
// //                               : colorScheme.primary)
// //                           .withOpacity(0.2),
// //                     ),
// //                     child: Slider(
// //                       min: -6.0,
// //                       max: 6.0,
// //                       divisions: 24,
// //                       value: delta,
// //                       onChanged: (v) => controller.updateFontSize(v),
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   tooltip: 'Larger',
// //                   onPressed: () => controller.updateFontSize((delta + 0.5)),
// //                   icon: Icon(
// //                     Icons.add_circle_outline,
// //                     color: isDark ? Colors.amber : colorScheme.primary,
// //                     size: 28,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 16,
// //                     vertical: 10,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(16),
// //                     gradient: LinearGradient(
// //                       colors:
// //                           isDark
// //                               ? [
// //                                 const Color.fromARGB(
// //                                   255,
// //                                   180,
// //                                   60,
// //                                   80,
// //                                 ), // DeepCoral
// //                                 const Color.fromARGB(
// //                                   255,
// //                                   120,
// //                                   40,
// //                                   80,
// //                                 ), // RichBurgundy
// //                               ]
// //                               : [
// //                                 colorScheme.primary.withOpacity(0.15),
// //                                 colorScheme.secondary.withOpacity(0.12),
// //                               ],
// //                       begin: Alignment.topLeft,
// //                       end: Alignment.bottomRight,
// //                     ),
// //                     border: Border.all(
// //                       color: (isDark ? Colors.amber : colorScheme.primary)
// //                           .withOpacity(0.3),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     delta.toStringAsFixed(1),
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w600,
// //                       color: isDark ? Colors.white : colorScheme.primary,
// //                       fontSize: 16,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       );
// //     });
// //   }

// //   Widget _buildPreviewSection(
// //     BuildContext context,
// //     FontController controller,
// //     bool isDark,
// //     ColorScheme colorScheme,
// //   ) {
// //     return Obx(() {
// //       final family = controller.currentFontFamily;
// //       final delta = controller.currentFontSizeDelta;

// //       return AnimatedContainer(
// //         duration: const Duration(milliseconds: 350),
// //         curve: Curves.easeInOut,
// //         width: double.infinity,
// //         padding: const EdgeInsets.all(24),
// //         decoration: BoxDecoration(
// //           borderRadius: BorderRadius.circular(24),
// //           gradient: LinearGradient(
// //             colors:
// //                 isDark
// //                     ? [
// //                       const Color.fromARGB(
// //                         255,
// //                         70,
// //                         40,
// //                         90,
// //                       ).withOpacity(0.25), // DarkViolet
// //                       const Color.fromARGB(
// //                         255,
// //                         32,
// //                         34,
// //                         80,
// //                       ).withOpacity(0.20), // DarkTeal
// //                     ]
// //                     : [
// //                       colorScheme.tertiary.withOpacity(0.12),
// //                       colorScheme.primary.withOpacity(0.10),
// //                     ],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //           border: Border.all(
// //             color: (isDark
// //                     ? const Color.fromARGB(255, 70, 40, 90)
// //                     : colorScheme.primary)
// //                 .withOpacity(0.30),
// //             width: 2,
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: (isDark ? Colors.amber : colorScheme.primary).withOpacity(
// //                 0.15,
// //               ),
// //               blurRadius: 20,
// //               spreadRadius: 1,
// //               offset: const Offset(0, 8),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             AnimatedDefaultTextStyle(
// //               duration: const Duration(milliseconds: 300),
// //               style: TextStyle(
// //                 fontFamily: family,
// //                 fontSize: 22 + delta,
// //                 height: 1.3,
// //                 color:
// //                     isDark
// //                         ? Colors.white
// //                         : const Color.fromARGB(255, 40, 41, 61),
// //               ),
// //               child: const Text('The quick brown fox jumps over the lazy dog'),
// //             ),
// //             const SizedBox(height: 16),
// //             AnimatedDefaultTextStyle(
// //               duration: const Duration(milliseconds: 300),
// //               style: TextStyle(
// //                 fontFamily: family,
// //                 fontSize: 18 + delta,
// //                 height: 1.35,
// //                 color:
// //                     isDark
// //                         ? Colors.white
// //                         : const Color.fromARGB(255, 40, 41, 61),
// //               ),
// //               child: const Text(
// //                 'مرحبا بك في تطبيق التعليم - 1234567890',
// //                 textDirection: TextDirection.rtl,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     });
// //   }

// //   Widget _buildActionButtons(
// //     BuildContext context,
// //     FontController controller,
// //     bool isDark,
// //     ColorScheme colorScheme,
// //   ) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: ElevatedButton.icon(
// //             onPressed: () {
// //               controller.updateFontFamily('Montserrat');
// //               controller.updateFontSize(0.0);
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor:
// //                   isDark
// //                       ? const Color.fromARGB(255, 100, 50, 40) // DeepRust
// //                       : colorScheme.primary,
// //               foregroundColor: Colors.white,
// //               padding: const EdgeInsets.symmetric(vertical: 18),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               elevation: 4,
// //             ),
// //             icon: const Icon(Icons.restore),
// //             label: const Text(
// //               'Reset',
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 16),
// //         Expanded(
// //           child: OutlinedButton.icon(
// //             onPressed: () => Get.back(),
// //             style: OutlinedButton.styleFrom(
// //               foregroundColor: isDark ? Colors.amber : colorScheme.primary,
// //               side: BorderSide(
// //                 color: isDark ? Colors.amber : colorScheme.primary,
// //                 width: 2,
// //               ),
// //               padding: const EdgeInsets.symmetric(vertical: 18),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //             ),
// //             icon: const Icon(Icons.check),
// //             label: const Text(
// //               'Done',
// //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/FontController.dart';
// import '../themes/ThemeController.dart';
// import '../themes/Themes.dart';

// class FontSettingsBottomSheet extends StatelessWidget {
//   const FontSettingsBottomSheet({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<FontController>();
//     final ThemeController themeController = Get.find<ThemeController>();
//     final bool isLightTheme =
//         themeController.initialTheme == Themes.customLightTheme;
//     final Color primaryColor =
//         isLightTheme
//             ? const Color.fromARGB(255, 40, 41, 61)
//             : const Color.fromARGB(255, 210, 209, 224);
//     final Color secondaryColor =
//         isLightTheme
//             ? const Color.fromARGB(255, 210, 209, 224)
//             : const Color.fromARGB(255, 40, 41, 61);

//     return Container(
//       decoration: BoxDecoration(
//         color: secondaryColor,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(60),
//           topRight: Radius.circular(60),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle bar
//           Container(
//             margin: const EdgeInsets.only(top: 12, bottom: 8),
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: primaryColor.withOpacity(0.5),
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
//                   color: primaryColor,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Font Settings',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: Icon(Icons.close_rounded, color: primaryColor),
//                 ),
//               ],
//             ),
//           ),

//           // Content
//           Flexible(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Font family selector
//                   _buildSectionTitle('Font Family', primaryColor),
//                   const SizedBox(height: 12),
//                   _buildFontFamilyGrid(
//                     controller,
//                     primaryColor,
//                     secondaryColor,
//                   ),

//                   const SizedBox(height: 24),

//                   // Font size controls
//                   _buildSectionTitle('Font Size', primaryColor),
//                   const SizedBox(height: 12),
//                   _buildFontSizeControls(
//                     controller,
//                     primaryColor,
//                     secondaryColor,
//                   ),

//                   const SizedBox(height: 24),

//                   // Preview
//                   _buildSectionTitle('Preview', primaryColor),
//                   const SizedBox(height: 12),
//                   _buildPreviewSection(
//                     controller,
//                     primaryColor,
//                     secondaryColor,
//                   ),

//                   const SizedBox(height: 24),

//                   // Action buttons
//                   _buildActionButtons(controller, primaryColor, secondaryColor),

//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, Color primaryColor) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color: primaryColor,
//       ),
//     );
//   }

//   Widget _buildFontFamilyGrid(
//     FontController controller,
//     Color primaryColor,
//     Color secondaryColor,
//   ) {
//     return Obx(() {
//       final selected = controller.currentFontFamily;
//       final fonts = controller.availableFonts;

//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 3.0,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//         ),
//         itemCount: fonts.length,
//         itemBuilder: (context, index) {
//           final f = fonts[index];
//           final isSelected = f == selected;

//           final Color borderColor =
//               isSelected ? primaryColor : primaryColor.withOpacity(0.3);

//           return InkWell(
//             borderRadius: BorderRadius.circular(16),
//             onTap: () => controller.updateFontFamily(f),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color:
//                     isSelected
//                         ? primaryColor.withOpacity(0.2)
//                         : primaryColor.withOpacity(0.05),
//                 border: Border.all(
//                   color: borderColor,
//                   width: isSelected ? 2.0 : 1.0,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     isSelected
//                         ? Icons.check_circle_rounded
//                         : Icons.circle_outlined,
//                     color:
//                         isSelected
//                             ? primaryColor
//                             : primaryColor.withOpacity(0.5),
//                     size: isSelected ? 24 : 20,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       f,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontFamily: f,
//                         fontWeight:
//                             isSelected ? FontWeight.w700 : FontWeight.w500,
//                         color: primaryColor,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     });
//   }

//   Widget _buildFontSizeControls(
//     FontController controller,
//     Color primaryColor,
//     Color secondaryColor,
//   ) {
//     return Obx(() {
//       final delta = controller.currentFontSizeDelta;

//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: primaryColor.withOpacity(0.1),
//           border: Border.all(color: primaryColor.withOpacity(0.25)),
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 IconButton(
//                   tooltip: 'Smaller',
//                   onPressed: () => controller.updateFontSize((delta - 0.5)),
//                   icon: Icon(
//                     Icons.remove_circle_outline,
//                     color: primaryColor,
//                     size: 28,
//                   ),
//                 ),
//                 Expanded(
//                   child: SliderTheme(
//                     data: SliderThemeData(
//                       activeTrackColor: primaryColor,
//                       inactiveTrackColor: primaryColor.withOpacity(0.3),
//                       thumbColor: primaryColor,
//                       overlayColor: primaryColor.withOpacity(0.2),
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
//                   tooltip: 'Larger',
//                   onPressed: () => controller.updateFontSize((delta + 0.5)),
//                   icon: Icon(
//                     Icons.add_circle_outline,
//                     color: primaryColor,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     color: primaryColor.withOpacity(0.15),
//                     border: Border.all(color: primaryColor.withOpacity(0.3)),
//                   ),
//                   child: Text(
//                     delta.toStringAsFixed(1),
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: primaryColor,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildPreviewSection(
//     FontController controller,
//     Color primaryColor,
//     Color secondaryColor,
//   ) {
//     return Obx(() {
//       final family = controller.currentFontFamily;
//       final delta = controller.currentFontSizeDelta;

//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           color: primaryColor.withOpacity(0.1),
//           border: Border.all(color: primaryColor.withOpacity(0.30), width: 2),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'The quick brown fox jumps over the lazy dog',
//               style: TextStyle(
//                 fontFamily: family,
//                 fontSize: 22 + delta,
//                 height: 1.3,
//                 color: primaryColor,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'مرحبا بك في تطبيق التعليم - 1234567890',
//               textDirection: TextDirection.rtl,
//               style: TextStyle(
//                 fontFamily: family,
//                 fontSize: 18 + delta,
//                 height: 1.35,
//                 color: primaryColor,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildActionButtons(
//     FontController controller,
//     Color primaryColor,
//     Color secondaryColor,
//   ) {
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () {
//               controller.updateFontFamily('Montserrat');
//               controller.updateFontSize(0.0);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryColor,
//               foregroundColor: secondaryColor,
//               padding: const EdgeInsets.symmetric(vertical: 18),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             icon: const Icon(Icons.restore),
//             label: const Text(
//               'Reset',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: OutlinedButton.icon(
//             onPressed: () => Get.back(),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: primaryColor,
//               side: BorderSide(color: primaryColor, width: 2),
//               padding: const EdgeInsets.symmetric(vertical: 18),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             icon: const Icon(Icons.check),
//             label: const Text(
//               'Done',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/FontController.dart';
import '../themes/ThemeController.dart';
import '../themes/Themes.dart';

class FontSettingsBottomSheet extends StatelessWidget {
  const FontSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FontController>();
    final ThemeController themeController = Get.find<ThemeController>();
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
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
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
                    _buildFontFamilyGrid(
                      controller,
                      accentColor,
                      primaryTextColor,
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

                    // Preview
                    _buildSectionTitle('Preview', primaryTextColor, controller),
                    const SizedBox(height: 16),
                    _buildPreviewSection(
                      controller,
                      primaryTextColor,
                      secondaryTextColor,
                      borderColor,
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    _buildActionButtons(
                      controller,
                      accentColor,
                      primaryTextColor,
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

  Widget _buildFontFamilyGrid(
    FontController controller,
    Color accentColor,
    Color primaryTextColor,
    Color borderColor,
  ) {
    return Obx(() {
      final selected = controller.currentFontFamily;
      final fonts = controller.availableFonts;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.transparent,
          border: Border.all(color: borderColor),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: fonts.length,
          itemBuilder: (context, index) {
            final f = fonts[index];
            final isSelected = f == selected;

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
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected ? Colors.white : accentColor,
                      size: isSelected ? 24 : 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: f,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : primaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
                    data: SliderThemeData(
                      activeTrackColor: accentColor,
                      inactiveTrackColor: accentColor.withOpacity(0.3),
                      thumbColor: accentColor,
                      overlayColor: accentColor.withOpacity(0.2),
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

  Widget _buildPreviewSection(
    FontController controller,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Obx(() {
      final family = controller.currentFontFamily;
      final delta = controller.currentFontSizeDelta;

      return Container(
        width: double.infinity,
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
                      fontFamily: family,
                      fontSize: 16 + delta,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0123456789',
                    style: TextStyle(
                      fontFamily: family,
                      fontSize: 16 + delta,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                    style: TextStyle(
                      fontFamily: family,
                      fontSize: 16 + delta,
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

  Widget _buildActionButtons(
    FontController controller,
    Color accentColor,
    Color primaryTextColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              controller.updateFontFamily('Montserrat');
              controller.updateFontSize(0.0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.restore),
            label: Text(
              'Reset'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: controller.currentFontFamily,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.check),
            label: Text(
              'Done'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: controller.currentFontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

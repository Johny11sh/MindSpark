import 'package:flutter/material.dart';
import '../core/constants/FontGlobals.dart';

/// Custom Text widget that automatically uses global font settings
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final TextDecoration? decoration;
  final TextDecorationStyle? decorationStyle;
  final Color? decorationColor;
  final double? decorationThickness;

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.decorationThickness,
  });

  @override
  Widget build(BuildContext context) {
    // Create a TextStyle that combines the provided style with global font settings
    final TextStyle effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontFamily: globalFontFamily,
      fontSize:
          globalFontSizeChange <= 17
              ? (globalFontSizeChange / 5) + 20
              : (fontSize ?? style?.fontSize ?? 14) -
                  (globalFontSizeChange / 5),
      fontWeight: fontWeight ?? style?.fontWeight,
      color: color ?? style?.color,
      letterSpacing: letterSpacing ?? style?.letterSpacing,
      wordSpacing: wordSpacing ?? style?.wordSpacing,
      height: height ?? style?.height,
      decoration: decoration ?? style?.decoration,
      decorationStyle: decorationStyle ?? style?.decorationStyle,
      decorationColor: decorationColor ?? style?.decorationColor,
      decorationThickness: decorationThickness ?? style?.decorationThickness,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Custom Text.rich widget that automatically uses global font settings
class CustomTextRich extends StatelessWidget {
  final TextSpan textSpan;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomTextRich(
    this.textSpan, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Apply global font settings to the default style
    final TextStyle effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontFamily: globalFontFamily,
      fontSize:
          globalFontSizeChange <= 17
              ? (globalFontSizeChange / 5) + 20
              : (style?.fontSize ?? 14) - (globalFontSizeChange / 5),
    );

    return Text.rich(
      textSpan,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

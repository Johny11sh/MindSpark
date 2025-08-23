// Global font configuration variables

// Stores only the change (delta) to apply on top of base font sizes across the app
import 'dart:io';

double globalFontSizeChange = 0.0;

// Stores the currently selected font family name
// Must match one of the registered families in pubspec.yaml
String globalFontFamily =
    Platform.isAndroid
        ? 'Roboto'
        : Platform.isIOS
        ? 'Montserrat'
        : 'Montserrat';

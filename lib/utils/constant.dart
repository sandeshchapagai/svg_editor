import 'package:flutter/material.dart';

class AppConstants {
  // File extensions
  static const List<String> supportedExtensions = ['svg'];

  // UI Constants
  static const double borderRadius = 15.0;
  static const double cardElevation = 8.0;
  static const double iconSize = 20.0;
  static const double layerItemHeight = 80.0;

  // Colors
  static const primaryColor = Colors.deepPurple;
  static const backgroundColor = Color(0xFFE8EAF6);

  // Error Messages
  static const String filePickingError = 'Failed to pick file';
  static const String fileSavingError = 'Failed to save file';
  static const String svgParsingError = 'Failed to parse SVG';
  static const String noLayersFoundError = 'No editable layers found in SVG';
}

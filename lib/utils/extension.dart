import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  String toHex() {
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }

  bool get isLight {
    return computeLuminance() > 0.5;
  }

  Color get contrastingTextColor {
    return isLight ? Colors.black : Colors.white;
  }
}

extension StringExtensions on String {
  bool get isSvgFile {
    return toLowerCase().endsWith('.svg');
  }

  String get fileNameWithoutExtension {
    return split('.').first;
  }
}

extension ListExtensions<T> on List<T> {
  List<T> get safely {
    return List.unmodifiable(this);
  }
}

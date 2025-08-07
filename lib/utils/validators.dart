import 'package:svg_editor/utils/extension.dart';

class SvgValidators {
  static bool isValidSvgContent(String content) {
    return content.trim().startsWith('<svg') && content.trim().endsWith('>');
  }

  static bool hasEditableLayers(String content) {
    final editableElements = ['rect', 'circle', 'ellipse', 'path', 'polygon'];
    return editableElements.any((element) => content.contains('<$element'));
  }

  static String? validateFileName(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return 'File name cannot be empty';
    }

    if (!fileName.isSvgFile) {
      return 'File must have .svg extension';
    }

    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(fileName)) {
      return 'File name contains invalid characters';
    }

    return null;
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileService {
  static Future<String?> pickSvgFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['svg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      throw FilePickingException('Failed to pick file: $e');
    }
  }

  static Future<void> saveSvgFile(String content, String fileName) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save SVG File',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['svg'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(content);
      }
    } catch (e) {
      throw FileSavingException('Failed to save file: $e');
    }
  }
}

class FilePickingException implements Exception {
  final String message;
  FilePickingException(this.message);

  @override
  String toString() => 'FilePickingException: $message';
}

class FileSavingException implements Exception {
  final String message;
  FileSavingException(this.message);

  @override
  String toString() => 'FileSavingException: $message';
}

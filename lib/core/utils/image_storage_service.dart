import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static const String _folderName = 'food_images';

  /// Copy image from temp to permanent Documents dir.
  /// Returns permanent file path.
  static Future<String> saveImagePermanently(File tempFile) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      debugPrint('[ImageStorageService] Documents dir: ${docsDir.path}');

      final imagesDir = Directory(path.join(docsDir.path, _folderName));
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final ext = path.extension(tempFile.path).isEmpty
          ? '.jpg'
          : path.extension(tempFile.path);
      final fileName = '${const Uuid().v4()}$ext';
      final permanentPath = path.join(imagesDir.path, fileName);

      final bytes = await tempFile.readAsBytes();
      final permanentFile = File(permanentPath);
      await permanentFile.writeAsBytes(bytes, flush: true);

      if (!await permanentFile.exists()) {
        throw Exception('Permanent image file was not created');
      }

      debugPrint('[ImageStorageService] Temp image: ${tempFile.path}');
      debugPrint('[ImageStorageService] Permanent image: $permanentPath');

      return permanentPath;
    } catch (e) {
      throw Exception('Failed to save image permanently: $e');
    }
  }

  /// Delete image file from Documents directory.
  /// Call this when user deletes a food record.
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Image delete failed: $e');
    }
  }

  /// Check if image file still exists.
  static Future<bool> imageExists(String imagePath) async {
    if (imagePath.isEmpty) {
      return false;
    }
    final exists = await File(imagePath).exists();
    debugPrint('[ImageStorageService] imageExists($imagePath) => $exists');
    return exists;
  }
}

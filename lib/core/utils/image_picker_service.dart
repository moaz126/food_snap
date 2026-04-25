import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  /// Returns null if user cancels or an error occurs
  Future<File?> pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        return File(picked.path);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Pick image from gallery
  /// Returns null if user cancels or an error occurs
  Future<File?> pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        return File(picked.path);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

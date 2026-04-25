import 'package:permission_handler/permission_handler.dart';

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionHandlerHelper {
  /// Request camera permission
  /// Returns [PermissionResult.granted] if permission is granted
  /// Returns [PermissionResult.permanentlyDenied] if permission is permanently denied
  /// Returns [PermissionResult.denied] if permission is denied but not permanently
  static Future<PermissionResult> requestCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return PermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  /// Request photo library permission
  /// Returns [PermissionResult.granted] if permission is granted
  /// Returns [PermissionResult.permanentlyDenied] if permission is permanently denied
  /// Returns [PermissionResult.denied] if permission is denied but not permanently
  static Future<PermissionResult> requestPhotos() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      return PermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return openAppSettings();
  }
}

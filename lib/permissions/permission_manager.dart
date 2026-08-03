import 'package:permission_handler/permission_handler.dart';

/// Dedicated Permission Management Layer
class PermissionManager {
  /// Checks whether microphone permission is granted.
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Requests microphone permission if not already granted.
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Returns true if permission is permanently denied.
  Future<bool> isMicrophonePermanentlyDenied() async {
    final status = await Permission.microphone.status;
    return status.isPermanentlyDenied;
  }

  /// Opens application settings if permission was permanently denied.
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}

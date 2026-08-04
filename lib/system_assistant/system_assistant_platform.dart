import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform bridge communicating with native Android WindowManager overlay and Foreground Service.
class SystemAssistantPlatform {
  static const MethodChannel _channel = MethodChannel('com.sahil.jarvis/overlay');

  /// Checks whether Android SYSTEM_ALERT_WINDOW ("Display over other apps") permission is granted.
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool granted = await _channel.invokeMethod('checkOverlayPermission');
      return granted;
    } catch (e) {
      debugPrint('Error checking overlay permission: $e');
      return false;
    }
  }

  /// Opens Android Settings screen to allow user to grant overlay permission.
  static Future<bool> requestOverlayPermission() async {
    try {
      final bool ok = await _channel.invokeMethod('requestOverlayPermission');
      return ok;
    } catch (e) {
      debugPrint('Error requesting overlay permission: $e');
      return false;
    }
  }

  /// Starts Android Foreground Service with microphone type and notification channel.
  static Future<bool> startForegroundService() async {
    try {
      final bool ok = await _channel.invokeMethod('startForegroundService');
      return ok;
    } catch (e) {
      debugPrint('Error starting foreground service: $e');
      return false;
    }
  }

  /// Stops Android Foreground Service.
  static Future<bool> stopForegroundService() async {
    try {
      final bool ok = await _channel.invokeMethod('stopForegroundService');
      return ok;
    } catch (e) {
      debugPrint('Error stopping foreground service: $e');
      return false;
    }
  }

  /// Displays compact bottom-centered translucent floating overlay over active external applications.
  static Future<bool> showOverlayWindow() async {
    try {
      final bool ok = await _channel.invokeMethod('showOverlayWindow');
      return ok;
    } catch (e) {
      debugPrint('Error showing overlay window: $e');
      return false;
    }
  }

  /// Updates overlay status text and glowing orb color state.
  static Future<bool> updateOverlayState(String state, {String previewText = ''}) async {
    try {
      final bool ok = await _channel.invokeMethod('updateOverlayState', {
        'state': state,
        'previewText': previewText,
      });
      return ok;
    } catch (e) {
      debugPrint('Error updating overlay state: $e');
      return false;
    }
  }

  /// Dismisses floating overlay window.
  static Future<bool> hideOverlayWindow() async {
    try {
      final bool ok = await _channel.invokeMethod('hideOverlayWindow');
      return ok;
    } catch (e) {
      debugPrint('Error hiding overlay window: $e');
      return false;
    }
  }
}

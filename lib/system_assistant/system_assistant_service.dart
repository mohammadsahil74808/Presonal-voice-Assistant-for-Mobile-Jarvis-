import 'package:flutter/foundation.dart';
import 'system_assistant_platform.dart';

/// Centralized Flutter manager orchestrating System-Wide Invocation and Siri-Style Overlay Window.
class SystemAssistantService extends ChangeNotifier {
  bool _isServiceRunning = false;
  bool _hasOverlayPermission = false;
  bool _isOverlayVisible = false;
  String _currentOverlayState = 'idle';

  bool get isServiceRunning => _isServiceRunning;
  bool get hasOverlayPermission => _hasOverlayPermission;
  bool get isOverlayVisible => _isOverlayVisible;
  String get currentOverlayState => _currentOverlayState;

  /// Initializes system assistant lifecycle, verifies Android overlay permission, and starts background service.
  Future<void> initialize() async {
    _hasOverlayPermission = await SystemAssistantPlatform.checkOverlayPermission();
    notifyListeners();
  }

  /// Refreshes and verifies overlay permission status.
  Future<bool> checkPermission() async {
    _hasOverlayPermission = await SystemAssistantPlatform.checkOverlayPermission();
    notifyListeners();
    return _hasOverlayPermission;
  }

  /// Guides user to Android Settings screen to grant "Display over other apps" permission.
  Future<void> requestOverlayPermission() async {
    await SystemAssistantPlatform.requestOverlayPermission();
  }

  /// Enables foreground service to keep JARVIS responsive for background invocation.
  Future<void> enableSystemInvocation() async {
    _hasOverlayPermission = await SystemAssistantPlatform.checkOverlayPermission();
    if (!_hasOverlayPermission) {
      await requestOverlayPermission();
      return;
    }

    final bool started = await SystemAssistantPlatform.startForegroundService();
    if (started) {
      _isServiceRunning = true;
      notifyListeners();
    }
  }

  /// Disables background service.
  Future<void> disableSystemInvocation() async {
    final bool stopped = await SystemAssistantPlatform.stopForegroundService();
    if (stopped) {
      _isServiceRunning = false;
      await hideOverlay();
      notifyListeners();
    }
  }

  /// Displays bottom translucent floating overlay over current screen.
  Future<void> showOverlay({String initialState = 'listening', String preview = ''}) async {
    if (!_hasOverlayPermission) {
      _hasOverlayPermission = await SystemAssistantPlatform.checkOverlayPermission();
      if (!_hasOverlayPermission) return;
    }

    final ok = await SystemAssistantPlatform.showOverlayWindow();
    if (ok) {
      _isOverlayVisible = true;
      _currentOverlayState = initialState;
      await SystemAssistantPlatform.updateOverlayState(initialState, previewText: preview);
      notifyListeners();
    }
  }

  /// Updates overlay status label and glowing orb color state.
  Future<void> updateOverlayState(String state, {String previewText = ''}) async {
    _currentOverlayState = state;
    if (_isOverlayVisible) {
      await SystemAssistantPlatform.updateOverlayState(state, previewText: previewText);
      notifyListeners();
    }
  }

  /// Updates live microphone volume level (0.0 to 1.0) on the overlay window.
  Future<void> updateAudioAmplitude(double amplitude) async {
    if (_isOverlayVisible) {
      await SystemAssistantPlatform.updateAudioAmplitude(amplitude);
    }
  }

  /// Hides floating overlay window.
  Future<void> hideOverlay() async {
    if (_isOverlayVisible) {
      await SystemAssistantPlatform.hideOverlayWindow();
      _isOverlayVisible = false;
      _currentOverlayState = 'idle';
      notifyListeners();
    }
  }

  VoidCallback? _onTriggerCallback;

  /// Sets up trigger listener for background Hey JARVIS wake word or hardware button invocation.
  void setTriggerCallback(VoidCallback callback) {
    _onTriggerCallback = callback;
    SystemAssistantPlatform.registerTriggerHandler(() {
      debugPrint('SystemAssistantService: Received native hardware button or wake word trigger!');
      if (_onTriggerCallback != null) {
        _onTriggerCallback!();
      }
    });
  }
}

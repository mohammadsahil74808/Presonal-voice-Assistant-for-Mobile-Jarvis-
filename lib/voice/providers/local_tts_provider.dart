import 'package:flutter/foundation.dart';
import '../../config/jarvis_voice_config.dart';
import '../tts_service.dart';

/// Future architectural extension point for embedded on-device neural offline voice models (e.g. Piper/Sherpa).
/// Reserved for future phases to prevent memory/APK overhead on standard 4GB RAM devices in Phase 4.
class LocalTTSProvider implements TTSService {
  @override
  bool get isSpeaking => false;

  @override
  Future<void> initialize() async {
    debugPrint('LocalTTSProvider initialization reserved for future fully-offline models.');
  }

  @override
  Future<void> speak(
    String rawText, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
    bool clearPrevious = false,
    JarvisVoiceConfig? config,
  }) async {
    throw UnimplementedError('LocalTTSProvider is an extension point reserved for future on-device modeling.');
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<bool> selectLanguage(String languageCode) async => false;

  @override
  Future<void> setSpeechRate(double rate) async {}

  @override
  Future<void> setPitch(double pitch) async {}

  @override
  Future<bool> selectVoice(Map<String, String> voice) async => false;
}

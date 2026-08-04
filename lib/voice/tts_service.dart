import 'package:flutter/foundation.dart';
import '../config/jarvis_voice_config.dart';

/// Dedicated Text-To-Speech service abstraction layer.
/// Decouples application voice features (Conversation, AI Providers, UI) from specific TTS engines.
/// Supports clean orchestration between Primary Edge Neural voice synthesis and Android System TTS fallback,
/// with extension points ready for future Local or Gemini vocal providers.
abstract class TTSService {
  /// Whether the TTS engine is actively speaking or processing an audio queue.
  bool get isSpeaking;
  
  /// Initializes underlying voice engines and audio focus structures.
  Future<void> initialize();
  
  /// Speaks the given text using the configured voice profile.
  /// [rawText] is automatically pre-processed by TtsTextPreprocessor.
  /// [config] optionally overrides default voice parameters (voice, rate, pitch).
  Future<void> speak(
    String rawText, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
    bool clearPrevious = false,
    JarvisVoiceConfig? config,
  });
  
  /// Halts active speech synthesis immediately and releases audio session focus.
  Future<void> stop();
  
  /// Disposes audio players and engine resources safely.
  Future<void> dispose();
  
  /// Engine adjustment methods for runtime tuning.
  Future<bool> selectLanguage(String languageCode);
  Future<void> setSpeechRate(double rate);
  Future<void> setPitch(double pitch);
  Future<bool> selectVoice(Map<String, String> voice);
}

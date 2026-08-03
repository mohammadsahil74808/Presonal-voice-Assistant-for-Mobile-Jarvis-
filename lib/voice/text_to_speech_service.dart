import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'tts_text_cleaner.dart';

/// Service managing Text-to-Speech playback using Android System TTS engine.
class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing TextToSpeechService: $e');
    }
  }

  /// Speaks the provided text using Android TTS engine.
  Future<void> speak(
    String rawText, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final speakableText = TTSTextCleaner.cleanForSpeech(rawText);
    if (speakableText.isEmpty) return;

    if (_isSpeaking) {
      await stop();
    }

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      if (onStart != null) onStart();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      if (onComplete != null) onComplete();
    });

    try {
      await _flutterTts.speak(speakableText);
    } catch (e) {
      debugPrint('Exception in TTS speak: $e');
      _isSpeaking = false;
      if (onComplete != null) onComplete();
    }
  }

  /// Immediately stops TTS audio output.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  Future<void> dispose() async {
    await stop();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../config/jarvis_voice_config.dart';
import '../tts_service.dart';
import '../tts_text_preprocessor.dart';

/// Service managing Text-to-Speech playback using Android System TTS engine.
/// Acts as a robust offline/network-failure fallback provider within the JARVIS voice pipeline.
class AndroidSystemTTSProvider implements TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _speechQueue = [];
  bool _isInitialized = false;
  bool _isSpeaking = false;
  VoidCallback? _onCompleteCallback;

  @override
  bool get isSpeaking => _isSpeaking || _speechQueue.isNotEmpty;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Default initial attempt to Indian English (en-IN)
      await selectLanguage('en-IN');
      await setSpeechRate(0.5); // Standard conversational cadence for human pacing
      await _flutterTts.setVolume(1.0);
      await setPitch(1.0); // Pure unadjusted frequency

      try {
        final voices = await _flutterTts.getVoices;
        if (voices != null && voices is List) {
          Map? bestVoice;
          int highestScore = -99999;
          final List<String> foundIndianVoices = [];

          for (final voice in voices) {
            if (voice is Map) {
              final name = voice['name']?.toString().toLowerCase() ?? '';
              final locale = voice['locale']?.toString().toLowerCase() ?? '';

              final isIndianLocale = locale.contains('en-in') ||
                  locale.contains('en_in') ||
                  locale.contains('hi-in') ||
                  locale.contains('hi_in') ||
                  locale.contains('ind') ||
                  name.contains('en-in') ||
                  name.contains('hi-in') ||
                  name.contains('india') ||
                  name.contains('cgm') ||
                  name.contains('hda');

              if (isIndianLocale) {
                foundIndianVoices.add('${voice["name"]} ($locale)');
              }

              int score = 0;

              // ULTIMATE PRIORITY 1: Indian Male Voice profiles for pure, authentic Hinglish & English pronunciation (+150,000)
              if (isIndianLocale) {
                score += 150000;
              } else {
                // Penalize foreign US/GB accents ("angrez voice") so Hindi words don't sound weird
                score -= 30000;
              }

              // PRIORITY 2: Strong male vocal profile identifiers (+50,000)
              if (name.contains('male') ||
                  name.contains('-b') ||
                  name.contains('-d') ||
                  name.contains('cgm') ||
                  name.contains('end') ||
                  name.contains('hdb') ||
                  name.contains('prabhat') ||
                  name.contains('wavenet-b')) {
                score += 50000;
              }

              // STRICT PENALTY: Prevent female vocal modules ("ladki wali voice") (-200,000)
              if (name.contains('female') ||
                  name.contains('woman') ||
                  name.contains('girl') ||
                  name.contains('swara') ||
                  name.contains('neerja') ||
                  name.contains('ena') ||
                  name.contains('-a') ||
                  name.contains('-c') ||
                  name.contains('hda')) {
                score -= 200000;
              }

              // PRIORITY 3: High-definition Neural, Studio, Wavy, or Network synthesized speech (+5,000)
              if (name.contains('network') ||
                  name.contains('neural') ||
                  name.contains('studio') ||
                  name.contains('wavy')) {
                score += 5000;
              }

              // Penalty: Low-bitrate robotic metallic offline synthesizers (-1,000)
              if (name.contains('local') ||
                  name.contains('compact') ||
                  name.contains('synth') ||
                  name.contains('espeak')) {
                score -= 1000;
              }

              if (score > highestScore) {
                highestScore = score;
                bestVoice = voice;
              }
            }
          }

          debugPrint('Android System TTS Discovery -> Installed Vocal Modules scanned. Best Male Charon Match Score: $highestScore');

          if (bestVoice != null) {
            final selectedLocale = bestVoice["locale"]?.toString() ?? "en-IN";
            final selectedName = bestVoice["name"]?.toString() ?? "";
            
            await selectLanguage(selectedLocale);
            await selectVoice({"name": selectedName, "locale": selectedLocale});
            debugPrint('Android System TTS hooked Male Vocal Module: $selectedName (Locale: $selectedLocale, Score: $highestScore)');
          } else {
            await selectLanguage('en-IN');
          }
        }
      } catch (voiceErr) {
        debugPrint('Voice auto-selection fallback error: $voiceErr');
        await selectLanguage('en-IN');
      }

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _processQueue();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('Android System TTS Error: $msg');
        _isSpeaking = false;
        _processQueue();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing AndroidSystemTTSProvider: $e');
    }
  }

  @override
  Future<bool> selectLanguage(String languageCode) async {
    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(languageCode);
      if (isAvailable == true || isAvailable == "true" || isAvailable == 1) {
        await _flutterTts.setLanguage(languageCode);
        return true;
      } else if (languageCode == 'hi-IN' || languageCode.startsWith('hi')) {
        await _flutterTts.setLanguage('en-IN');
        return false;
      } else {
        await _flutterTts.setLanguage('en-US');
        return false;
      }
    } catch (e) {
      debugPrint('Language selection fallback error: $e');
      try {
        await _flutterTts.setLanguage('en-US');
      } catch (_) {}
      return false;
    }
  }

  @override
  Future<bool> selectVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
      return true;
    } catch (e) {
      debugPrint('Error selecting voice: $e');
      return false;
    }
  }

  @override
  Future<void> speak(
    String rawText, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
    bool clearPrevious = false,
    JarvisVoiceConfig? config,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (clearPrevious && (_isSpeaking || _speechQueue.isNotEmpty)) {
      await stop();
    }

    final speakableText = TtsTextPreprocessor.cleanForSpeech(rawText);
    if (speakableText.isEmpty) {
      if (onComplete != null && _speechQueue.isEmpty && !_isSpeaking) onComplete();
      return;
    }

    _speechQueue.add(speakableText);

    if (onComplete != null) {
      final existing = _onCompleteCallback;
      _onCompleteCallback = () {
        if (existing != null) existing();
        onComplete();
      };
    }

    if (!_isSpeaking) {
      if (onStart != null) onStart();
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_speechQueue.isEmpty || _isSpeaking) {
      if (_speechQueue.isEmpty && !_isSpeaking && _onCompleteCallback != null) {
        final cb = _onCompleteCallback!;
        _onCompleteCallback = null;
        cb();
      }
      return;
    }

    _isSpeaking = true;
    final nextText = _speechQueue.removeAt(0);

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _processQueue();
    });

    try {
      await _flutterTts.speak(nextText);
    } catch (e) {
      debugPrint('Exception in Android System TTS speak: $e');
      _isSpeaking = false;
      _processQueue();
    }
  }

  @override
  Future<void> stop() async {
    _speechQueue.clear();
    _onCompleteCallback = null;
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping Android System TTS: $e');
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      debugPrint('Error setting pitch: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
  }
}

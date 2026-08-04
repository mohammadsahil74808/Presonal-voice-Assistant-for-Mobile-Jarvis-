import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:flutter/foundation.dart';
import '../../config/jarvis_voice_config.dart';
import '../tts_service.dart';
import '../tts_ssml_builder.dart';
import 'android_system_tts_provider.dart';

/// Primary neural Text-To-Speech engine utilizing Microsoft Edge online synthesis.
/// Provides human-like conversational intonation, authentic Indian Hinglish articulation,
/// Android audio focus control, temporary privacy caching, and seamless offline fallback.
class EdgeNeuralTTSProvider implements TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AndroidSystemTTSProvider _fallbackProvider = AndroidSystemTTSProvider();

  JarvisVoiceConfig _currentConfig = const JarvisVoiceConfig();
  final List<_SpeechItem> _queue = [];
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _usingFallbackForCurrentSession = false;
  File? _activeTempAudioFile;
  StreamSubscription<void>? _completionSubscription;
  StreamSubscription<String>? _errorSubscription;

  @override
  bool get isSpeaking => _isSpeaking || _queue.isNotEmpty || _fallbackProvider.isSpeaking;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Android Audio Focus so JARVIS ducks background music gracefully during speech
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ));

      await _fallbackProvider.initialize();

      _completionSubscription = _audioPlayer.onPlayerComplete.listen((_) {
        _cleanActiveAudioFile();
        _isSpeaking = false;
        _processQueue();
      });

      _errorSubscription = _audioPlayer.onLog.listen((msg) {
        if (msg.toLowerCase().contains('error') || msg.toLowerCase().contains('exception')) {
          debugPrint('AudioPlayer Warning/Error during TTS playback: $msg');
        }
      });

      _isInitialized = true;
      debugPrint('EdgeNeuralTTSProvider Initialized -> Primary Voice: ${_currentConfig.voice} (${_currentConfig.language})');
    } catch (e) {
      debugPrint('Error during EdgeNeuralTTSProvider initialization: $e');
    }
  }

  /// Updates current default vocal parameters.
  void updateConfig(JarvisVoiceConfig newConfig) {
    _currentConfig = newConfig;
    debugPrint('EdgeNeuralTTSProvider Config Updated -> Voice: ${_currentConfig.voice}, Rate: ${_currentConfig.rate}');
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

    if (clearPrevious && (_isSpeaking || _queue.isNotEmpty || _fallbackProvider.isSpeaking)) {
      await stop();
    }

    final cleanedText = TtsSsmlBuilder.formatForSpeech(rawText);
    if (cleanedText.isEmpty) {
      if (onComplete != null && _queue.isEmpty && !_isSpeaking) onComplete();
      return;
    }

    _queue.add(_SpeechItem(
      text: cleanedText,
      config: config ?? _currentConfig,
      onStart: onStart,
      onComplete: onComplete,
    ));

    if (!_isSpeaking && !_usingFallbackForCurrentSession) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty || _isSpeaking) {
      return;
    }

    _isSpeaking = true;
    _usingFallbackForCurrentSession = false;
    final item = _queue.removeAt(0);

    try {
      // Notify speech start transition
      if (item.onStart != null) item.onStart!();

      // Attempt primary synthesis via Edge Neural TTS over network WebSocket
      final communicate = Communicate(
        text: item.text,
        voice: item.config.voice,
        rate: item.config.rate,
        pitch: item.config.pitch,
        volume: item.config.volume,
      );

      // Synthesize with strict timeout to prevent lingering in speaking state during offline network drop
      final Uint8List mp3Bytes = await communicate.toBytes().timeout(const Duration(milliseconds: 3500));
      
      if (mp3Bytes.isEmpty) {
        throw Exception('Edge TTS synthesized 0 bytes.');
      }

      // Store in app-private temporary storage for reliable Android audio decompression
      final tempDir = Directory('${Directory.systemTemp.path}/jarvis_neural_cache');
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      final tempFilePath = '${tempDir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.mp3';
      _activeTempAudioFile = File(tempFilePath);
      await _activeTempAudioFile!.writeAsBytes(mp3Bytes, flush: true);

      // Play audio file
      await _audioPlayer.play(DeviceFileSource(tempFilePath));

      // Attach one-shot completion handler for this queue item
      StreamSubscription? onceComplete;
      onceComplete = _audioPlayer.onPlayerComplete.listen((_) {
        onceComplete?.cancel();
        if (item.onComplete != null) item.onComplete!();
      });

    } catch (e) {
      debugPrint('Edge Neural TTS primary synthesis failed ($e). Executing seamless Android System TTS Fallback.');
      _cleanActiveAudioFile();
      
      _usingFallbackForCurrentSession = true;
      _isSpeaking = false; // Fallback provider will track its own speaking state

      try {
        await _fallbackProvider.speak(
          item.text,
          onStart: () {
            _isSpeaking = true;
          },
          onComplete: () {
            _isSpeaking = false;
            _usingFallbackForCurrentSession = false;
            if (item.onComplete != null) item.onComplete!();
            _processQueue();
          },
          clearPrevious: false,
        );
      } catch (fallbackErr) {
        debugPrint('Both Primary Neural and Fallback System TTS failed: $fallbackErr');
        _isSpeaking = false;
        _usingFallbackForCurrentSession = false;
        if (item.onComplete != null) item.onComplete!();
        _processQueue();
      }
    }
  }

  void _cleanActiveAudioFile() {
    try {
      if (_activeTempAudioFile != null && _activeTempAudioFile!.existsSync()) {
        _activeTempAudioFile!.deleteSync();
      }
      _activeTempAudioFile = null;
    } catch (e) {
      debugPrint('Minor error during temporary audio cache purge: $e');
    }
  }

  @override
  Future<void> stop() async {
    _queue.clear();
    _usingFallbackForCurrentSession = false;
    try {
      await _audioPlayer.stop();
      _cleanActiveAudioFile();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping Neural AudioPlayer: $e');
    }
    try {
      await _fallbackProvider.stop();
    } catch (_) {}
  }

  @override
  Future<bool> selectLanguage(String languageCode) async {
    _currentConfig = _currentConfig.copyWith(language: languageCode);
    return await _fallbackProvider.selectLanguage(languageCode);
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    // Map floating rate (0.5 is normal) into percentage string for neural TTS (-50% to +50%)
    int percent = ((rate - 0.5) * 100).round();
    String rateStr = percent >= 0 ? '+$percent%' : '$percent%';
    if (rate == 0.5) rateStr = '-4%'; // Maintain conversational human pacing default
    _currentConfig = _currentConfig.copyWith(rate: rateStr);
    await _fallbackProvider.setSpeechRate(rate);
  }

  @override
  Future<void> setPitch(double pitch) async {
    int hz = ((pitch - 1.0) * 20).round();
    String pitchStr = hz >= 0 ? '+${hz}Hz' : '${hz}Hz';
    if (pitch == 1.0) pitchStr = '-2Hz';
    _currentConfig = _currentConfig.copyWith(pitch: pitchStr);
    await _fallbackProvider.setPitch(pitch);
  }

  @override
  Future<bool> selectVoice(Map<String, String> voice) async {
    final name = voice['name'] ?? voice['voice'];
    if (name != null && name.isNotEmpty) {
      _currentConfig = _currentConfig.copyWith(voice: name);
    }
    return await _fallbackProvider.selectVoice(voice);
  }

  @override
  Future<void> dispose() async {
    await stop();
    _completionSubscription?.cancel();
    _errorSubscription?.cancel();
    await _audioPlayer.dispose();
    await _fallbackProvider.dispose();

    // Final purge of all private temporary audio artifacts in cache directory
    try {
      final tempDir = Directory('${Directory.systemTemp.path}/jarvis_neural_cache');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}

class _SpeechItem {
  final String text;
  final JarvisVoiceConfig config;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  _SpeechItem({
    required this.text,
    required this.config,
    this.onStart,
    this.onComplete,
  });
}

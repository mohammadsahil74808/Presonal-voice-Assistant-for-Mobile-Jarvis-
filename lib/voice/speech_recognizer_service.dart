import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Real Speech-to-Text service utilizing [SpeechToText] for Android.
class SpeechRecognizerService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _speech.isListening;

  /// Initializes the speech recognizer engine.
  Future<bool> initialize({
    Function(String error)? onError,
    Function(String status)? onStatus,
  }) async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (SpeechRecognitionError errorNotification) {
          debugPrint('Speech error: ${errorNotification.errorMsg}');
          if (onError != null) {
            onError(errorNotification.errorMsg);
          }
        },
        onStatus: (String status) {
          debugPrint('Speech status: $status');
          if (onStatus != null) {
            onStatus(status);
          }
        },
      );
    } catch (e) {
      debugPrint('Exception initializing SpeechToText: $e');
      _isInitialized = false;
      if (onError != null) {
        onError('Failed to initialize speech recognition engine.');
      }
    }

    return _isInitialized;
  }

  /// Starts listening for voice input.
  Future<void> startListening({
    required Function(String transcript, bool isFinal) onResult,
    required Function(String error) onError,
    String languageCode = 'en_IN',
  }) async {
    if (!_isInitialized) {
      final ok = await initialize(onError: onError);
      if (!ok) {
        onError('Speech recognizer unavailable or microphone permission missing.');
        return;
      }
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          localeId: languageCode,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(milliseconds: 2000),
        ),
      );
    } catch (e) {
      debugPrint('Error in startListening: $e');
      onError('Unable to start audio recording session.');
    }
  }

  /// Stops listening and returns final result.
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Cancels active listening session without preserving partial transcript.
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../core/enums/assistant_state.dart';
import '../permissions/permission_manager.dart';
import 'speech_recognizer_service.dart';
import 'wake_word_detector.dart';

/// Orchestrates Speech Recognition, Wake Word Detection, Permissions, and Assistant State.
class VoiceManager extends ChangeNotifier {
  final SpeechRecognizerService _speechRecognizer = SpeechRecognizerService();
  final WakeWordDetector _wakeWordDetector = StandardWakeWordDetector();
  final PermissionManager _permissionManager = PermissionManager();

  AssistantState _state = AssistantState.idle;
  String _partialTranscript = '';
  String _lastUserMessage = '';
  String _errorMessage = '';

  AssistantState get state => _state;
  String get partialTranscript => _partialTranscript;
  String get lastUserMessage => _lastUserMessage;
  String get errorMessage => _errorMessage;

  VoiceManager() {
    _init();
  }

  Future<void> _init() async {
    await _speechRecognizer.initialize(
      onError: (err) {
        _handleError(err);
      },
    );
  }

  /// Toggles voice listening session.
  Future<void> toggleListening() async {
    if (_state == AssistantState.listening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Starts active voice listening session.
  Future<void> startListening() async {
    final hasPerm = await _permissionManager.hasMicrophonePermission();
    if (!hasPerm) {
      final granted = await _permissionManager.requestMicrophonePermission();
      if (!granted) {
        _handleError(
          'Microphone permission is required to speak with JARVIS. Please grant microphone access.',
        );
        return;
      }
    }

    _errorMessage = '';
    _partialTranscript = '';
    _state = AssistantState.listening;
    notifyListeners();

    await _speechRecognizer.startListening(
      onResult: (transcript, isFinal) {
        _partialTranscript = transcript;
        notifyListeners();

        if (isFinal && transcript.trim().isNotEmpty) {
          _processFinalSpeech(transcript);
        }
      },
      onError: (error) {
        _handleError(error);
      },
    );
  }

  /// Stops active listening and processes recorded audio.
  Future<void> stopListening() async {
    await _speechRecognizer.stopListening();
    if (_partialTranscript.isNotEmpty && _state == AssistantState.listening) {
      _processFinalSpeech(_partialTranscript);
    } else {
      _state = AssistantState.idle;
      notifyListeners();
    }
  }

  /// Cancels listening session without preserving input.
  Future<void> cancelListening() async {
    await _speechRecognizer.cancelListening();
    _partialTranscript = '';
    _state = AssistantState.idle;
    notifyListeners();
  }

  void _processFinalSpeech(String rawSpeech) {
    // Command cleaning: Strips "Hey JARVIS" / "JARVIS" wake phrase prefixes if present
    final cleanedCommand = _wakeWordDetector.cleanCommandPrefix(rawSpeech);

    _lastUserMessage = cleanedCommand;
    _partialTranscript = '';
    _state = AssistantState.processing;
    notifyListeners();

    // In Phase 3: Transition to processing then return to idle (Gemini added in Phase 4)
    Future.delayed(const Duration(seconds: 2), () {
      if (_state == AssistantState.processing) {
        _state = AssistantState.idle;
        notifyListeners();
      }
    });
  }

  void _handleError(String message) {
    _errorMessage = message;
    _state = AssistantState.error;
    notifyListeners();
  }

  Future<void> openAppSettings() async {
    await _permissionManager.openSettings();
  }

  @override
  void dispose() {
    _speechRecognizer.cancelListening();
    super.dispose();
  }
}

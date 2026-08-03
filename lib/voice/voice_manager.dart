import 'package:flutter/foundation.dart';
import '../ai/ai_provider.dart';
import '../ai/gemini_provider.dart';
import '../config/secure_storage_service.dart';
import '../core/enums/assistant_state.dart';
import '../permissions/permission_manager.dart';
import 'speech_recognizer_service.dart';
import 'text_to_speech_service.dart';
import 'wake_word_detector.dart';

/// Central Voice Assistant Orchestrator (STT + Gemini AI + TTS + Permissions + Secure Storage)
class VoiceManager extends ChangeNotifier {
  final SpeechRecognizerService _speechRecognizer = SpeechRecognizerService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  final WakeWordDetector _wakeWordDetector = StandardWakeWordDetector();
  final PermissionManager _permissionManager = PermissionManager();
  final SecureStorageService _secureStorage = SecureStorageService();

  AIProvider? _aiProvider;

  AssistantState _state = AssistantState.idle;
  String _partialTranscript = '';
  String _lastUserMessage = '';
  String _errorMessage = '';
  bool _hasApiKey = false;

  final List<Map<String, String>> _conversationHistory = [];

  AssistantState get state => _state;
  String get partialTranscript => _partialTranscript;
  String get lastUserMessage => _lastUserMessage;
  String get errorMessage => _errorMessage;
  bool get hasApiKey => _hasApiKey;
  List<Map<String, String>> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  VoiceManager() {
    _init();
  }

  Future<void> _init() async {
    await _speechRecognizer.initialize(
      onError: (err) => _handleError(err),
    );
    await _ttsService.initialize();
    await checkAndLoadApiKey();
  }

  /// Checks and loads API key securely from local encrypted storage.
  Future<bool> checkAndLoadApiKey() async {
    final key = await _secureStorage.getGeminiApiKey();
    if (key != null && key.trim().isNotEmpty) {
      _aiProvider = GeminiAIProvider(apiKey: key);
      _hasApiKey = true;
    } else {
      _aiProvider = null;
      _hasApiKey = false;
    }
    notifyListeners();
    return _hasApiKey;
  }

  /// Saves a new Gemini API key securely.
  Future<void> setApiKey(String key) async {
    await _secureStorage.saveGeminiApiKey(key);
    await checkAndLoadApiKey();
  }

  /// Removes stored API key.
  Future<void> clearApiKey() async {
    await _secureStorage.deleteGeminiApiKey();
    await checkAndLoadApiKey();
  }

  /// Toggles voice listening session. If speaking, interrupts TTS and starts listening.
  Future<void> toggleListening() async {
    if (_state == AssistantState.speaking) {
      await _ttsService.stop();
    }

    if (_state == AssistantState.listening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Starts listening for voice commands.
  Future<void> startListening() async {
    // If speaking, interrupt TTS immediately
    if (_ttsService.isSpeaking) {
      await _ttsService.stop();
    }

    final hasPerm = await _permissionManager.hasMicrophonePermission();
    if (!hasPerm) {
      final granted = await _permissionManager.requestMicrophonePermission();
      if (!granted) {
        _handleError(
          'Microphone permission is required to speak with JARVIS, Sir. Please grant access in settings.',
        );
        return;
      }
    }

    if (!_hasApiKey) {
      _handleError('Gemini API key is missing. Please set your API key in Settings, Sir.');
      return;
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

  /// Stops listening session.
  Future<void> stopListening() async {
    await _speechRecognizer.stopListening();
    if (_partialTranscript.isNotEmpty && _state == AssistantState.listening) {
      _processFinalSpeech(_partialTranscript);
    } else {
      _state = AssistantState.idle;
      notifyListeners();
    }
  }

  /// Cancels listening session.
  Future<void> cancelListening() async {
    await _speechRecognizer.cancelListening();
    await _ttsService.stop();
    _partialTranscript = '';
    _state = AssistantState.idle;
    notifyListeners();
  }

  /// Processes finalized speech input through Gemini AI and speaks the response via TTS.
  Future<void> _processFinalSpeech(String rawSpeech) async {
    final cleanedCommand = _wakeWordDetector.cleanCommandPrefix(rawSpeech);
    if (cleanedCommand.trim().isEmpty) {
      _state = AssistantState.idle;
      notifyListeners();
      return;
    }

    _lastUserMessage = cleanedCommand;
    _conversationHistory.add({'role': 'user', 'content': cleanedCommand});
    _partialTranscript = '';
    _state = AssistantState.processing;
    notifyListeners();

    if (_aiProvider == null) {
      _handleError('Gemini AI Provider is not configured, Sir.');
      return;
    }

    try {
      final aiResponse = await _aiProvider!.sendMessage(
        cleanedCommand,
        history: _conversationHistory,
      );

      _conversationHistory.add({'role': 'assistant', 'content': aiResponse});
      _state = AssistantState.speaking;
      notifyListeners();

      // Speak response using Android System TTS
      await _ttsService.speak(
        aiResponse,
        onStart: () {
          _state = AssistantState.speaking;
          notifyListeners();
        },
        onComplete: () {
          _state = AssistantState.idle;
          notifyListeners();
        },
      );
    } catch (e) {
      _handleError(e.toString().replaceAll('Exception: ', ''));
    }
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
    _ttsService.dispose();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../ai/ai_provider.dart';
import '../ai/gemini_provider.dart';
import '../config/gemini_config_service.dart';
import '../config/secure_storage_service.dart';
import '../core/enums/assistant_state.dart';
import '../memory/conversation_manager.dart';
import '../permissions/permission_manager.dart';
import '../services/service_locator.dart';
import 'speech_recognizer_service.dart';
import 'tts_service.dart';
import 'wake_word_detector.dart';
import 'audio_level_controller.dart';
import 'speech_animation_controller.dart';

import '../system_assistant/system_assistant_controller.dart';
import '../system_assistant/system_assistant_platform.dart';

/// Central Voice Assistant Orchestrator (STT + Gemini AI + TTS + ConversationManager + Permissions + Audio Reactivity)
class VoiceManager extends ChangeNotifier {
  final SpeechRecognizerService _speechRecognizer;
  final TTSService _ttsService;
  final WakeWordDetector _wakeWordDetector;
  final PermissionManager _permissionManager;
  final SecureStorageService _secureStorage;
  final ConversationManager _conversationManager;
  final GeminiConfigService _configService;
  SystemAssistantController? _systemAssistantController;

  final AudioLevelController audioLevelController = AudioLevelController();
  final SpeechAnimationController speechAnimationController = SpeechAnimationController();

  AIProvider? _aiProvider;
  AssistantState _state = AssistantState.idle;
  String _partialTranscript = '';
  String _lastUserMessage = '';
  String _errorMessage = '';
  bool _hasApiKey = false;

  AssistantState get state => _state;
  String get partialTranscript => _partialTranscript;
  String get lastUserMessage => _lastUserMessage;
  String get errorMessage => _errorMessage;
  bool get hasApiKey => _hasApiKey;
  SystemAssistantController? get systemAssistantController => _systemAssistantController;
  List<Map<String, String>> get conversationHistory => _conversationManager.historyMaps;

  /// Normalized audio amplitude between 0.0 and 1.0 for UI animations (listening microphone volume or TTS speech animation).
  double get currentAmplitude {
    if (_state == AssistantState.listening) {
      return audioLevelController.amplitude;
    } else if (_state == AssistantState.speaking) {
      return speechAnimationController.amplitude;
    }
    return 0.0;
  }

  VoiceManager({
    SpeechRecognizerService? speechRecognizer,
    TTSService? ttsService,
    WakeWordDetector? wakeWordDetector,
    PermissionManager? permissionManager,
    SecureStorageService? secureStorage,
    ConversationManager? conversationManager,
    GeminiConfigService? configService,
  })  : _speechRecognizer = speechRecognizer ?? SpeechRecognizerService(),
        _ttsService = ttsService ?? ServiceLocator.instance.ttsService,
        _wakeWordDetector = wakeWordDetector ?? StandardWakeWordDetector(),
        _permissionManager = permissionManager ?? PermissionManager(),
        _secureStorage = secureStorage ?? ServiceLocator.instance.secureStorage,
        _conversationManager = conversationManager ?? ServiceLocator.instance.conversationManager,
        _configService = configService ?? ServiceLocator.instance.geminiConfigService {
    _init();
  }

  Future<void> _init() async {
    await ServiceLocator.instance.initialize();
    _systemAssistantController = SystemAssistantController(
      voiceManager: this,
      systemService: ServiceLocator.instance.systemAssistantService,
    );
    await _speechRecognizer.initialize(
      onError: (err) => _handleError(err),
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _state == AssistantState.listening) {
          if (_partialTranscript.trim().isNotEmpty) {
            _processFinalSpeech(_partialTranscript);
          } else {
            _state = AssistantState.idle;
            SystemAssistantPlatform.resumeWakeWord();
            notifyListeners();
          }
        }
      },
    );
    _conversationManager.addListener(notifyListeners);
    audioLevelController.addListener(notifyListeners);
    speechAnimationController.addListener(notifyListeners);
    await checkAndLoadApiKey();
  }

  /// Checks and loads API key securely from local encrypted storage or .env fallback.
  Future<bool> checkAndLoadApiKey() async {
    String? key = await _secureStorage.getGeminiApiKey();
    if (key == null || key.trim().isEmpty || key.trim() == 'YOUR_KEY_HERE') {
      key = dotenv.env['GEMINI_API_KEY'];
    }
    if (key != null && key.trim().isNotEmpty && key.trim() != 'YOUR_KEY_HERE') {
      final model = dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.0-flash-lite';
      final deepModel = dotenv.env['GEMINI_DEEP_MODEL'] ?? 'gemini-1.5-pro';
      _aiProvider = GeminiProvider(apiKey: key.trim(), modelName: model, deepModelName: deepModel);
      _configService.updateModel(model);
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

  /// Removes stored API key securely.
  Future<void> deleteApiKey() async {
    await _secureStorage.deleteGeminiApiKey();
    _aiProvider = null;
    _hasApiKey = false;
    notifyListeners();
  }

  Future<void> clearApiKey() async => await deleteApiKey();

  /// Toggles active speech recognition listening session on or off.
  Future<void> toggleListening() async {
    if (_state == AssistantState.listening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Starts interactive voice listening session with microphone permission validation and real-time audio reactivity.
  Future<void> startListening() async {
    // Pause background wake word listener to free microphone for active conversation session
    await SystemAssistantPlatform.pauseWakeWord();

    if (_state == AssistantState.speaking || _ttsService.isSpeaking) {
      speechAnimationController.stopAnimation();
      await _ttsService.stop();
    }

    bool hasMicPermission = await _permissionManager.hasMicrophonePermission();
    if (!hasMicPermission) {
      hasMicPermission = await _permissionManager.requestMicrophonePermission();
      if (!hasMicPermission) {
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
    audioLevelController.reset();
    notifyListeners();

    await _speechRecognizer.startListening(
      languageCode: 'en_IN',
      onSoundLevelChange: (level) {
        audioLevelController.updateLevel(level);
      },
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

  /// Stops listening session and evaluates partial transcript if present.
  Future<void> stopListening() async {
    audioLevelController.reset();
    await _speechRecognizer.stopListening();
    if (_partialTranscript.isNotEmpty && _state == AssistantState.listening) {
      _processFinalSpeech(_partialTranscript);
    } else {
      _state = AssistantState.idle;
      await SystemAssistantPlatform.resumeWakeWord();
      notifyListeners();
    }
  }

  /// Cancels active listening session without preserving partial transcript.
  Future<void> cancelListening() async {
    audioLevelController.reset();
    speechAnimationController.stopAnimation();
    await _speechRecognizer.cancelListening();
    await _ttsService.stop();
    _partialTranscript = '';
    _state = AssistantState.idle;
    await SystemAssistantPlatform.resumeWakeWord();
    notifyListeners();
  }

  /// Processes finalized speech input through Gemini AI and speaks the response via TTS.
  Future<void> _processFinalSpeech(String rawSpeech) async {
    audioLevelController.reset();
    await _speechRecognizer.stopListening();

    final cleanedCommand = _wakeWordDetector.cleanCommandPrefix(rawSpeech);
    final finalClean = ConversationManager.cleanWakePhrase(cleanedCommand);
    if (finalClean.trim().isEmpty) {
      _state = AssistantState.idle;
      await SystemAssistantPlatform.resumeWakeWord();
      notifyListeners();
      return;
    }
    await _generateAndSpeakResponse(finalClean, isFromSpeech: true);
  }

  /// Sends a typed text command directly to Gemini AI and speaks the response.
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (!_hasApiKey) {
      _handleError('Gemini API key is missing. Please set your API key in Settings, Sir.');
      return;
    }

    await SystemAssistantPlatform.pauseWakeWord();

    if (_state == AssistantState.speaking || _ttsService.isSpeaking) {
      speechAnimationController.stopAnimation();
      await _ttsService.stop();
    }
    if (_state == AssistantState.listening) {
      audioLevelController.reset();
      await _speechRecognizer.cancelListening();
    }

    await _generateAndSpeakResponse(text, isFromSpeech: false);
  }

  /// Low-Latency Real-Time Streaming Pipeline with audio feedback protection and chunked sentence speech.
  Future<void> _generateAndSpeakResponse(String userCommand, {bool isFromSpeech = false}) async {
    if (isFromSpeech) {
      audioLevelController.reset();
      await _speechRecognizer.stopListening();
    }

    _lastUserMessage = userCommand;
    _conversationManager.addUserMessage(userCommand, cleanWakeWord: isFromSpeech);
    _errorMessage = '';
    _partialTranscript = '';
    _state = AssistantState.processing;
    notifyListeners();

    if (_aiProvider == null) {
      _handleError('Gemini AI Provider is not configured, Sir.');
      return;
    }

    final StringBuffer fullResponse = StringBuffer();
    final StringBuffer sentenceBuffer = StringBuffer();
    bool startedSpeaking = false;
    bool streamCompleted = false;

    // Capture context history from ConversationManager BEFORE AI begins response
    final historyForAi = _conversationManager.getContext();

    try {
      final stream = _aiProvider!.streamMessage(
        userCommand,
        history: historyForAi,
      );

      await for (final chunk in stream) {
        fullResponse.write(chunk);
        sentenceBuffer.write(chunk);

        _conversationManager.updateLastAssistantMessage(fullResponse.toString());
        if (!startedSpeaking) {
          _state = AssistantState.speaking;
        }
        notifyListeners();

        // Check for natural sentence or clause punctuation to trigger speech without waiting for full stream (<300ms lag)
        final currentBuffer = sentenceBuffer.toString();
        final splitIndex = _findSentenceBreak(currentBuffer);
        if (splitIndex != -1 && splitIndex >= 4) {
          final sentenceToSpeak = currentBuffer.substring(0, splitIndex + 1).trim();
          final remainder = currentBuffer.substring(splitIndex + 1);
          sentenceBuffer.clear();
          sentenceBuffer.write(remainder);

          if (sentenceToSpeak.isNotEmpty) {
            startedSpeaking = true;
            await _speechRecognizer.stopListening(); // Audio feedback protection before speech
            _ttsService.speak(
              sentenceToSpeak,
              onStart: () {
                _state = AssistantState.speaking;
                speechAnimationController.startAnimation();
                notifyListeners();
              },
              onComplete: () {
                if (streamCompleted && !_ttsService.isSpeaking) {
                  speechAnimationController.stopAnimation();
                  _scheduleWakePhraseRecovery();
                }
              },
            );
          }
        }
      }

      streamCompleted = true;

      // Speak remaining words after stream completes
      final finalLeftover = sentenceBuffer.toString().trim();
      if (finalLeftover.isNotEmpty) {
        startedSpeaking = true;
        await _speechRecognizer.stopListening();
        _ttsService.speak(
          finalLeftover,
          onStart: () {
            _state = AssistantState.speaking;
            speechAnimationController.startAnimation();
            notifyListeners();
          },
          onComplete: () {
            speechAnimationController.stopAnimation();
            _scheduleWakePhraseRecovery();
          },
        );
      } else if (!startedSpeaking || !_ttsService.isSpeaking) {
        speechAnimationController.stopAnimation();
        _scheduleWakePhraseRecovery();
      }
    } catch (e) {
      speechAnimationController.stopAnimation();
      _handleError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// After TTS completes, waits a safe interval (350ms) before restoring idle/wake-word recovery without self-echo.
  void _scheduleWakePhraseRecovery() {
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!_ttsService.isSpeaking && (_state == AssistantState.speaking || _state == AssistantState.processing)) {
        speechAnimationController.stopAnimation();
        _state = AssistantState.idle;
        SystemAssistantPlatform.resumeWakeWord();
        notifyListeners();
      }
    });
  }

  /// Helper to find natural sentence breaks for continuous, unbroken audio streaming.
  int _findSentenceBreak(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      // Trigger streaming audio synthesis on complete sentence endings (. ! ? \n) after 15 characters
      if ((char == '.' || char == '!' || char == '?' || char == '\n') && i >= 15) {
        return i;
      }
    }
    return -1;
  }

  /// Clears the active error status and returns assistant state to idle.
  void clearError() {
    audioLevelController.reset();
    speechAnimationController.stopAnimation();
    _errorMessage = '';
    _state = AssistantState.idle;
    SystemAssistantPlatform.resumeWakeWord();
    notifyListeners();
  }

  void _handleError(String message) {
    audioLevelController.reset();
    speechAnimationController.stopAnimation();
    final lower = message.toLowerCase();
    // Ignore benign Android STT timeout / no match notifications
    if (lower.contains('no_match') ||
        lower.contains('error_no_match') ||
        lower.contains('timeout') ||
        lower.contains('error_speech_timeout') ||
        lower.contains('error_busy') ||
        lower.contains('error_recognizer_busy') ||
        lower.contains('error_client')) {
      _state = AssistantState.idle;
      _errorMessage = '';
      SystemAssistantPlatform.resumeWakeWord();
      notifyListeners();
      return;
    }

    _errorMessage = message;
    _state = AssistantState.error;
    SystemAssistantPlatform.resumeWakeWord();
    notifyListeners();
  }

  Future<void> openAppSettings() async {
    await _permissionManager.openSettings();
  }

  @override
  void dispose() {
    _conversationManager.removeListener(notifyListeners);
    audioLevelController.removeListener(notifyListeners);
    speechAnimationController.removeListener(notifyListeners);
    audioLevelController.dispose();
    speechAnimationController.dispose();
    _speechRecognizer.cancelListening();
    _ttsService.dispose();
    super.dispose();
  }
}

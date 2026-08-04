import '../config/gemini_config_service.dart';
import '../config/secure_storage_service.dart';
import '../memory/conversation_manager.dart';
import '../voice/text_to_speech_service.dart';

/// Service locator foundation for dependency localization and clean injection across modular boundaries.
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  ServiceLocator._internal();

  late final SecureStorageService secureStorage = SecureStorageService();
  late final GeminiConfigService geminiConfigService = GeminiConfigService(secureStorage);
  late final ConversationManager conversationManager = ConversationManager();
  late final TTSService ttsService = GeminiTTSProvider(apiKeyGetter: () => geminiConfigService.apiKey);

  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    await geminiConfigService.initialize();
    await ttsService.initialize();
    _initialized = true;
  }
}

import '../config/gemini_config_service.dart';
import '../config/secure_storage_service.dart';
import '../memory/conversation_manager.dart';
import '../system_assistant/system_assistant_service.dart';
import '../voice/text_to_speech_service.dart';

/// Service locator foundation for dependency localization and clean injection across modular boundaries.
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  ServiceLocator._internal();

  late final SecureStorageService secureStorage = SecureStorageService();
  late final GeminiConfigService geminiConfigService = GeminiConfigService(secureStorage);
  late final ConversationManager conversationManager = ConversationManager();
  late final TTSService ttsService = EdgeNeuralTTSProvider();
  late final SystemAssistantService systemAssistantService = SystemAssistantService();

  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    await geminiConfigService.initialize();
    await ttsService.initialize();
    await systemAssistantService.initialize();
    _initialized = true;
  }
}

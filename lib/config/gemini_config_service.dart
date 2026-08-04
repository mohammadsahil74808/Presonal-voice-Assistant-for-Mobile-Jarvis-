import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'gemini_config.dart';
import 'secure_storage_service.dart';

/// Centralized configuration service for Gemini AI Provider.
/// Manages API key availability, validation, storage updates/removals, model selection, and initialization.
class GeminiConfigService extends ChangeNotifier {
  final SecureStorageService _storage;
  GeminiConfig _config = const GeminiConfig(apiKey: '');

  GeminiConfigService(this._storage);

  /// Current immutable configuration instance
  GeminiConfig get config => _config;
  String get apiKey => _config.apiKey;
  String get model => _config.model;
  
  /// Checks whether a valid API key is currently available
  bool get hasApiKey => _config.apiKey.trim().isNotEmpty;

  /// Initializes configuration by retrieving securely stored API keys or falling back to .env
  Future<void> initialize() async {
    final storedKey = await _storage.getGeminiApiKey();
    if (storedKey != null && storedKey.trim().isNotEmpty) {
      _config = _config.copyWith(apiKey: storedKey.trim());
      notifyListeners();
    } else {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.trim().isNotEmpty) {
        _config = _config.copyWith(apiKey: envKey.trim());
        notifyListeners();
      }
    }
  }

  /// Validates format and minimum criteria for an API key without making network calls or logging secrets
  bool validateApiKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length < 15 || !trimmed.startsWith('AIza')) return false;
    return true;
  }

  /// Updates and securely stores the API key if valid
  Future<bool> saveApiKey(String newKey) async {
    if (!validateApiKey(newKey)) {
      return false;
    }
    await _storage.saveGeminiApiKey(newKey.trim());
    _config = _config.copyWith(apiKey: newKey.trim());
    notifyListeners();
    return true;
  }

  /// Removes stored API key securely
  Future<void> removeApiKey() async {
    await _storage.deleteGeminiApiKey();
    _config = _config.copyWith(apiKey: '');
    notifyListeners();
  }

  /// Updates selected conversational model identifier
  void updateModel(String newModel) {
    _config = _config.copyWith(model: newModel.trim());
    notifyListeners();
  }

  /// Updates AI generation parameters
  void updateGenerationSettings({
    double? temperature,
    int? maxOutputTokens,
    double? topP,
    int? topK,
  }) {
    _config = _config.copyWith(
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
      topP: topP,
      topK: topK,
    );
    notifyListeners();
  }
}

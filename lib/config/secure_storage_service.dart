import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service using EncryptedSharedPreferences on Android.
class SecureStorageService {
  static const _keyGeminiApi = 'gemini_api_key';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Retrieves stored Gemini API key securely.
  Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: _keyGeminiApi);
  }

  /// Saves user-provided Gemini API key securely.
  Future<void> saveGeminiApiKey(String apiKey) async {
    await _storage.write(key: _keyGeminiApi, value: apiKey.trim());
  }

  /// Removes stored Gemini API key.
  Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: _keyGeminiApi);
  }

  /// Checks whether a valid API key exists.
  Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.trim().isNotEmpty;
  }
}

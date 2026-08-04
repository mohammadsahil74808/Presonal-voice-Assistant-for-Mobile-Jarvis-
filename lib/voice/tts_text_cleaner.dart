import 'tts_text_preprocessor.dart';

/// Backward-compatibility wrapper around the upgraded TtsTextPreprocessor.
class TTSTextCleaner {
  /// Transforms markdown-formatted AI text into clean, speakable natural prose.
  static String cleanForSpeech(String input) {
    return TtsTextPreprocessor.cleanForSpeech(input);
  }
}

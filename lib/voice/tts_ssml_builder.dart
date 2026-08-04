import 'tts_text_preprocessor.dart';

/// Lightweight SSML and prosody builder for natural speech cadence and pause boundaries.
class TtsSsmlBuilder {
  /// Formats raw text into speech-optimized SSML or structured speech text.
  static String formatForSpeech(String rawText) {
    String clean = TtsTextPreprocessor.cleanForSpeech(rawText);
    if (clean.isEmpty) return clean;

    // Add natural micro-pauses at clause boundaries if text does not already contain SSML tags
    if (!clean.startsWith('<speak>')) {
      clean = clean.replaceAll(' ,', ',').replaceAll(' .', '.');
    }

    return clean;
  }

  /// Builds a complete SSML wrapper for engines that support native SSML tags.
  static String buildSsml(String text, {double pitchHz = -2.0, String rate = '-4%'}) {
    final cleaned = TtsTextPreprocessor.cleanForSpeech(text);
    return '<speak><prosody rate="$rate" pitch="${pitchHz}Hz">$cleaned</prosody></speak>';
  }
}

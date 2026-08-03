import 'package:flutter/foundation.dart';

/// Abstract interface for Wake Word Detection.
abstract class WakeWordDetector {
  Future<void> startDetection({required VoidCallback onWakeWordDetected});
  Future<void> stopDetection();
  bool isTargetWakeWord(String text);
  String cleanCommandPrefix(String rawInput);
}

/// Local Command-Cleaning & Wake-Word Service implementation.
class StandardWakeWordDetector implements WakeWordDetector {
  static const List<String> wakePhrases = [
    'hey jarvis',
    'ok jarvis',
    'okay jarvis',
    'jarvis',
  ];

  @override
  Future<void> startDetection({required VoidCallback onWakeWordDetected}) async {
    // Architecture placeholder for future native local engine (e.g., Porcupine/Snowboy)
    debugPrint('WakeWordDetector: Listening for wake phrase (Hey JARVIS / JARVIS)...');
  }

  @override
  Future<void> stopDetection() async {
    debugPrint('WakeWordDetector: Detection stopped.');
  }

  @override
  bool isTargetWakeWord(String text) {
    final lower = text.trim().toLowerCase();
    return wakePhrases.any((phrase) => lower.contains(phrase));
  }

  @override
  String cleanCommandPrefix(String rawInput) {
    String cleaned = rawInput.trim();
    final lower = cleaned.toLowerCase();

    for (final phrase in wakePhrases) {
      if (lower.startsWith(phrase)) {
        cleaned = cleaned.substring(phrase.length).trim();
        // Remove leading punctuation if user said "Hey JARVIS, ..."
        if (cleaned.startsWith(',') || cleaned.startsWith('.')) {
          cleaned = cleaned.substring(1).trim();
        }
        break;
      }
    }

    return cleaned.isEmpty ? rawInput : cleaned;
  }
}

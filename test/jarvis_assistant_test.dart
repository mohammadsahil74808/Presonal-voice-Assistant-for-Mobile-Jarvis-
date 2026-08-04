import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_mobile/voice/audio_level_controller.dart';
import 'package:jarvis_mobile/voice/speech_animation_controller.dart';
import 'package:jarvis_mobile/voice/tts_text_preprocessor.dart';
import 'package:jarvis_mobile/memory/conversation_manager.dart';

void main() {
  group('JARVIS Assistant Comprehensive Diagnostic Suite', () {

    test('1. TTS Preprocessor - Clean Speech Transformation', () {
      final input = 'Hello! Your balance is 500 rupees & status is #1.';
      final processed = TtsTextPreprocessor.cleanForSpeech(input);

      expect(processed, contains('Hello'));
      expect(processed.contains('#'), isFalse);
    });

    test('2. Audio Level Controller - Signal Normalization & Damping', () {
      final controller = AudioLevelController();
      expect(controller.amplitude, equals(0.0));

      // Simulate decibel input
      controller.updateLevel(6.0);
      expect(controller.amplitude, greaterThan(0.0));
      expect(controller.amplitude, lessThanOrEqualTo(1.0));

      controller.reset();
      expect(controller.amplitude, equals(0.0));
    });

    test('3. Speech Animation Controller - Vocal Rhythm Sync', () {
      final controller = SpeechAnimationController();
      expect(controller.isSpeaking, isFalse);
      expect(controller.amplitude, equals(0.0));

      controller.startAnimation();
      expect(controller.isSpeaking, isTrue);

      controller.stopAnimation();
      expect(controller.isSpeaking, isFalse);
      expect(controller.amplitude, equals(0.0));
    });

    test('4. Conversation Manager - Wake Phrase Stripping', () {
      final clean1 = ConversationManager.cleanWakePhrase('hey jarvis call sahil');
      expect(clean1.trim().toLowerCase(), equals('call sahil'));

      final clean2 = ConversationManager.cleanWakePhrase('ok jarvis what is the weather');
      expect(clean2.trim().toLowerCase(), equals('what is the weather'));
    });
  });
}

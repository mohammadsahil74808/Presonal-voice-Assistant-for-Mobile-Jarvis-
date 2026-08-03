/// Interface abstraction for Speech Input & TTS Pipeline
abstract class VoicePipeline {
  Future<void> startListening();
  Future<void> stopListening();
  Future<void> speak(String text);
  Future<void> stopSpeaking();
}

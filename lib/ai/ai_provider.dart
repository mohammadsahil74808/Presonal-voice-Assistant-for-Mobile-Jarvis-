/// Abstract interface for AI Providers (Gemini, Local LLM in future, etc.)
abstract class AIProvider {
  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? history,
  });

  Stream<String> streamMessage(
    String message, {
    List<Map<String, String>>? history,
  });
}

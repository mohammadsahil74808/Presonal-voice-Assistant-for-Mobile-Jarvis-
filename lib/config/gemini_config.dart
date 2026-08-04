/// Configurable model identifier and generation parameters for Gemini AIProvider.
class GeminiConfig {
  final String apiKey;
  final String model;
  final double temperature;
  final int maxOutputTokens;
  final double topP;
  final int topK;

  const GeminiConfig({
    required this.apiKey,
    this.model = 'gemini-3.5-flash-lite',
    this.temperature = 0.7,
    this.maxOutputTokens = 800,
    this.topP = 0.95,
    this.topK = 40,
  });

  GeminiConfig copyWith({
    String? apiKey,
    String? model,
    double? temperature,
    int? maxOutputTokens,
    double? topP,
    int? topK,
  }) {
    return GeminiConfig(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxOutputTokens: maxOutputTokens ?? this.maxOutputTokens,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
    );
  }
}

/// Centralized voice configuration for JARVIS Neural Text-To-Speech engine.
/// Decouples voice synthesis tuning (voice selection, speed, resonance) from provider implementations.
class JarvisVoiceConfig {
  /// Selected Microsoft Edge Neural voice identifier.
  /// Preferred Default: 'en-IN-PrabhatNeural' (warm, professional Indian male voice with exceptional Hinglish & English handling).
  final String voice;

  /// Primary target language locale.
  final String language;

  /// Speech percentage rate variation formatted as a signed percentage string (e.g., '-4%' or '+0%').
  /// A slightly slower conversational cadence prevents the speech from sounding like a frantic narration engine.
  final String rate;

  /// Frequency acoustic pitch adjustment (e.g., '-2Hz' or '+0Hz').
  /// Slight negative adjustment provides a calm, grounded, and confident male resonance.
  final String pitch;

  /// Master TTS audio gain volume (e.g., '+0%' for normalized full gain).
  final String volume;

  const JarvisVoiceConfig({
    this.voice = defaultVoice,
    this.language = defaultLanguage,
    this.rate = defaultRate,
    this.pitch = defaultPitch,
    this.volume = defaultVolume,
  });

  // Recommended Neural Male Voice Presets
  static const String defaultVoice = 'hi-IN-MadhurNeural'; // Madhur: Premier Deep Indian Male Neural Voice
  static const String indianEnglishMale = 'en-IN-PrabhatNeural';
  static const String movieJarvisMale = 'en-GB-RyanNeural';
  static const String usJarvisMale = 'en-US-ChristopherNeural';

  static const String defaultLanguage = 'hi-IN';
  static const String defaultRate = '+10%';
  static const String defaultPitch = '0Hz';
  static const String defaultVolume = '+0%';

  /// Creates a copy of this configuration with optional overrides.
  JarvisVoiceConfig copyWith({
    String? voice,
    String? language,
    String? rate,
    String? pitch,
    String? volume,
  }) {
    return JarvisVoiceConfig(
      voice: voice ?? this.voice,
      language: language ?? this.language,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
    );
  }

  /// Exports config parameters as a readable debug map.
  Map<String, String> toMap() {
    return {
      'voice': voice,
      'language': language,
      'rate': rate,
      'pitch': pitch,
      'volume': volume,
    };
  }
}

import 'providers/android_system_tts_provider.dart';
import 'providers/gemini_tts_provider.dart';

export 'tts_service.dart';
export 'tts_text_preprocessor.dart';
export 'tts_text_cleaner.dart';
export 'providers/android_system_tts_provider.dart';
export 'providers/edge_neural_tts_provider.dart';
export 'providers/gemini_tts_provider.dart';
export 'providers/local_tts_provider.dart';

/// Backward compatibility typedefs mapping to the new multi-provider voice architecture.
typedef AndroidTTSProvider = AndroidSystemTTSProvider;
typedef TextToSpeechService = GeminiTTSProvider;

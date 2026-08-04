import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_provider.dart';
import 'jarvis_system_instruction.dart';

/// Type alias for backward compatibility across modular architectures
typedef GeminiAIProvider = GeminiProvider;

/// Gemini AI Provider implementation with intelligent Dual-Engine Auto-Routing (Flash-Lite for speed, Flash for deep reasoning).
class GeminiProvider implements AIProvider {
  final String apiKey;
  final String modelName;
  final String deepModelName;

  late final GenerativeModel _defaultModel; // Fast conversational engine (e.g. gemini-3.5-flash-lite)
  late final GenerativeModel _deepModel;    // Analytical reasoning engine (e.g. gemini-3.5-flash)
  late final GenerativeModel _backupModel;  // Stable fallback engine (gemini-2.0-flash)

  GeminiProvider({
    required this.apiKey,
    this.modelName = 'gemini-2.0-flash',
    this.deepModelName = 'gemini-1.5-pro',
  }) {
    _initModel();
  }

  void _initModel() {
    final instructions = JarvisSystemInstruction.buildInstruction();
    _defaultModel = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(instructions),
    );
    _deepModel = GenerativeModel(
      model: deepModelName,
      apiKey: apiKey,
      systemInstruction: Content.system(instructions),
    );
    _backupModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(instructions),
    );
  }

  /// Determines whether a user prompt requires complex analysis/deep reasoning or is a standard conversational query.
  bool _isDeepReasoningQuery(String message) {
    final lower = message.toLowerCase();

    // Only route to heavy deep analysis if prompt is very long or explicitly asks for exhaustive essay breakdown
    if (message.length > 250) return true;

    final deepKeywords = [
      'explain in deep detail', 'exhaustive essay', 'step by step architecture',
      'comprehensive comparison', 'detailed technical report', 'deep dive summary'
    ];

    for (final kw in deepKeywords) {
      if (lower.contains(kw)) {
        return true;
      }
    }

    // Default to ultra-fast high-speed engines for 99% of conversational queries
    return false;
  }

  @override
  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? history,
  }) async {
    if (apiKey.trim().isEmpty) {
      return 'Sir, the Gemini API key is not configured. Please set your API key in settings.';
    }

    final chatContents = _buildChatContents(message, history);
    final isDeep = _isDeepReasoningQuery(message);
    // Prioritize ultra-fast stable 2.0-flash immediately if 3.5-flash-lite encounters temporary server traffic load
    final modelsToTry = isDeep 
        ? [_deepModel, _defaultModel, _backupModel] 
        : [_defaultModel, _backupModel, _deepModel];

    String lastError = '';
    for (final model in modelsToTry) {
      try {
        debugPrint('JARVIS Auto-Routing (sendMessage) -> Attempting AI engine...');
        final chat = model.startChat(history: chatContents.sublist(0, chatContents.length - 1));
        final response = await chat.sendMessage(chatContents.last).timeout(
              const Duration(seconds: 12),
            );

        final text = response.text;
        if (text != null && text.trim().isNotEmpty) {
          return text.trim();
        }
      } catch (e) {
        debugPrint('Error with AI engine: $e');
        lastError = e.toString().toLowerCase();
        debugPrint('JARVIS Resilience Engine -> Seamlessly switching to backup AI engine...');
      }
    }

    if (lastError.contains('api_key_invalid') || lastError.contains('invalid api key') || lastError.contains('401') || lastError.contains('unauthorized')) {
      return 'Sir, the provided API key appears to be invalid. Please check your settings.';
    } else if (lastError.contains('socketexception') || lastError.contains('network') || lastError.contains('timeout') || lastError.contains('connection')) {
      return "I can't reach Gemini right now, Sir. Please check your internet connection.";
    } else if (lastError.contains('quota') || lastError.contains('rate limit') || lastError.contains('429')) {
      return "Sir, our API quota or rate limit has been reached. Please try again shortly.";
    }
    return "I can't reach Gemini right now, Sir.";
  }

  @override
  Stream<String> streamMessage(
    String message, {
    List<Map<String, String>>? history,
  }) async* {
    if (apiKey.trim().isEmpty) {
      yield 'Sir, the Gemini API key is not configured. Please set your API key in settings.';
      return;
    }

    final chatContents = _buildChatContents(message, history);
    final isDeep = _isDeepReasoningQuery(message);
    final modelsToTry = isDeep 
        ? [_deepModel, _defaultModel, _backupModel] 
        : [_defaultModel, _backupModel, _deepModel];

    bool receivedAnyChunk = false;
    String lastError = '';

    for (final model in modelsToTry) {
      try {
        debugPrint('JARVIS Auto-Routing (streamMessage) -> Attempting AI engine...');
        final chat = model.startChat(history: chatContents.sublist(0, chatContents.length - 1));
        final responseStream = chat.sendMessageStream(chatContents.last);

        await for (final chunk in responseStream) {
          if (chunk.text != null && chunk.text!.isNotEmpty) {
            receivedAnyChunk = true;
            yield chunk.text!;
          }
        }
        if (receivedAnyChunk) return;
      } catch (e) {
        debugPrint('Stream Error on AI engine: $e');
        lastError = e.toString().toLowerCase();
        if (receivedAnyChunk) {
          // If stream already started delivering output, do not repeat with another model
          return;
        }
        debugPrint('JARVIS Resilience Engine -> Seamlessly switching to backup AI engine...');
      }
    }

    if (!receivedAnyChunk) {
      if (lastError.contains('api_key_invalid') || lastError.contains('invalid api key') || lastError.contains('401')) {
        yield 'Sir, the provided API key appears to be invalid. Please check your settings.';
      } else if (lastError.contains('socketexception') || lastError.contains('network') || lastError.contains('connection') || lastError.contains('timeout')) {
        yield "I can't reach Gemini right now, Sir.";
      } else if (lastError.contains('quota') || lastError.contains('rate limit') || lastError.contains('429')) {
        yield "Sir, our API quota or rate limit has been reached. Please try again shortly.";
      } else {
        yield "I can't reach Gemini right now, Sir.";
      }
    }
  }

  List<Content> _buildChatContents(
    String currentMessage,
    List<Map<String, String>>? history,
  ) {
    final List<Content> contents = [];

    if (history != null && history.isNotEmpty) {
      // Limit to last 8 turns to keep short-term context lightweight and within conversational budget
      final recent = history.length > 8
          ? history.sublist(history.length - 8)
          : history;

      for (final msg in recent) {
        final role = msg['role'] ?? 'user';
        final text = msg['content'] ?? '';
        if (text.isNotEmpty) {
          if (role == 'user') {
            contents.add(Content.text(text));
          } else {
            contents.add(Content.model([TextPart(text)]));
          }
        }
      }
    }

    contents.add(Content.text(currentMessage));
    return contents;
  }
}

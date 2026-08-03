import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_provider.dart';

/// Gemini AI Provider implementation using official google_generative_ai SDK.
class GeminiAIProvider implements AIProvider {
  final String _apiKey;
  final String _modelName;
  late final GenerativeModel _model;

  static const String systemInstructionText = '''
You are JARVIS, a highly intelligent, calm, respectful, and technically capable personal AI assistant.
Key instructions:
1. Always address the user respectfully as "Sir".
2. Keep your spoken responses concise, natural, and conversational unless the user asks for deep detail.
3. You natively support English and Hinglish (natural Hindi-English code-switching).
4. Be direct and helpful. Avoid robotic filler phrases like "How may I assist you today?" unless contextually ideal.
5. Do not claim to have performed physical actions unless an actual tool confirmed it.
''';

  GeminiAIProvider({
    required String apiKey,
    String modelName = 'gemini-1.5-flash',
  })  : _apiKey = apiKey,
        _modelName = modelName {
    _initModel();
  }

  void _initModel() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstructionText),
    );
  }

  @override
  Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? history,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw Exception('Gemini API key is not configured. Please set your API key in Settings, Sir.');
    }

    try {
      final chatContents = _buildChatContents(message, history);
      final chat = _model.startChat(history: chatContents.sublist(0, chatContents.length - 1));
      final response = await chat.sendMessage(chatContents.last).timeout(
            const Duration(seconds: 20),
          );

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return 'Sir, I received an empty response from Gemini.';
      }
      return text.trim();
    } on TimeoutException {
      return 'Sir, the connection to Gemini timed out. Please check your internet connection.';
    } catch (e) {
      debugPrint('Gemini Error: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('api_key_invalid') || errStr.contains('invalid api key')) {
        throw Exception('Invalid Gemini API Key provided. Please update your API Key, Sir.');
      } else if (errStr.contains('quota') || errStr.contains('429')) {
        return 'Sir, API rate limit or quota exceeded. Please try again in a moment.';
      } else if (errStr.contains('socketexception') || errStr.contains('network')) {
        return "Sir, I can't reach Gemini right now. Please check your internet connection.";
      }
      return 'Sir, an error occurred while connecting to Gemini: $e';
    }
  }

  @override
  Stream<String> streamMessage(
    String message, {
    List<Map<String, String>>? history,
  }) async* {
    if (_apiKey.trim().isEmpty) {
      yield 'Gemini API key is not configured. Please set your API key in Settings, Sir.';
      return;
    }

    try {
      final chatContents = _buildChatContents(message, history);
      final chat = _model.startChat(history: chatContents.sublist(0, chatContents.length - 1));
      final responseStream = chat.sendMessageStream(chatContents.last);

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      debugPrint('Gemini Stream Error: $e');
      yield 'Sir, an error occurred while streaming response from Gemini.';
    }
  }

  List<Content> _buildChatContents(
    String currentMessage,
    List<Map<String, String>>? history,
  ) {
    final List<Content> contents = [];

    if (history != null && history.isNotEmpty) {
      // Limit to last 10 turns to keep short-term context lightweight
      final recent = history.length > 10
          ? history.sublist(history.length - 10)
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

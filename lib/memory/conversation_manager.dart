import 'package:flutter/foundation.dart';

/// Represents an immutable conversation message turn.
class ConversationMessage {
  final String role; // 'user' or 'assistant' / 'model'
  final String content;
  final DateTime timestamp;

  const ConversationMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, String> toMap() => {
        'role': role,
        'content': content,
      };
}

/// Dedicated Conversation layer managing short-term conversation history and intelligent context trimming.
/// Ensures GeminiProvider does not own the conversation lifecycle directly.
class ConversationManager extends ChangeNotifier {
  final List<ConversationMessage> _messages = [];
  final int maxTurns; // Intelligent limit to avoid unnecessary token usage and overflow

  ConversationManager({this.maxTurns = 8}); // Retain recent turns for intelligent short-term context

  List<ConversationMessage> get messages => List.unmodifiable(_messages);

  /// Clean up wake phrases ("Hey JARVIS", "JARVIS") before feeding speech transcripts to AI provider.
  static String cleanWakePhrase(String transcript) {
    if (transcript.trim().isEmpty) return transcript;
    String text = transcript.trim();
    
    // Regular expression to strip leading wake phrases case-insensitively
    final wakeRegExp = RegExp(
      r'^(hey\s+jarvis|hi\s+jarvis|hello\s+jarvis|ok\s+jarvis|okay\s+jarvis|jarvis)[\s,\.\!\:\;\-]*',
      caseSensitive: false,
    );
    
    text = text.replaceFirst(wakeRegExp, '').trim();
    // Capitalize first character of the cleaned query
    if (text.isNotEmpty && text.length > 1) {
      text = text[0].toUpperCase() + text.substring(1);
    } else if (text.isNotEmpty) {
      text = text.toUpperCase();
    }
    return text;
  }

  /// Appends a user query to the short-term conversation context after cleaning any leading wake phrases.
  void addUserMessage(String message, {bool cleanWakeWord = false}) {
    final text = cleanWakeWord ? cleanWakePhrase(message) : message.trim();
    if (text.isEmpty) return;

    _messages.add(ConversationMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    ));
    trimContext();
    notifyListeners();
  }

  /// Appends an AI assistant response to the short-term conversation context.
  void addAssistantMessage(String message) {
    if (message.trim().isEmpty) return;

    _messages.add(ConversationMessage(
      role: 'assistant',
      content: message.trim(),
      timestamp: DateTime.now(),
    ));
    trimContext();
    notifyListeners();
  }

  /// Updates or appends the ongoing streaming assistant response in real-time.
  void updateLastAssistantMessage(String fullContent) {
    if (_messages.isNotEmpty && (_messages.last.role == 'assistant' || _messages.last.role == 'model')) {
      _messages[_messages.length - 1] = ConversationMessage(
        role: 'assistant',
        content: fullContent,
        timestamp: _messages.last.timestamp,
      );
    } else {
      _messages.add(ConversationMessage(
        role: 'assistant',
        content: fullContent,
        timestamp: DateTime.now(),
      ));
      trimContext();
    }
    notifyListeners();
  }

  /// Returns UI-friendly history maps for rendering chat bubbles reactively.
  List<Map<String, String>> get historyMaps => _messages.map((m) => {
        'role': m.role,
        'content': m.content,
      }).toList();

  /// Retrieves structured context formatted for AI Provider transmission.
  /// Converts 'assistant' role to 'model' for compatibility with Gemini APIs.
  List<Map<String, String>> getContext() {
    return _messages.map((m) => {
      'role': (m.role == 'assistant' || m.role == 'model') ? 'model' : 'user',
      'content': m.content,
    }).toList();
  }

  /// Clears short-term conversation session history.
  void clearConversation() {
    _messages.clear();
    notifyListeners();
  }

  /// Intelligently trims short-term context to retain the most recent relevant turns while preventing token bloat.
  void trimContext() {
    while (_messages.length > maxTurns) {
      _messages.removeAt(0);
    }
    // Ensure conversation sent to chat model starts with a user turn if history is truncated
    while (_messages.isNotEmpty && _messages.first.role == 'assistant') {
      _messages.removeAt(0);
    }
  }
}

/// Utility class to clean raw AI text responses before Text-To-Speech audio playback.
class TTSTextCleaner {
  /// Transforms markdown-formatted AI text into clean, speakable natural prose.
  static String cleanForSpeech(String input) {
    if (input.isEmpty) return input;

    String text = input;

    // Remove code blocks ```code```
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), 'code block omitted');

    // Remove inline code `code`
    text = text.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

    // Remove Markdown Headers (# Header -> Header)
    text = text.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');

    // Remove Bold/Italic formatting (**bold** or *italic* or __bold__)
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    text = text.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    text = text.replaceAll(RegExp(r'_([^_]+)_'), r'$1');

    // Remove Markdown Links [text](url) -> text
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');

    // Remove bullet point markers (* or - at start of line)
    text = text.replaceAll(RegExp(r'^\s*[\*\-]\s+', multiLine: true), '');

    // Clean multiple spaces/newlines
    text = text.replaceAll(RegExp(r'\n+'), '. ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text.trim();
  }
}

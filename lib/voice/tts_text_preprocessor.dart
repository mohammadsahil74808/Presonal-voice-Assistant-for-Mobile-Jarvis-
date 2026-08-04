/// Dedicated text preprocessor to refine raw AI output into human-like spoken speech.
/// Strips UI formatting, Markdown syntax, technical jargon, and disruptive symbols while preserving
/// meaningful conversational punctuation for authentic vocal pauses.
class TtsTextPreprocessor {
  /// Cleans and optimizes raw AI text for natural neural voice synthesis.
  static String cleanForSpeech(String input) {
    if (input.trim().isEmpty) return '';

    String text = input;

    // 1. Replace code blocks ```code``` with a natural spoken notification
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), ' Sir, I have displayed the complete code structure on your screen. ');

    // 2. Strip inline code snippets
    text = text.replaceAll(RegExp(r'`([^`]+)`'), r'$1');

    // 3. Remove Markdown Headers (## Header -> Header) and Blockquotes (> quote)
    text = text.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*>\s+', multiLine: true), '');

    // 4. Strip Markdown emphasis (**bold**, *italic*, __bold__, _italic_, ~~strikethrough~~)
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    text = text.replaceAll(RegExp(r'__([^_]+)__'), r'$1');
    text = text.replaceAll(RegExp(r'_([^_]+)_'), r'$1');
    text = text.replaceAll(RegExp(r'~~([^~]+)~~'), r'$1');

    // 5. Transform Markdown links [Title](URL) into spoken title only
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');

    // 6. Strip list formatting bullet symbols (*, -, +) and numbered prefixes ("1. ") at start of lines
    text = text.replaceAll(RegExp(r'^\s*[\*\-\+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // 7. Convert repetitive ellipses or trailing periods (...) into a natural conversational pause (soft comma)
    text = text.replaceAll(RegExp(r'\.{2,}'), ', ');

    // 8. Convert disruptive structural punctuation (colons, semicolons, dashes, brackets, pipes) into soft conversational pauses
    text = text.replaceAll(RegExp(r'[\:\;\-\–\—\(\)\[\]\|\{\}]'), ', ');

    // 9. Remove technical markup symbols and stray characters that trigger vocal stutters
    text = text.replaceAll(RegExp(r'[\~\#\^\_\`\\<\>\|\@\%\$\&]'), ' ');
    text = text.replaceAll('**', ' ');
    text = text.replaceAll('*', ' ');

    // 10. Smooth out line breaks and multiple newlines into conversational breath pauses
    text = text.replaceAll(RegExp(r'\n+'), ', ');

    // 11. Clean repetitive consecutive punctuation and normalize whitespace
    text = text.replaceAll(RegExp(r'[\,\s]{2,}'), ', ');
    text = text.replaceAll(RegExp(r'\,\s*\.'), '. ');
    text = text.replaceAll(RegExp(r'\.\s*\,'), '. ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Trim trailing or leading orphaned commas
    text = text.trim();
    if (text.startsWith(',')) text = text.substring(1).trim();
    if (text.endsWith(',')) text = text.substring(0, text.length - 1).trim();

    return text;
  }
}

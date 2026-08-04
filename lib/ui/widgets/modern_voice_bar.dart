import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

class ModernVoiceBar extends StatefulWidget {
  final AssistantState state;
  final String partialTranscript;
  final VoidCallback onMicTap;
  final VoidCallback? onCancelTap;
  final Function(String text)? onSendText;

  const ModernVoiceBar({
    super.key,
    required this.state,
    required this.partialTranscript,
    required this.onMicTap,
    this.onCancelTap,
    this.onSendText,
  });

  @override
  State<ModernVoiceBar> createState() => _ModernVoiceBarState();
}

class _ModernVoiceBarState extends State<ModernVoiceBar> {
  final TextEditingController _textController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final notEmpty = _textController.text.trim().isNotEmpty;
      if (notEmpty != _hasText) {
        setState(() {
          _hasText = notEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.onSendText != null) {
      widget.onSendText!(text);
      _textController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.state == AssistantState.listening;
    final isProcessing = widget.state == AssistantState.processing;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: JarvisTheme.cardDark,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isListening
              ? JarvisTheme.cyanAccent
              : isProcessing
                  ? JarvisTheme.amberWarning
                  : JarvisTheme.cyanAccent.withValues(alpha: 0.25),
          width: isListening ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isListening
                ? JarvisTheme.cyanAccent.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: isListening ? 2 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Text Input or Live Voice Transcript Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: isListening
                  ? Text(
                      widget.partialTranscript.isEmpty
                          ? "Listening... Speak naturally, Sir"
                          : widget.partialTranscript,
                      style: const TextStyle(
                        color: JarvisTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : TextField(
                      controller: _textController,
                      style: const TextStyle(
                        color: JarvisTheme.textPrimary,
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText: isProcessing
                            ? "Processing input..."
                            : "Type a command or tap mic, Sir...",
                        hintStyle: const TextStyle(
                          color: JarvisTheme.textSecondary,
                          fontSize: 13.5,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _submitText(),
                    ),
            ),
          ),

          if (isListening && widget.onCancelTap != null)
            IconButton(
              onPressed: widget.onCancelTap,
              icon: const Icon(Icons.close_rounded,
                  color: JarvisTheme.textMuted, size: 20),
              tooltip: 'Cancel recording',
            ),

          // Action Button: Send Icon when typing text, Mic Icon otherwise
          GestureDetector(
            onTap: (_hasText && !isListening) ? _submitText : widget.onMicTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_hasText && !isListening)
                    ? JarvisTheme.cyanAccent
                    : isListening
                        ? JarvisTheme.cyanAccent
                        : isProcessing
                            ? JarvisTheme.amberWarning
                            : JarvisTheme.cyanAccent.withValues(alpha: 0.15),
                border: Border.all(
                  color: (_hasText || isListening)
                      ? Colors.white
                      : JarvisTheme.cyanAccent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: (_hasText || isListening)
                    ? [
                        BoxShadow(
                          color: JarvisTheme.cyanAccent.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                (_hasText && !isListening)
                    ? Icons.send_rounded
                    : isListening
                        ? Icons.mic
                        : isProcessing
                            ? Icons.hourglass_empty_rounded
                            : Icons.mic_none_rounded,
                color: (_hasText || isListening)
                    ? Colors.black
                    : JarvisTheme.cyanAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

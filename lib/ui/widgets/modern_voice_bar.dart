import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

class ModernVoiceBar extends StatelessWidget {
  final AssistantState state;
  final String partialTranscript;
  final VoidCallback onMicTap;
  final VoidCallback? onCancelTap;

  const ModernVoiceBar({
    super.key,
    required this.state,
    required this.partialTranscript,
    required this.onMicTap,
    this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = state == AssistantState.listening;
    final isProcessing = state == AssistantState.processing;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          // Expanded live transcript / prompt text area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 12.0),
              child: Text(
                isListening
                    ? (partialTranscript.isEmpty
                        ? "Listening... Speak naturally, Sir"
                        : partialTranscript)
                    : isProcessing
                        ? "Processing input..."
                        : "Tap microphone or say 'Hey JARVIS'",
                style: TextStyle(
                  color: isListening
                      ? JarvisTheme.textPrimary
                      : JarvisTheme.textSecondary,
                  fontSize: 13.5,
                  fontWeight:
                      isListening ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          if (isListening && onCancelTap != null)
            IconButton(
              onPressed: onCancelTap,
              icon: const Icon(Icons.close_rounded,
                  color: JarvisTheme.textMuted, size: 20),
              tooltip: 'Cancel recording',
            ),

          // Primary Voice Mic Button
          GestureDetector(
            onTap: onMicTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening
                    ? JarvisTheme.cyanAccent
                    : isProcessing
                        ? JarvisTheme.amberWarning
                        : JarvisTheme.cyanAccent.withValues(alpha: 0.15),
                border: Border.all(
                  color: isListening
                      ? Colors.white
                      : JarvisTheme.cyanAccent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: isListening
                    ? [
                        BoxShadow(
                          color: JarvisTheme.cyanAccent.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isListening
                    ? Icons.mic
                    : isProcessing
                        ? Icons.hourglass_empty_rounded
                        : Icons.mic_none_rounded,
                color: isListening ? Colors.black : JarvisTheme.cyanAccent,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

class TranscriptWidget extends StatelessWidget {
  final AssistantState state;
  final String simulatedResponse;

  const TranscriptWidget({
    super.key,
    required this.state,
    required this.simulatedResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: JarvisTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JarvisTheme.cyanAccent.withValues(alpha: 0.18),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.terminal_rounded,
                color: JarvisTheme.cyanAccent,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'TRANSCRIPT LOG',
                style: TextStyle(
                  color: JarvisTheme.cyanAccent.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMessageItem(
            sender: 'Sir',
            message: 'Jarvis, what is your current status?',
            isUser: true,
          ),
          const Divider(
            color: Color(0x1F00F0FF),
            height: 16,
            thickness: 0.8,
          ),
          _buildMessageItem(
            sender: 'JARVIS',
            message: simulatedResponse,
            isUser: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem({
    required String sender,
    required String message,
    required bool isUser,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sender.toUpperCase(),
          style: TextStyle(
            color: isUser ? JarvisTheme.textMuted : JarvisTheme.cyanAccent,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          message,
          style: TextStyle(
            color: isUser ? JarvisTheme.textSecondary : JarvisTheme.textPrimary,
            fontSize: 13,
            height: 1.35,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

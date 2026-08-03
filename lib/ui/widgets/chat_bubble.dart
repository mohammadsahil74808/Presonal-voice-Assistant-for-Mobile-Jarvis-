import 'package:flutter/material.dart';
import '../theme/jarvis_theme.dart';

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? JarvisTheme.blueAccent.withValues(alpha: 0.18)
                    : JarvisTheme.cardDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? JarvisTheme.blueAccent.withValues(alpha: 0.4)
                      : JarvisTheme.cyanAccent.withValues(alpha: 0.2),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender.toUpperCase(),
                    style: TextStyle(
                      color: isUser ? JarvisTheme.textMuted : JarvisTheme.cyanAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isUser ? JarvisTheme.textPrimary : JarvisTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: JarvisTheme.cyanAccent.withValues(alpha: 0.15),
        border: Border.all(
          color: JarvisTheme.cyanAccent.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: const Icon(
        Icons.graphic_eq_rounded,
        color: JarvisTheme.cyanAccent,
        size: 16,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: JarvisTheme.blueAccent.withValues(alpha: 0.15),
        border: Border.all(
          color: JarvisTheme.blueAccent.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: JarvisTheme.blueAccent,
        size: 18,
      ),
    );
  }
}

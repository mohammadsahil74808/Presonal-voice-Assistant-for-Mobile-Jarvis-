import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final cardColor = isUser
        ? JarvisTheme.blueAccent.withValues(alpha: 0.15)
        : JarvisTheme.cardDark.withValues(alpha: 0.85);

    final borderColor = isUser
        ? JarvisTheme.blueAccent.withValues(alpha: 0.45)
        : JarvisTheme.cyanAccent.withValues(alpha: 0.3);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildJarvisAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Message copied to clipboard, Sir.'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: JarvisTheme.cardDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: JarvisTheme.cyanAccent.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    if (!isUser)
                      BoxShadow(
                        color: JarvisTheme.cyanAccent.withValues(alpha: 0.05),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUser ? Icons.person_outline_rounded : Icons.bolt_rounded,
                          size: 12,
                          color: isUser ? JarvisTheme.textMuted : JarvisTheme.cyanAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          sender.toUpperCase(),
                          style: TextStyle(
                            color: isUser ? JarvisTheme.textMuted : JarvisTheme.cyanAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      message,
                      style: const TextStyle(
                        color: JarvisTheme.textPrimary,
                        fontSize: 13.5,
                        height: 1.45,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildJarvisAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: JarvisTheme.cyanAccent.withValues(alpha: 0.15),
        border: Border.all(
          color: JarvisTheme.cyanAccent.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: JarvisTheme.cyanAccent.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
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
          color: JarvisTheme.blueAccent.withValues(alpha: 0.5),
          width: 1.2,
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

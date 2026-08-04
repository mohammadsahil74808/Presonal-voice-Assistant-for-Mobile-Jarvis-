import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';

/// Compact, bottom-centered Siri-style translucent overlay widget for in-app or window presentation.
class JarvisOverlayWidget extends StatefulWidget {
  final AssistantState state;
  final String statusText;
  final VoidCallback? onTapOrb;
  final VoidCallback? onDismiss;

  const JarvisOverlayWidget({
    super.key,
    required this.state,
    this.statusText = '',
    this.onTapOrb,
    this.onDismiss,
  });

  @override
  State<JarvisOverlayWidget> createState() => _JarvisOverlayWidgetState();
}

class _JarvisOverlayWidgetState extends State<JarvisOverlayWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getOrbColor() {
    switch (widget.state) {
      case AssistantState.listening:
        return const Color(0xFF00E5FF); // Neon Cyan
      case AssistantState.processing:
        return const Color(0xFFFFAB00); // Amber Gold
      case AssistantState.speaking:
        return const Color(0xFF00E676); // Emerald Green
      case AssistantState.error:
        return const Color(0xFFFF5252); // Coral Red
      default:
        return const Color(0xFF00E5FF);
    }
  }

  String _getDisplayText() {
    if (widget.statusText.isNotEmpty) return widget.statusText;
    switch (widget.state) {
      case AssistantState.listening:
        return '◉ Listening...';
      case AssistantState.processing:
        return '⚡ Thinking...';
      case AssistantState.speaking:
        return '💬 Speaking...';
      case AssistantState.error:
        return '⚠️ Error';
      default:
        return 'JARVIS Active';
    }
  }

  @override
  Widget build(BuildContext meContext) {
    final orbColor = _getOrbColor();

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xEE0B0E14), // Dark translucent backdrop
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: orbColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: orbColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: widget.onTapOrb,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orbColor,
                      boxShadow: [
                        BoxShadow(
                          color: orbColor.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  _getDisplayText(),
                  style: const TextStyle(
                    color: Color(0xFFEEF4F8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.onDismiss != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white54,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

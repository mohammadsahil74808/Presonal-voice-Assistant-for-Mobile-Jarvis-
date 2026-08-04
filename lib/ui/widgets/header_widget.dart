import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

class HeaderWidget extends StatelessWidget {
  final AssistantState state;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onAssistantSetupTap;

  const HeaderWidget({
    super.key,
    required this.state,
    this.onSettingsTap,
    this.onAssistantSetupTap,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    switch (state) {
      case AssistantState.idle:
        statusText = '● READY';
        statusColor = JarvisTheme.cyanAccent;
        break;
      case AssistantState.listening:
        statusText = '● LISTENING';
        statusColor = JarvisTheme.cyanAccent;
        break;
      case AssistantState.processing:
        statusText = '● PROCESSING';
        statusColor = JarvisTheme.amberWarning;
        break;
      case AssistantState.speaking:
        statusText = '● SPEAKING';
        statusColor = JarvisTheme.blueAccent;
        break;
      case AssistantState.error:
        statusText = '● OFFLINE / ERROR';
        statusColor = JarvisTheme.redError;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.8),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'JARVIS',
                style: TextStyle(
                  color: JarvisTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              if (onAssistantSetupTap != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onAssistantSetupTap,
                  icon: const Icon(
                    Icons.assistant_outlined,
                    color: JarvisTheme.cyanAccent,
                    size: 22,
                  ),
                  tooltip: 'System Assistant Setup',
                ),
              ],
              if (onSettingsTap != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onSettingsTap,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: JarvisTheme.textSecondary,
                    size: 20,
                  ),
                  tooltip: 'API Key Settings',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

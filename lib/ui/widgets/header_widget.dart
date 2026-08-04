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
        statusText = 'READY';
        statusColor = JarvisTheme.cyanAccent;
        break;
      case AssistantState.listening:
        statusText = 'LISTENING';
        statusColor = JarvisTheme.cyanAccent;
        break;
      case AssistantState.processing:
        statusText = 'PROCESSING';
        statusColor = JarvisTheme.amberWarning;
        break;
      case AssistantState.speaking:
        statusText = 'SPEAKING';
        statusColor = JarvisTheme.blueAccent;
        break;
      case AssistantState.error:
        statusText = 'OFFLINE';
        statusColor = JarvisTheme.redError;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: JarvisTheme.cardDark.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: JarvisTheme.cyanAccent.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Brand & Telemetry Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
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
                  const SizedBox(width: 8),
                  const Text(
                    'JARVIS',
                    style: TextStyle(
                      color: JarvisTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const SizedBox(width: 15),
                  Text(
                    'OS v2.5  |  TELEMETRY ONLINE',
                    style: TextStyle(
                      color: JarvisTheme.textMuted.withValues(alpha: 0.8),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right Side: Status Badge & Action Controls
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '● $statusText',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (onAssistantSetupTap != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onAssistantSetupTap,
                  icon: const Icon(
                    Icons.assistant_outlined,
                    color: JarvisTheme.cyanAccent,
                    size: 20,
                  ),
                  tooltip: 'System Assistant Setup',
                ),
              ],
              if (onSettingsTap != null) ...[
                const SizedBox(width: 2),
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

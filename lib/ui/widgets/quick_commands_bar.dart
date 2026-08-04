import 'package:flutter/material.dart';
import '../theme/jarvis_theme.dart';

class QuickCommandsBar extends StatelessWidget {
  final Function(String command) onCommandSelected;
  final VoidCallback? onToggleMiniOverlay;
  final bool isOverlayActive;

  const QuickCommandsBar({
    super.key,
    required this.onCommandSelected,
    this.onToggleMiniOverlay,
    this.isOverlayActive = false,
  });

  static const List<_QuickCommandItem> _commands = [
    _QuickCommandItem(
      label: 'System Status',
      icon: Icons.monitor_heart_outlined,
      prompt: 'Check system status and phone diagnostics',
    ),
    _QuickCommandItem(
      label: 'Open Settings',
      icon: Icons.settings_applications_outlined,
      prompt: 'Open device settings',
    ),
    _QuickCommandItem(
      label: 'Battery & Storage',
      icon: Icons.battery_charging_full_rounded,
      prompt: 'Show battery and storage health',
    ),
    _QuickCommandItem(
      label: 'Quick Briefing',
      icon: Icons.bolt_rounded,
      prompt: 'Give me a quick briefing, Sir',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          if (onToggleMiniOverlay != null) ...[
            InkWell(
              onTap: onToggleMiniOverlay,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverlayActive
                      ? JarvisTheme.cyanAccent.withValues(alpha: 0.25)
                      : JarvisTheme.cardDark.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOverlayActive
                        ? JarvisTheme.cyanAccent
                        : JarvisTheme.cyanAccent.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      color: JarvisTheme.cyanAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOverlayActive ? 'Hide Mini HUD' : 'Mini Siri HUD',
                      style: const TextStyle(
                        color: JarvisTheme.cyanAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ..._commands.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => onCommandSelected(item.prompt),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: JarvisTheme.cardDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: JarvisTheme.cyanAccent.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: JarvisTheme.cyanAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: JarvisTheme.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuickCommandItem {
  final String label;
  final IconData icon;
  final String prompt;

  const _QuickCommandItem({
    required this.label,
    required this.icon,
    required this.prompt,
  });
}

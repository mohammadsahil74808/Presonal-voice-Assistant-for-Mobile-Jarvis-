import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

/// Transparent Agent Reasoning Activity Card (shows human-readable AI activity flow)
class AgentActivityCard extends StatefulWidget {
  final AssistantState state;
  final String? activeAction;

  const AgentActivityCard({
    super.key,
    required this.state,
    this.activeAction,
  });

  @override
  State<AgentActivityCard> createState() => _AgentActivityCardState();
}

class _AgentActivityCardState extends State<AgentActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state != AssistantState.processing) {
      return const SizedBox.shrink();
    }

    final displayAction = widget.activeAction ?? 'Processing intent & synthesizing response...';

    return AnimatedBuilder(
      animation: _sweepController,
      builder: (context, child) {
        final sweepVal = _sweepController.value;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: JarvisTheme.cardDark.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: JarvisTheme.amberWarning.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: JarvisTheme.amberWarning.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: JarvisTheme.amberWarning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      color: JarvisTheme.amberWarning,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'JARVIS AGENT REASONING',
                    style: TextStyle(
                      color: JarvisTheme.amberWarning,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: JarvisTheme.amberWarning,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: JarvisTheme.amberWarning.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                displayAction,
                style: const TextStyle(
                  color: JarvisTheme.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              // Linear Sweeping Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 3,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(
                        color: JarvisTheme.textMuted.withValues(alpha: 0.2),
                      ),
                      Positioned(
                        left: (MediaQuery.of(context).size.width * sweepVal) - 80,
                        width: 80,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                JarvisTheme.amberWarning,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

class StatusTextWidget extends StatelessWidget {
  final AssistantState state;

  const StatusTextWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtext;
    Color titleColor;

    switch (state) {
      case AssistantState.idle:
        title = 'JARVIS READY';
        subtext = 'Tap the microphone to speak';
        titleColor = JarvisTheme.textPrimary;
        break;
      case AssistantState.listening:
        title = 'LISTENING';
        subtext = "I'm listening, Sir.";
        titleColor = JarvisTheme.cyanAccent;
        break;
      case AssistantState.processing:
        title = 'PROCESSING';
        subtext = 'Thinking...';
        titleColor = JarvisTheme.amberWarning;
        break;
      case AssistantState.speaking:
        title = 'SPEAKING';
        subtext = 'JARVIS is responding';
        titleColor = JarvisTheme.cyanAccent;
        break;
      case AssistantState.error:
        title = 'SYSTEM ERROR';
        subtext = 'An unexpected system fault occurred.';
        titleColor = JarvisTheme.redError;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            title,
            key: ValueKey<String>(title),
            style: TextStyle(
              color: titleColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            subtext,
            key: ValueKey<String>(subtext),
            style: const TextStyle(
              color: JarvisTheme.textSecondary,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

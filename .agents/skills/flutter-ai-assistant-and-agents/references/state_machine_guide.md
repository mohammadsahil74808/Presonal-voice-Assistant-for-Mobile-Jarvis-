# AI Agent State Machine & Reactive Orchestration Guide

This document outlines the state machine design patterns, state transition matrix, and reactive event architecture for Flutter AI Agent Mobile Applications.

---

## 🔁 1. Complete State Transition Matrix

| From State | Trigger / Event | Target State | Visual & Haptic Transition |
| :--- | :--- | :--- | :--- |
| `IDLE` | User taps Mic or Wake Word | `LISTENING` | Dynamic scale-up of soundwave core, soft haptic click. |
| `IDLE` | User submits Text / Image | `THINKING` | Smooth radial rotation on central visual core. |
| `LISTENING` | Silence threshold reached | `THINKING` | Waveform condenses into rotating computational geometric nodes. |
| `LISTENING` | User taps Cancel / Swipes down | `IDLE` | Quick scale-down fade, dampened spring curve. |
| `THINKING` | Intent parsed, needs execution plan | `PROCESSING` | Morphing particle mesh or smooth status sweep bar. |
| `PROCESSING` | External tool required | `USING_TOOL` | Tool badge slides into focused execution container. |
| `PROCESSING` | Sensitive action required | `WAITING_FOR_USER` | Permission / Input modal pops with subtle bouncing glow (`Curves.elasticOut`). |
| `USING_TOOL` | Sensitive action required | `WAITING_FOR_USER` | Target action card highlights required permission. |
| `USING_TOOL` | Tool execution complete | `EXECUTING` / `PROCESSING` | Checkmark pulse on tool card, transition to next plan step. |
| `WAITING_FOR_USER` | User grants permission | `EXECUTING` | Green checkmark feedback, immediate resume of execution plan. |
| `WAITING_FOR_USER` | User denies / cancels | `INTERRUPTED` / `IDLE` | Warning border pulse, graceful step cancellation report. |
| `PROCESSING` / `EXECUTING` | Direct response ready | `SPEAKING` / `COMPLETED` | Voice wave canvas activates in sync with TTS audio stream. |
| `SPEAKING` | User taps screen / speaks over | `INTERRUPTED` | Instant audio stream pause, state switches to `LISTENING` or `IDLE`. |
| Any State | Exception / Network drop | `ERROR` | Coral border glow, error details card with clear retry button. |
| Any State | Offline detected | `OFFLINE` | Mode indicator badge updates to "Local Model Only". |

---

## 🏗️ 2. Dart State Machine Implementation Pattern

```dart
enum AiAgentState {
  idle,
  listening,
  thinking,
  processing,
  executing,
  usingTool,
  waitingForUser,
  speaking,
  completed,
  error,
  interrupted,
  offline,
}

class AiStatePayload {
  final AiAgentState state;
  final String statusText;
  final double audioAmplitude;
  final String? activeToolName;
  final double executionProgress;
  final String? errorMessage;

  const AiStatePayload({
    required this.state,
    this.statusText = 'Ready',
    this.audioAmplitude = 0.0,
    this.activeToolName,
    this.executionProgress = 0.0,
    this.errorMessage,
  });

  AiStatePayload copyWith({
    AiAgentState? state,
    String? statusText,
    double? audioAmplitude,
    String? activeToolName,
    double? executionProgress,
    String? errorMessage,
  }) {
    return AiStatePayload(
      state: state ?? this.state,
      statusText: statusText ?? this.statusText,
      audioAmplitude: audioAmplitude ?? this.audioAmplitude,
      activeToolName: activeToolName ?? this.activeToolName,
      executionProgress: executionProgress ?? this.executionProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

---

## ⚡ 3. Reactive State Listener & Non-Blocking Updates

Wrap state listeners in custom reactive widgets (`ValueListenableBuilder` or `StreamBuilder`) so that state changes only rebuild necessary UI subtrees:

```dart
class AiStatusHeader extends StatelessWidget {
  final ValueNotifier<AiStatePayload> stateNotifier;

  const AiStatusHeader({super.key, required this.stateNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AiStatePayload>(
      valueListenable: stateNotifier,
      builder: (context, payload, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          child: Container(
            key: ValueKey(payload.state),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStateColor(payload.state).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStateColor(payload.state).withOpacity(0.4),
                width: 1.2,
              ),
            ),
            child: Text(
              payload.statusText.toUpperCase(),
              style: TextStyle(
                color: _getStateColor(payload.state),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStateColor(AiAgentState state) {
    switch (state) {
      case AiAgentState.listening: return const Color(0xFF00E5FF);
      case AiAgentState.thinking: return const Color(0xFF7C4DFF);
      case AiAgentState.usingTool: return const Color(0xFFFFAB00);
      case AiAgentState.speaking: return const Color(0xFF00E676);
      case AiAgentState.error: return const Color(0xFFFF5252);
      default: return const Color(0xFF90A4AE);
    }
  }
}
```

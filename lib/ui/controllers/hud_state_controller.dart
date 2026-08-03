import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/enums/assistant_state.dart';

/// State Controller for JARVIS HUD.
/// Manages current [AssistantState] and provides simulated voice-flow transitions for Phase 2.
class HudStateController extends ValueNotifier<AssistantState> {
  Timer? _simulationTimer;
  String _simulatedResponse = 'I am initialized and standing by, Sir.';

  HudStateController() : super(AssistantState.idle);

  String get simulatedResponse => _simulatedResponse;

  /// Simulates voice assistant flow for Phase 2 UI demonstration.
  void toggleMicSimulation() {
    if (value == AssistantState.idle) {
      startSimulationFlow();
    } else {
      resetToIdle();
    }
  }

  void startSimulationFlow() {
    _simulationTimer?.cancel();
    value = AssistantState.listening;

    _simulationTimer = Timer(const Duration(seconds: 2), () {
      if (value == AssistantState.listening) {
        value = AssistantState.processing;

        _simulationTimer = Timer(const Duration(seconds: 2), () {
          if (value == AssistantState.processing) {
            value = AssistantState.speaking;
            _simulatedResponse =
                'Sir, main current system status check kar raha hoon. Everything is operational.';

            _simulationTimer = Timer(const Duration(seconds: 3), () {
              if (value == AssistantState.speaking) {
                value = AssistantState.idle;
              }
            });
          }
        });
      }
    });
  }

  void triggerErrorState([String? errorMessage]) {
    _simulationTimer?.cancel();
    value = AssistantState.error;
    if (errorMessage != null) {
      _simulatedResponse = errorMessage;
    }
  }

  void resetToIdle() {
    _simulationTimer?.cancel();
    value = AssistantState.idle;
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

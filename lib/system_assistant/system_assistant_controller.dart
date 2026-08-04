import '../core/enums/assistant_state.dart';
import '../voice/voice_manager.dart';
import 'system_assistant_service.dart';

/// Bridges VoiceManager AssistantState transitions to SystemAssistantService floating overlay window.
class SystemAssistantController {
  final VoiceManager voiceManager;
  final SystemAssistantService systemService;

  SystemAssistantController({
    required this.voiceManager,
    required this.systemService,
  }) {
    _initListener();
  }

  void _initListener() {
    voiceManager.addListener(_onVoiceStateChanged);
  }

  void _onVoiceStateChanged() {
    final state = voiceManager.state;

    if (systemService.isOverlayVisible) {
      if (state == AssistantState.speaking) {
        final preview = voiceManager.partialTranscript.isNotEmpty
            ? voiceManager.partialTranscript
            : 'Jarvis Speaking...';
        systemService.updateOverlayState('speaking', previewText: preview);
      } else if (state == AssistantState.processing) {
        systemService.updateOverlayState('processing');
      } else if (state == AssistantState.listening) {
        systemService.updateOverlayState('listening');
      } else if (state == AssistantState.idle) {
        // Auto-dismiss overlay when conversation returns to idle
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (voiceManager.state == AssistantState.idle) {
            systemService.hideOverlay();
          }
        });
      } else if (state == AssistantState.error) {
        systemService.updateOverlayState('error', previewText: voiceManager.errorMessage);
      }
    }
  }

  void dispose() {
    voiceManager.removeListener(_onVoiceStateChanged);
  }
}

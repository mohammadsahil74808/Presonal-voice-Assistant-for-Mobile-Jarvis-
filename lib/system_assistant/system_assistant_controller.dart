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
    systemService.setTriggerCallback(() {
      systemService.showOverlay(initialState: 'listening', preview: '◉ Listening... Speak, Sir');
      voiceManager.startListening();
    });
  }

  void _onVoiceStateChanged() {
    final state = voiceManager.state;
    final currentAmp = voiceManager.currentAmplitude;

    if (systemService.isOverlayVisible) {
      systemService.updateAudioAmplitude(currentAmp);

      if (state == AssistantState.speaking) {
        String preview = '💬 Speaking...';
        if (voiceManager.conversationHistory.isNotEmpty) {
          final lastEntry = voiceManager.conversationHistory.last;
          if (lastEntry['role'] == 'assistant') {
            preview = lastEntry['content'] ?? '💬 Speaking...';
          }
        }
        systemService.updateOverlayState('speaking', previewText: preview);
      } else if (state == AssistantState.processing) {
        systemService.updateOverlayState('processing');
      } else if (state == AssistantState.listening) {
        systemService.updateOverlayState('listening', previewText: voiceManager.partialTranscript);
      } else if (state == AssistantState.idle) {
        // Auto-dismiss overlay when conversation returns to idle
        Future.delayed(const Duration(milliseconds: 1800), () {
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

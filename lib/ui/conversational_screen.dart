import 'package:flutter/material.dart';
import '../config/secure_storage_service.dart';
import '../core/enums/assistant_state.dart';
import '../voice/voice_manager.dart';
import 'theme/jarvis_theme.dart';
import 'widgets/ai_core_orb.dart';
import 'widgets/api_key_dialog.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/header_widget.dart';
import 'widgets/modern_voice_bar.dart';

import '../services/service_locator.dart';
import 'widgets/overlay_permission_dialog.dart';

class ConversationalScreen extends StatefulWidget {
  const ConversationalScreen({super.key});

  @override
  State<ConversationalScreen> createState() => _ConversationalScreenState();
}

class _ConversationalScreenState extends State<ConversationalScreen> {
  late final VoiceManager _voiceManager;
  final ScrollController _scrollController = ScrollController();
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _voiceManager = VoiceManager()..addListener(_onVoiceStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showAssistantSetupDialog();
    });
  }

  void _showAssistantSetupDialog() {
    final systemService = ServiceLocator.instance.systemAssistantService;
    showDialog(
      context: context,
      builder: (context) => OverlayPermissionDialog(
        onOpenSettings: () => systemService.requestOverlayPermission(),
      ),
    );
  }

  void _onVoiceStateChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showApiKeyDialog() async {
    final currentKey = await _secureStorage.getGeminiApiKey();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return ApiKeyDialog(
          initialKey: currentKey,
          onSave: (key) async {
            await _voiceManager.setApiKey(key);
          },
          onClear: currentKey != null
              ? () async {
                  await _voiceManager.clearApiKey();
                }
              : null,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _voiceManager.removeListener(_onVoiceStateChanged);
    _voiceManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _voiceManager,
      builder: (context, child) {
        final state = _voiceManager.state;
        final partialTranscript = _voiceManager.partialTranscript;
        final history = _voiceManager.conversationHistory;

        return Scaffold(
          backgroundColor: JarvisTheme.bgDark,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Section with Settings Button
                HeaderWidget(
                  state: state,
                  onSettingsTap: _showApiKeyDialog,
                  onAssistantSetupTap: _showAssistantSetupDialog,
                ),

                // Subtle Ambient AI Orb Header Core
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: AICoreOrb(
                    state: state,
                    size: 100,
                  ),
                ),

                // Missing API Key Notification Banner
                if (!_voiceManager.hasApiKey)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: JarvisTheme.amberWarning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: JarvisTheme.amberWarning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.key_outlined,
                            color: JarvisTheme.amberWarning, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Gemini API key is required. Tap settings to configure your key, Sir.',
                            style: TextStyle(
                              color: JarvisTheme.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _showApiKeyDialog,
                          child: const Text(
                            'SET KEY',
                            style: TextStyle(
                              color: JarvisTheme.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // System Error Notification Banner
                if (state == AssistantState.error &&
                    _voiceManager.errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: JarvisTheme.redError.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: JarvisTheme.redError.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: JarvisTheme.redError, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _voiceManager.errorMessage,
                            style: const TextStyle(
                              color: JarvisTheme.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_voiceManager.errorMessage.toLowerCase().contains('permission')) {
                              _voiceManager.openAppSettings();
                            } else {
                              _voiceManager.clearError();
                            }
                          },
                          child: Text(
                            _voiceManager.errorMessage.toLowerCase().contains('permission')
                                ? 'PERMISSIONS'
                                : 'DISMISS',
                            style: const TextStyle(
                              color: JarvisTheme.cyanAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Conversation Scroll Area
                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.graphic_eq_rounded,
                                color: JarvisTheme.textMuted,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Good day, Sir. I am JARVIS.\nTap the microphone or say 'Hey JARVIS' to speak.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: JarvisTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            final isUser = item['role'] == 'user';
                            return ChatBubble(
                              sender: isUser ? 'Sir' : 'JARVIS',
                              message: item['content'] ?? '',
                              isUser: isUser,
                            );
                          },
                        ),
                ),

                // Bottom Modern Voice Interaction Bar
                ModernVoiceBar(
                  state: state,
                  partialTranscript: partialTranscript,
                  onMicTap: () {
                    if (!_voiceManager.hasApiKey) {
                      _showApiKeyDialog();
                    } else {
                      _voiceManager.toggleListening();
                    }
                  },
                  onCancelTap: () {
                    _voiceManager.cancelListening();
                  },
                  onSendText: (text) {
                    if (!_voiceManager.hasApiKey) {
                      _showApiKeyDialog();
                    } else {
                      _voiceManager.sendTextMessage(text);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

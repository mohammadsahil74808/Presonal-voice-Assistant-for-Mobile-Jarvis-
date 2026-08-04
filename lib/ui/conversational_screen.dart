import 'package:flutter/material.dart';
import '../config/secure_storage_service.dart';
import '../core/enums/assistant_state.dart';
import '../services/service_locator.dart';
import '../voice/voice_manager.dart';
import 'theme/jarvis_theme.dart';
import 'widgets/agent_activity_card.dart';
import 'widgets/ai_core_orb.dart';
import 'widgets/api_key_dialog.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/header_widget.dart';
import 'widgets/jarvis_overlay_widget.dart';
import 'widgets/modern_voice_bar.dart';
import 'widgets/overlay_permission_dialog.dart';
import 'widgets/quick_commands_bar.dart';

enum JarvisViewMode { hud, canvas }

class ConversationalScreen extends StatefulWidget {
  const ConversationalScreen({super.key});

  @override
  State<ConversationalScreen> createState() => _ConversationalScreenState();
}

class _ConversationalScreenState extends State<ConversationalScreen> {
  late final VoiceManager _voiceManager;
  final ScrollController _scrollController = ScrollController();
  final SecureStorageService _secureStorage = SecureStorageService();
  JarvisViewMode _currentViewMode = JarvisViewMode.hud;
  bool _showMiniJarvisOverlay = false;

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

  void _handleQuickCommand(String command) {
    if (!_voiceManager.hasApiKey) {
      _showApiKeyDialog();
    } else {
      _voiceManager.sendTextMessage(command);
    }
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
            child: Stack(
              children: [
                // Ambient Radial Background Glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.3),
                        radius: 1.2,
                        colors: [
                          JarvisTheme.cyanAccent.withValues(alpha: 0.05),
                          JarvisTheme.bgDark,
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Top Telemetry Header Section
                    HeaderWidget(
                      state: state,
                      onSettingsTap: _showApiKeyDialog,
                      onAssistantSetupTap: _showAssistantSetupDialog,
                    ),

                    // Futuristic Mode Switcher Bar (HUD vs Canvas)
                    _buildModeSwitcher(),

                    // Missing API Key Notification Banner
                    if (!_voiceManager.hasApiKey) _buildApiKeyBanner(),

                    // System Error Notification Banner
                    if (state == AssistantState.error &&
                        _voiceManager.errorMessage.isNotEmpty)
                      _buildErrorBanner(),

                    // Active Agent Reasoning Step Card
                    AgentActivityCard(
                      state: state,
                      activeAction: _voiceManager.partialTranscript.isNotEmpty
                          ? 'Listening: "${_voiceManager.partialTranscript}"'
                          : null,
                    ),

                    // Main Interactive Content Area (HUD vs Conversational Canvas)
                    Expanded(
                      child: _currentViewMode == JarvisViewMode.hud
                          ? _buildHudView(state)
                          : _buildCanvasView(history),
                    ),

                    // Quick Command Chips Bar
                    QuickCommandsBar(
                      onCommandSelected: _handleQuickCommand,
                      isOverlayActive: _showMiniJarvisOverlay,
                      onToggleMiniOverlay: () {
                        setState(() {
                          _showMiniJarvisOverlay = !_showMiniJarvisOverlay;
                        });
                      },
                    ),

                    // Bottom Floating Multimodal Voice Bar
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

                // Siri-Style Mini JARVIS Voice Overlay Layer (Reacts to voice volume)
                if (_showMiniJarvisOverlay || state == AssistantState.listening)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 70,
                    child: JarvisOverlayWidget(
                      state: state,
                      audioAmplitude: _voiceManager.currentAmplitude,
                      statusText: partialTranscript,
                      onTapOrb: () {
                        if (!_voiceManager.hasApiKey) {
                          _showApiKeyDialog();
                        } else {
                          _voiceManager.toggleListening();
                        }
                      },
                      onDismiss: () {
                        setState(() {
                          _showMiniJarvisOverlay = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: JarvisTheme.cardDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: JarvisTheme.cyanAccent.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              mode: JarvisViewMode.hud,
              label: '⚡ COMMAND HUD',
              icon: Icons.hub_outlined,
            ),
          ),
          Expanded(
            child: _buildModeTab(
              mode: JarvisViewMode.canvas,
              label: '💬 CONVERSATION',
              icon: Icons.chat_bubble_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required JarvisViewMode mode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentViewMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentViewMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? JarvisTheme.cyanAccent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color: JarvisTheme.cyanAccent.withValues(alpha: 0.5),
                  width: 1.0,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? JarvisTheme.cyanAccent
                  : JarvisTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? JarvisTheme.cyanAccent
                    : JarvisTheme.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudView(AssistantState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final orbSize = (availableHeight * 0.45).clamp(180.0, 250.0);

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // 3D Perspective Matrix Visualizer Core Orb
                AICoreOrb(
                  state: state,
                  size: orbSize,
                  audioAmplitude: _voiceManager.currentAmplitude,
                ),
                const SizedBox(height: 24),
                // Live Status Info Text
                Text(
                  _getStateDescription(state),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: JarvisTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Tap the microphone or say 'Hey JARVIS'",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: JarvisTheme.textMuted.withValues(alpha: 0.8),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStateDescription(AssistantState state) {
    switch (state) {
      case AssistantState.idle:
        return 'SYSTEM ONLINE • READY';
      case AssistantState.listening:
        return 'CAPTURING AUDIO INPUT...';
      case AssistantState.processing:
        return 'REASONING & EXECUTING TASK...';
      case AssistantState.speaking:
        return 'JARVIS SYNTHESIZING VOICE...';
      case AssistantState.error:
        return 'SYSTEM OFFLINE / ATTENTION REQUIRED';
    }
  }

  Widget _buildCanvasView(List<Map<String, String>> history) {
    if (history.isEmpty) {
      return Center(
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
              "Good day, Sir. I am JARVIS.\nTap the microphone or type a command.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: JarvisTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
    );
  }

  Widget _buildApiKeyBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              'Gemini API key required, Sir.',
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
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              if (_voiceManager.errorMessage
                  .toLowerCase()
                  .contains('permission')) {
                _voiceManager.openAppSettings();
              } else {
                _voiceManager.clearError();
              }
            },
            child: Text(
              _voiceManager.errorMessage
                      .toLowerCase()
                      .contains('permission')
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
    );
  }
}

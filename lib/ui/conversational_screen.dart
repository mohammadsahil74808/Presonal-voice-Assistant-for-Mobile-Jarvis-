import 'package:flutter/material.dart';
import '../core/enums/assistant_state.dart';
import '../voice/voice_manager.dart';
import 'theme/jarvis_theme.dart';
import 'widgets/ai_core_orb.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/header_widget.dart';
import 'widgets/modern_voice_bar.dart';

class ConversationalScreen extends StatefulWidget {
  const ConversationalScreen({super.key});

  @override
  State<ConversationalScreen> createState() => _ConversationalScreenState();
}

class _ConversationalScreenState extends State<ConversationalScreen> {
  late final VoiceManager _voiceManager;
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'JARVIS',
      'message': 'Good day, Sir. I am online and listening. How may I assist you today?',
      'isUser': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _voiceManager = VoiceManager()..addListener(_onVoiceStateChanged);
  }

  void _onVoiceStateChanged() {
    if (_voiceManager.lastUserMessage.isNotEmpty &&
        (_messages.isEmpty ||
            _messages.last['message'] != _voiceManager.lastUserMessage)) {
      setState(() {
        _messages.add({
          'sender': 'Sir',
          'message': _voiceManager.lastUserMessage,
          'isUser': true,
        });

        // Demo response for Phase 3 before Gemini integration in Phase 4
        _messages.add({
          'sender': 'JARVIS',
          'message':
              'Sir, transcript received: "${_voiceManager.lastUserMessage}". Voice input pipeline is operational. Ready for Phase 4 AI engine.',
          'isUser': false,
        });
      });
    }
  }

  @override
  void dispose() {
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

        return Scaffold(
          backgroundColor: JarvisTheme.bgDark,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Section
                HeaderWidget(state: state),

                // Subtle Ambient AI Orb Header Core
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AICoreOrb(
                    state: state,
                    size: 110,
                  ),
                ),

                // Permission or System Error Notification Banner if active
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
                            _voiceManager.openAppSettings();
                          },
                          child: const Text(
                            'SETTINGS',
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

                // Main Conversation Scroll Area
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final item = _messages[index];
                      return ChatBubble(
                        sender: item['sender'],
                        message: item['message'],
                        isUser: item['isUser'],
                      );
                    },
                  ),
                ),

                // Bottom Modern Voice Interaction Bar
                ModernVoiceBar(
                  state: state,
                  partialTranscript: partialTranscript,
                  onMicTap: () {
                    _voiceManager.toggleListening();
                  },
                  onCancelTap: () {
                    _voiceManager.cancelListening();
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

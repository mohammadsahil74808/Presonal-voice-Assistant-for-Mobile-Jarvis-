import 'package:flutter/material.dart';
import '../core/enums/assistant_state.dart';
import 'controllers/hud_state_controller.dart';
import 'theme/jarvis_theme.dart';
import 'widgets/ai_core_orb.dart';
import 'widgets/header_widget.dart';
import 'widgets/mic_button.dart';
import 'widgets/status_text_widget.dart';
import 'widgets/transcript_widget.dart';

class HudScreen extends StatefulWidget {
  const HudScreen({super.key});

  @override
  State<HudScreen> createState() => _HudScreenState();
}

class _HudScreenState extends State<HudScreen> {
  late final HudStateController _hudController;

  @override
  void initState() {
    super.initState();
    _hudController = HudStateController();
  }

  @override
  void dispose() {
    _hudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisTheme.bgDark,
      body: SafeArea(
        child: ValueListenableBuilder<AssistantState>(
          valueListenable: _hudController,
          builder: (context, state, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final orbSize = (screenHeight * 0.28).clamp(160.0, 260.0);

                return Column(
                  children: [
                    // Top Header Section
                    HeaderWidget(state: state),

                    const Spacer(),

                    // Central AI Core Orb
                    Center(
                      child: AICoreOrb(
                        state: state,
                        size: orbSize,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status Text Display
                    StatusTextWidget(state: state),

                    const Spacer(),

                    // Transcript Conversation Log
                    TranscriptWidget(
                      state: state,
                      simulatedResponse: _hudController.simulatedResponse,
                    ),

                    const SizedBox(height: 12),

                    // Microphone Action Control
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: MicButton(
                        state: state,
                        onTap: _hudController.toggleMicSimulation,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

/// Siri-Style Mini JARVIS Floating Voice Overlay HUD.
/// Pops up at the bottom of the screen and dynamically reacts to voice volume (audioAmplitude).
class JarvisOverlayWidget extends StatefulWidget {
  final AssistantState state;
  final String statusText;
  final double audioAmplitude;
  final VoidCallback? onTapOrb;
  final VoidCallback? onDismiss;
  final VoidCallback? onTapResponse;

  const JarvisOverlayWidget({
    super.key,
    required this.state,
    this.statusText = '',
    this.audioAmplitude = 0.0,
    this.onTapOrb,
    this.onDismiss,
    this.onTapResponse,
  });

  @override
  State<JarvisOverlayWidget> createState() => _JarvisOverlayWidgetState();
}

class _JarvisOverlayWidgetState extends State<JarvisOverlayWidget> with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late AnimationController _pulseController;
  late AnimationController _wavePhaseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Fast 260ms spring entrance
    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearanceController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _wavePhaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _pulseController.dispose();
    _wavePhaseController.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _appearanceController.reverse();
    widget.onDismiss?.call();
  }

  Color _getPrimaryColor() {
    switch (widget.state) {
      case AssistantState.listening:
        return JarvisTheme.cyanAccent;
      case AssistantState.processing:
        return JarvisTheme.amberWarning;
      case AssistantState.speaking:
        return JarvisTheme.blueAccent;
      case AssistantState.error:
        return JarvisTheme.redError;
      default:
        return JarvisTheme.cyanAccent;
    }
  }

  String _getDisplayText() {
    if (widget.statusText.isNotEmpty) return widget.statusText;
    switch (widget.state) {
      case AssistantState.listening:
        return '◉ JARVIS Listening... Speak, Sir';
      case AssistantState.processing:
        return '⚡ Reasoning intent...';
      case AssistantState.speaking:
        return '💬 Synthesizing response...';
      case AssistantState.error:
        return '⚠️ System error or attention required';
      default:
        return 'JARVIS Ready, Sir';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final isAudioActive = widget.state == AssistantState.listening || widget.state == AssistantState.speaking;
    final double extraScale = isAudioActive ? (widget.audioAmplitude * 0.35) : 0.0;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  constraints: const BoxConstraints(minHeight: 68, maxWidth: 400),
                  decoration: BoxDecoration(
                    color: const Color(0xEE070A12), // Glassmorphic Siri Dark Capsule
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: (0.45 + (widget.audioAmplitude * 0.45)).clamp(0.2, 0.95)),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3 + (widget.audioAmplitude * 0.3)),
                        blurRadius: 30 + (widget.audioAmplitude * 18),
                        spreadRadius: 4 + (widget.audioAmplitude * 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Animated Voice-Reactive Pulsing Orb
                      GestureDetector(
                        onTap: widget.onTapOrb,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_pulseController, _wavePhaseController]),
                          builder: (context, child) {
                            final phase = _wavePhaseController.value * 2 * math.pi;

                            return Transform.scale(
                              scale: 1.0 + extraScale,
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Ambient Halo Glow
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor.withValues(alpha: 0.25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha: 0.8),
                                            blurRadius: 16 + (widget.audioAmplitude * 12),
                                            spreadRadius: 4 + (widget.audioAmplitude * 6),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Mini Acoustic Wave Ring
                                    if (isAudioActive)
                                      CustomPaint(
                                        size: const Size(38, 38),
                                        painter: _MiniWaveRingPainter(
                                          color: primaryColor,
                                          amplitude: widget.audioAmplitude,
                                          phase: phase,
                                        ),
                                      ),
                                    // Central White Core Pulse
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text Preview Response
                      Flexible(
                        child: GestureDetector(
                          onTap: widget.onTapResponse,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'MINI JARVIS HUD',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDisplayText(),
                                style: const TextStyle(
                                  color: Color(0xFFEEF4F8),
                                  fontSize: 13.5,
                                  height: 1.3,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Multi-Bar Voice Audio Spectrum (Visually reacts to audio volume)
                      if (isAudioActive) ...[
                        const SizedBox(width: 10),
                        CustomPaint(
                          size: const Size(28, 22),
                          painter: _MultiBarAudioSpectrumPainter(
                            color: primaryColor,
                            amplitude: widget.audioAmplitude,
                          ),
                        ),
                      ],

                      // Close Button
                      if (widget.onDismiss != null) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _handleDismiss,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniWaveRingPainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double phase;

  _MiniWaveRingPainter({
    required this.color,
    required this.amplitude,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 + (amplitude * 2.0);

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 4.0;

    final path = Path();
    const int points = 30;
    for (int i = 0; i <= points; i++) {
      final double angle = (i * 2 * math.pi) / points;
      final double waveOffset = math.sin((angle * 5) + phase) * (2.0 + (amplitude * 6.0));
      final double r = baseRadius + waveOffset;

      final double x = center.dx + math.cos(angle) * r;
      final double y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniWaveRingPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude || oldDelegate.phase != phase || oldDelegate.color != color;
  }
}

class _MultiBarAudioSpectrumPainter extends CustomPainter {
  final Color color;
  final double amplitude;

  _MultiBarAudioSpectrumPainter({
    required this.color,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const int barCount = 5;
    final double barWidth = (size.width - (barCount - 1) * 2.5) / barCount;

    // Dynamic bar height multiplier based on voice input amplitude
    final heights = [
      (size.height * 0.25) + (amplitude * size.height * 0.70),
      (size.height * 0.60) + (amplitude * size.height * 0.40),
      (size.height * 0.35) + (amplitude * size.height * 0.65),
      (size.height * 0.80) + (amplitude * size.height * 0.20),
      (size.height * 0.45) + (amplitude * size.height * 0.55),
    ];

    for (int i = 0; i < barCount; i++) {
      final double left = i * (barWidth + 2.5);
      final double h = heights[i].clamp(3.0, size.height);
      final double top = (size.height - h) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiBarAudioSpectrumPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.amplitude != amplitude;
  }
}

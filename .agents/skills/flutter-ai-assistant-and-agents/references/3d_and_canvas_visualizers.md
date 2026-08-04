# High-Performance 3D Core & Soundwave Canvas Guide

This reference document provides implementation patterns for 60 FPS vector canvases, audio-reactive soundwave visualizers, and state-driven 3D core rendering in Flutter AI Applications.

---

## 🌊 1. Dynamic Harmonic Soundwave Painter (`CustomPainter`)

Use this pattern to render real-time soundwave visualizations during `LISTENING` and `SPEAKING` states:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HarmonicSoundwavePainter extends CustomPainter {
  final double amplitude; // Normalized 0.0 to 1.0
  final double phase;     // Driven by AnimationController (0.0 to 2*pi)
  final Color primaryColor;
  final Color secondaryColor;

  HarmonicSoundwavePainter({
    required this.amplitude,
    required this.phase,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final width = size.width;

    // Primary Harmonic Wave
    final path1 = Path();
    path1.moveTo(0, centerY);

    for (double x = 0; x <= width; x += 2) {
      final normalizedX = x / width;
      // Envelope to dampen wave edges at boundaries
      final envelope = math.sin(normalizedX * math.pi);
      final y = centerY +
          math.sin((normalizedX * 4 * math.pi) + phase) *
              (amplitude * 40 * envelope);
      path1.lineTo(x, y);
    }

    final paint1 = Paint()
      ..color = primaryColor.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Secondary Shifted Wave
    final path2 = Path();
    path2.moveTo(0, centerY);

    for (double x = 0; x <= width; x += 2) {
      final normalizedX = x / width;
      final envelope = math.sin(normalizedX * math.pi);
      final y = centerY +
          math.cos((normalizedX * 3 * math.pi) - phase * 1.5) *
              (amplitude * 25 * envelope);
      path2.lineTo(x, y);
    }

    final paint2 = Paint()
      ..color = secondaryColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path2, paint2);
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant HarmonicSoundwavePainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.phase != phase ||
        oldDelegate.primaryColor != primaryColor;
  }
}
```

---

## 🔮 2. State-Driven Vector AI Core Widget

```dart
class AiVectorCoreWidget extends StatefulWidget {
  final AiAgentState state;
  final double audioAmplitude;
  final double size;

  const AiVectorCoreWidget({
    super.key,
    required this.state,
    this.audioAmplitude = 0.0,
    this.size = 220,
  });

  @override
  State<AiVectorCoreWidget> createState() => _AiVectorCoreWidgetState();
}

class _AiVectorCoreWidgetState extends State<AiVectorCoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _phaseController;

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _phaseController,
        builder: (context, child) {
          final phase = _phaseController.value * 2 * math.pi;
          final dynamicScale = 1.0 + (widget.audioAmplitude * 0.2);

          return Transform.scale(
            scale: dynamicScale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient Glow Backdrop
                  Container(
                    width: widget.size * 0.75,
                    height: widget.size * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getCoreColor(widget.state).withOpacity(0.4),
                          blurRadius: 35 + (widget.audioAmplitude * 25),
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  // Rotating Ring Canvas
                  Transform.rotate(
                    angle: phase * (widget.state == AiAgentState.thinking ? 2 : 0.5),
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: HarmonicSoundwavePainter(
                        amplitude: widget.audioAmplitude,
                        phase: phase,
                        primaryColor: _getCoreColor(widget.state),
                        secondaryColor: const Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCoreColor(AiAgentState state) {
    switch (state) {
      case AiAgentState.listening: return const Color(0xFF00E5FF);
      case AiAgentState.thinking: return const Color(0xFF7C4DFF);
      case AiAgentState.usingTool: return const Color(0xFFFFAB00);
      case AiAgentState.speaking: return const Color(0xFF00E676);
      case AiAgentState.error: return const Color(0xFFFF5252);
      default: return const Color(0xFF00B0FF);
    }
  }
}
```

---

## 🎮 3. 3D Model Integration Best Practices

When embedding GLB/GLTF models (such as reactive 3D avatars or abstract computational cores):
1. **Asset Optimization**: Compress GLB models using Draco compression (keep asset file sizes strictly under 5MB for smooth mobile loading).
2. **Dynamic PBR Lighting**: Use neutral HDR environment maps (Studio / Softbox) to ensure physical lighting reacts realistically across dark/light UI modes.
3. **Decoupled Render Boundaries**: Never place 3D viewports inside scroll views without explicit `RepaintBoundary` and memory recycling handlers.

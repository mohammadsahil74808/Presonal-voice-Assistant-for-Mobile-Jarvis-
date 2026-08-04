import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

/// Ultra 3D Matrix Perspective Sci-Fi Core Orb with dynamic 3D particle field, acoustic soundwaves, and gyroscopic tilt.
class AICoreOrb extends StatefulWidget {
  final AssistantState state;
  final double size;
  final double audioAmplitude;

  const AICoreOrb({
    super.key,
    required this.state,
    this.size = 220,
    this.audioAmplitude = 0.0,
  });

  @override
  State<AICoreOrb> createState() => _AICoreOrbState();
}

class _AICoreOrbState extends State<AICoreOrb> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _tiltController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(AICoreOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _adjustAnimationSpeed();
    }
  }

  void _adjustAnimationSpeed() {
    switch (widget.state) {
      case AssistantState.idle:
        _breathingController.duration = const Duration(seconds: 3);
        _rotationController.duration = const Duration(seconds: 10);
        break;
      case AssistantState.listening:
        _breathingController.duration = const Duration(milliseconds: 1200);
        _rotationController.duration = const Duration(seconds: 4);
        break;
      case AssistantState.processing:
        _breathingController.duration = const Duration(milliseconds: 700);
        _rotationController.duration = const Duration(seconds: 2);
        break;
      case AssistantState.speaking:
        _breathingController.duration = const Duration(milliseconds: 1400);
        _rotationController.duration = const Duration(seconds: 6);
        break;
      case AssistantState.error:
        _breathingController.duration = const Duration(seconds: 4);
        _rotationController.duration = const Duration(seconds: 18);
        break;
    }
    if (!_breathingController.isAnimating) _breathingController.repeat(reverse: true);
    if (!_rotationController.isAnimating) _rotationController.repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rotationController.dispose();
    _tiltController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    switch (widget.state) {
      case AssistantState.idle:
      case AssistantState.listening:
        return JarvisTheme.cyanAccent;
      case AssistantState.processing:
        return JarvisTheme.amberWarning;
      case AssistantState.speaking:
        return JarvisTheme.blueAccent;
      case AssistantState.error:
        return JarvisTheme.redError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final isAudioActive = widget.state == AssistantState.listening || widget.state == AssistantState.speaking;
    final double dynamicScaleBoost = isAudioActive ? (widget.audioAmplitude * 0.25) : 0.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _rotationController, _tiltController]),
      builder: (context, child) {
        final baseScale = _breathingAnimation.value;
        final totalScale = baseScale + dynamicScaleBoost;
        final rotation = _rotationController.value * 2 * math.pi;
        final tiltValue = _tiltController.value * 2 * math.pi;

        // 3D Perspective Matrix Tilt
        final tiltX = math.sin(tiltValue) * 0.16;
        final tiltY = math.cos(tiltValue * 1.2) * 0.14;

        final matrix3D = Matrix4.identity()
          ..setEntry(3, 2, 0.0015) // Perspective distortion
          ..rotateX(tiltX)
          ..rotateY(tiltY);

        return RepaintBoundary(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Volumetric Ambient Blur Glow
                Transform.scale(
                  scale: totalScale * 1.18,
                  child: Container(
                    width: widget.size * 0.85,
                    height: widget.size * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: (0.35 + (widget.audioAmplitude * 0.3)).clamp(0.2, 0.75)),
                          blurRadius: 45 + (widget.audioAmplitude * 20),
                          spreadRadius: 18 + (widget.audioAmplitude * 12),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3D Matrix Layer (Particle Dust & Tilted Ring Orbits)
                Transform(
                  transform: matrix3D,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 3D Floating Particle Node Field
                      CustomPaint(
                        size: Size(widget.size * 1.1, widget.size * 1.1),
                        painter: _ParticleFieldPainter3D(
                          color: primaryColor,
                          phase: rotation,
                          amplitude: widget.audioAmplitude,
                        ),
                      ),

                      // Outer 3D Orbital HUD Ring
                      Transform.rotate(
                        angle: rotation,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: _OrbitalRingPainter3D(
                            color: primaryColor.withValues(alpha: 0.65),
                            strokeWidth: 1.8,
                            dashCount: 12,
                          ),
                        ),
                      ),

                      // Counter-Rotating Inner Vector Ring
                      Transform.rotate(
                        angle: -rotation * 1.6,
                        child: CustomPaint(
                          size: Size(widget.size * 0.76, widget.size * 0.76),
                          painter: _OrbitalRingPainter3D(
                            color: primaryColor.withValues(alpha: 0.85),
                            strokeWidth: 2.2,
                            dashCount: 16,
                          ),
                        ),
                      ),

                      // Dynamic Acoustic Waveform Canvas Ring
                      if (isAudioActive && widget.audioAmplitude > 0.04)
                        Transform.scale(
                          scale: 1.0 + (widget.audioAmplitude * 0.18),
                          child: CustomPaint(
                            size: Size(widget.size * 0.92, widget.size * 0.92),
                            painter: _AcousticWaveCanvasPainter(
                              color: primaryColor,
                              amplitude: widget.audioAmplitude,
                              phase: rotation * 2.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 3D Glass Core Lens Flare & Gradient Orb
                Transform.scale(
                  scale: totalScale,
                  child: Container(
                    width: widget.size * 0.46,
                    height: widget.size * 0.46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          primaryColor,
                          primaryColor.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.75, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.95),
                          blurRadius: 28 + (widget.audioAmplitude * 18),
                          spreadRadius: 6 + (widget.audioAmplitude * 10),
                        ),
                      ],
                    ),
                  ),
                ),

                // Central White Hot Pulse Dot
                Container(
                  width: widget.size * 0.13,
                  height: widget.size * 0.13,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrbitalRingPainter3D extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _OrbitalRingPainter3D({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    final arcAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 == 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          i * arcAngle,
          arcAngle * 0.68,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter3D oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount;
  }
}

class _ParticleFieldPainter3D extends CustomPainter {
  final Color color;
  final double phase;
  final double amplitude;

  _ParticleFieldPainter3D({
    required this.color,
    required this.phase,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 14.0;
    const int particleCount = 18;

    for (int i = 0; i < particleCount; i++) {
      final double angle = (i * 2 * math.pi) / particleCount + phase * (i % 2 == 0 ? 1 : -1);
      final double zDepth = math.sin(angle + phase) * 0.5 + 0.5; // Z depth scale between 0.0 and 1.0
      final double currentRadius = baseRadius + (math.sin((angle * 3) + phase) * (8.0 + (amplitude * 10.0)));

      final double x = center.dx + math.cos(angle) * currentRadius;
      final double y = center.dy + math.sin(angle) * currentRadius;

      final double particleSize = (2.0 + (zDepth * 3.5)) * (1.0 + (amplitude * 0.5));
      final paint = Paint()
        ..color = color.withValues(alpha: (0.3 + (zDepth * 0.65)).clamp(0.1, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter3D oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.amplitude != amplitude || oldDelegate.color != color;
  }
}

class _AcousticWaveCanvasPainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final double phase;

  _AcousticWaveCanvasPainter({
    required this.color,
    required this.amplitude,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 + (amplitude * 2.5);

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 12.0;

    final path = Path();
    const int points = 60;
    for (int i = 0; i <= points; i++) {
      final double angle = (i * 2 * math.pi) / points;
      final double waveOffset = math.sin((angle * 8) + phase) * (amplitude * 10.0) +
          math.cos((angle * 12) - phase) * (amplitude * 5.0);
      final double currentRadius = baseRadius + waveOffset;

      final double x = center.dx + math.cos(angle) * currentRadius;
      final double y = center.dy + math.sin(angle) * currentRadius;

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
  bool shouldRepaint(covariant _AcousticWaveCanvasPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.amplitude != amplitude || oldDelegate.phase != phase;
  }
}

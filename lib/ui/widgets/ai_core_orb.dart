import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/enums/assistant_state.dart';
import '../theme/jarvis_theme.dart';

class AICoreOrb extends StatefulWidget {
  final AssistantState state;
  final double size;

  const AICoreOrb({
    super.key,
    required this.state,
    this.size = 220,
  });

  @override
  State<AICoreOrb> createState() => _AICoreOrbState();
}

class _AICoreOrbState extends State<AICoreOrb>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rotationController;
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
      duration: const Duration(seconds: 12),
    )..repeat();

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
        _rotationController.duration = const Duration(seconds: 12);
        break;
      case AssistantState.listening:
        _breathingController.duration = const Duration(milliseconds: 1200);
        _rotationController.duration = const Duration(seconds: 5);
        break;
      case AssistantState.processing:
        _breathingController.duration = const Duration(milliseconds: 800);
        _rotationController.duration = const Duration(seconds: 3);
        break;
      case AssistantState.speaking:
        _breathingController.duration = const Duration(milliseconds: 1500);
        _rotationController.duration = const Duration(seconds: 7);
        break;
      case AssistantState.error:
        _breathingController.duration = const Duration(seconds: 4);
        _rotationController.duration = const Duration(seconds: 20);
        break;
    }
    if (!_breathingController.isAnimating) {
      _breathingController.repeat(reverse: true);
    }
    if (!_rotationController.isAnimating) {
      _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Color _getPrimaryColor() {
    switch (widget.state) {
      case AssistantState.idle:
        return JarvisTheme.cyanAccent;
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

    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _rotationController]),
      builder: (context, child) {
        final scale = _breathingAnimation.value;
        final rotation = _rotationController.value * 2 * math.pi;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ambient Glow
              Transform.scale(
                scale: scale * 1.15,
                child: Container(
                  width: widget.size * 0.85,
                  height: widget.size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.35),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),

              // Outer Rotating Ring
              Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _OrbRingPainter(
                    color: primaryColor.withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashCount: 8,
                  ),
                ),
              ),

              // Counter-Rotating Inner Ring
              Transform.rotate(
                angle: -rotation * 1.5,
                child: CustomPaint(
                  size: Size(widget.size * 0.78, widget.size * 0.78),
                  painter: _OrbRingPainter(
                    color: primaryColor.withValues(alpha: 0.8),
                    strokeWidth: 2.0,
                    dashCount: 12,
                  ),
                ),
              ),

              // Glowing Central Core
              Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.45,
                  height: widget.size * 0.45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        primaryColor,
                        primaryColor.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.8, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.9),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // Central Inner Pulse Dot
              Container(
                width: widget.size * 0.12,
                height: widget.size * 0.12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _OrbRingPainter({
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
          arcAngle * 0.65,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbRingPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount;
  }
}

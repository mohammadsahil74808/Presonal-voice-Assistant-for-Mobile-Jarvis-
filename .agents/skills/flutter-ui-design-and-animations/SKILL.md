---
name: flutter-ui-design-and-animations
description: Master Flutter UI skill for creating state-of-the-art visual design, rich animations, 60 FPS CustomPaint vector canvases, dynamic particle effects, glassmorphism, micro-interactions, dark mode visual identity, and reactive UI layouts that rival or exceed modern web applications (React, Next.js, Framer Motion). Use when requested to build or improve Flutter UI/UX, animations, HUD interfaces, visual effects, or design systems.
---

# Flutter Ultra-High-Quality UI, Design & Animation Skill

This skill enforces best-in-class Flutter UI design practices, dynamic vector animations, custom shaders/canvases, and interactive micro-animations that surpass standard web frameworks (React, Next.js, Framer Motion).

---

## 🎨 1. Visual Aesthetics & Design Principles

To create designs that truly **WOW** the user:

### A. Curated Color Palettes & Dark Mode
- **Never use plain raw colors** (`Colors.red`, `Colors.blue`). Use HSL-tailored dark backdrops, sleek neon accents, and smooth gradient stops.
- **JARVIS/Futuristic Palette**:
  - Dark Backdrop: `#0B0E14`, `#0F172A`
  - Neon Cyan: `#00E5FF`
  - Gold Amber: `#FFAB00`
  - Emerald Green: `#00E676`
  - Coral Red: `#FF5252`

### B. Glassmorphism & Backdrop Blurs
- Combine `BackdropFilter` with `ImageFilter.blur(sigmaX: 15, sigmaY: 15)` and translucent dark cards (`#EE0B0E14` or `Colors.white.withOpacity(0.08)`).
- Add thin glowing borders (`Border.all(color: accentColor.withOpacity(0.4), width: 1.5)`).

### C. Modern Typography
- Use Google Fonts (such as *Outfit*, *Inter*, *Fira Code*, or *Roboto*) with explicit font weights (`FontWeight.w600`) and letter spacing (`letterSpacing: 1.2`).

---

## ⚡ 2. 60 FPS Vector Canvases & Custom Animations

When building complex graphics, orb visualizers, or particle effects, **do not rely on heavy video files or webviews**. Use native high-performance Flutter canvas primitives.

### A. CustomPaint & Math-Driven Canvases
- Extend `CustomPainter` to draw concentric rotating rings, dash-line arcs, audio-reactive waveform paths, and glowing particle orbits using `Canvas.drawPath()`, `Canvas.drawArc()`, and `Paint.shader`.
- Use `SweepGradient` or `RadialGradient` shaders directly on `Paint()` objects for glowing laser/neon ring effects.

### B. Micro-Animations & Spring Physics
- Use `AnimationController` with curves like `Curves.easeOutBack`, `Curves.elasticOut`, or `Curves.bounceOut` for tactile UI feedback.
- Set fast responsive durations (~250ms to 350ms) for entrance animations, modal popups, and floating overlays.

### C. Audio-Reactive Soundwave Visualization
- Modulate scale, blur radius, and stroke width in real-time based on normalized microphone amplitude (`0.0` - `1.0`).
- Superimpose multiple harmonic sine waves (`math.sin((angle * 6) + phase) * amplitude`) for authentic organic acoustic motion.

---

## 🚀 3. Performance & Architecture Rules

1. **Isolate Rebuilds**:
   - Wrap animated widgets in `AnimatedBuilder` or `ValueListenableBuilder`.
   - Never call `setState()` at 60 FPS on parent screens; update only the specific animated component.
2. **RepaintBoundary Isolation**:
   - Wrap complex `CustomPaint` or particle canvases in a `RepaintBoundary` widget to prevent surrounding UI widgets from re-executing rasterization passes.
3. **Memory & Ticker Cleanup**:
   - Always call `_animationController.dispose()` inside `State.dispose()` to eliminate memory and frame leaks.
4. **Const Constructor Hygiene**:
   - Mark non-changing widget subtrees with `const` to allow Flutter's element tree to skip redundant rebuild cycles.

---

## 📱 4. Example: Dynamic Vector Orb Widget Pattern

```dart
class VectorGlowOrb extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final double audioAmplitude;

  const VectorGlowOrb({
    super.key,
    this.size = 200,
    required this.primaryColor,
    this.audioAmplitude = 0.0,
  });

  @override
  State<VectorGlowOrb> createState() => _VectorGlowOrbState();
}

class _VectorGlowOrbState extends State<VectorGlowOrb> with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          final rotation = _rotationController.value * 2 * math.pi;
          final dynamicScale = 1.0 + (widget.audioAmplitude * 0.25);

          return Transform.scale(
            scale: dynamicScale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing Ambient Backdrop
                  Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.5),
                          blurRadius: 30 + (widget.audioAmplitude * 20),
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Rotating Canvas Ring
                  Transform.rotate(
                    angle: rotation,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _RingPainter(color: widget.primaryColor),
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
}
```

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Generates rhythmic speaking animations synchronized with TTS start/stop events when native audio amplitude is unavailable.
/// Separates real acoustic audio analysis from synthetic vocal speaking animations.
class SpeechAnimationController extends ChangeNotifier {
  Timer? _animationTimer;
  double _speechAmplitude = 0.0;
  bool _isSpeaking = false;
  final math.Random _random = math.Random();
  double _step = 0.0;

  /// Current speech animation intensity value between 0.0 and 1.0.
  double get amplitude => _speechAmplitude;
  bool get isSpeaking => _isSpeaking;

  /// Starts vocal rhythm animation synchronized with TTS audio playback.
  void startAnimation() {
    if (_isSpeaking) return;
    _isSpeaking = true;
    _step = 0.0;

    // Run interval at 40ms (~25 FPS update rate) for smooth vector animation without overloading CPU
    _animationTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!_isSpeaking) {
        timer.cancel();
        return;
      }
      _step += 0.25;
      // Generate natural speech cadences using multiple superimposed harmonic sine waves with subtle randomness
      final baseSine = math.sin(_step) * 0.3 + 0.5;
      final fastSine = math.cos(_step * 2.3) * 0.15;
      final randomJitter = (_random.nextDouble() * 0.15) - 0.075;
      
      final double nextValue = (baseSine + fastSine + randomJitter).clamp(0.2, 0.98);
      _speechAmplitude = _speechAmplitude * 0.4 + nextValue * 0.6; // Smooth interpolation
      notifyListeners();
    });
  }

  /// Stops TTS speech animation and smoothly decays amplitude back to idle zero.
  void stopAnimation() {
    _isSpeaking = false;
    _animationTimer?.cancel();
    _animationTimer = null;
    if (_speechAmplitude != 0.0) {
      _speechAmplitude = 0.0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}

import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Audio level processor that normalizes and smoothes microphone sound amplitude for live UI animations.
/// Completely privacy-preserving: strictly processes amplitude values and never exposes or stores raw audio recordings.
class AudioLevelController extends ChangeNotifier {
  double _currentAmplitude = 0.0;
  double _smoothedAmplitude = 0.0;

  /// Normalized audio amplitude between 0.0 (silent) and 1.0 (peak speech).
  double get amplitude => _smoothedAmplitude;

  /// Updates the controller with raw decibel or sound level readings from the microphone engine.
  void updateLevel(double soundLevel) {
    // Normalizing typical decibel range (-2.0 dB to 12.0 dB from Android recognizer) to 0.0 - 1.0
    double clamped = ((soundLevel + 2.0) / 14.0).clamp(0.0, 1.0);
    _currentAmplitude = math.pow(clamped, 1.5).toDouble(); // Apply curve for natural dynamics

    // Exponential smoothing (damping) to eliminate visual stutter and jitter
    final double target = _currentAmplitude;
    final double nextSmoothed = _smoothedAmplitude * 0.65 + target * 0.35;

    // Prevent excessive rebuilds by notifying only when visual variance exceeds threshold
    if ((nextSmoothed - _smoothedAmplitude).abs() > 0.015 || (target == 0.0 && _smoothedAmplitude > 0.0)) {
      _smoothedAmplitude = nextSmoothed;
      notifyListeners();
    }
  }

  /// Resets amplitude cleanly when listening finishes.
  void reset() {
    if (_smoothedAmplitude != 0.0) {
      _currentAmplitude = 0.0;
      _smoothedAmplitude = 0.0;
      notifyListeners();
    }
  }
}

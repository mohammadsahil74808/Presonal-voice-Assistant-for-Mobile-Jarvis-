import 'package:flutter/material.dart';

class JarvisTheme {
  // Brand / Core Futuristic Palette
  static const Color bgDark = Color(0xFF060913);
  static const Color cardDark = Color(0xAA0E1628);
  static const Color cyanAccent = Color(0xFF00F0FF);
  static const Color cyanGlow = Color(0x6600F0FF);
  static const Color blueAccent = Color(0xFF0077FF);
  static const Color purpleGlow = Color(0x44A020F0);
  static const Color amberWarning = Color(0xFFFFB700);
  static const Color redError = Color(0xFFFF3366);
  static const Color textPrimary = Color(0xFFE2F1FF);
  static const Color textSecondary = Color(0xFF8AA2C0);
  static const Color textMuted = Color(0xFF4C6280);

  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: cyanAccent,
        surface: cardDark,
        error: redError,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

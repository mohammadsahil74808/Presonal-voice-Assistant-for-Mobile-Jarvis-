import 'package:flutter/material.dart';

/// Placeholder screen for JARVIS HUD (Phase 2 UI will build full HUD)
class HudScreen extends StatelessWidget {
  const HudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.graphic_eq, color: Colors.cyanAccent, size: 64),
              SizedBox(height: 16),
              Text(
                'JARVIS',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'System Initialized',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

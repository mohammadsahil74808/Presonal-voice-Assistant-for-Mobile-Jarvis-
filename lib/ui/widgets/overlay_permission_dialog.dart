import 'package:flutter/material.dart';
import '../../system_assistant/system_assistant_platform.dart';

/// User-friendly dialog guiding the user to grant Android "Display over other apps" permission and set Default Digital Assistant App.
class OverlayPermissionDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const OverlayPermissionDialog({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
      ),
      title: Row(
        children: const [
          Icon(Icons.assistant, color: Color(0xFF00E5FF)),
          SizedBox(width: 10),
          Text(
            'System Assistant Setup',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'To activate JARVIS like Google Assistant or Siri over WhatsApp, Chrome, or YouTube:\n\n1. Grant "Display over other apps" permission.\n2. Set JARVIS as your phone\'s Default Digital Assistant App in Settings.',
        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF00E5FF),
            side: const BorderSide(color: Color(0xFF00E5FF)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            SystemAssistantPlatform.openDefaultAssistantSettings();
          },
          child: const Text('Set Default Assistant'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            foregroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onOpenSettings();
          },
          child: const Text('Display Over Apps', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

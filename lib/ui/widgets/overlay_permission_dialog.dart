import 'package:flutter/material.dart';

/// User-friendly dialog guiding the user to grant Android "Display over other apps" permission.
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
          Icon(Icons.layers, color: Color(0xFF00E5FF)),
          SizedBox(width: 10),
          Text(
            'Enable System Overlay',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'JARVIS requires permission to display the assistant overlay over other applications so you can invoke "Hey JARVIS" while using WhatsApp, Chrome, or YouTube.',
        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
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
          child: const Text('Open Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

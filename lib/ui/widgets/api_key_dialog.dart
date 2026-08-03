import 'package:flutter/material.dart';
import '../theme/jarvis_theme.dart';

class ApiKeyDialog extends StatefulWidget {
  final String? initialKey;
  final Function(String key) onSave;
  final VoidCallback? onClear;

  const ApiKeyDialog({
    super.key,
    this.initialKey,
    required this.onSave,
    this.onClear,
  });

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late final TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKey ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: JarvisTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: JarvisTheme.cyanAccent.withValues(alpha: 0.3),
        ),
      ),
      title: Row(
        children: const [
          Icon(Icons.key_rounded, color: JarvisTheme.cyanAccent, size: 22),
          SizedBox(width: 10),
          Text(
            'GEMINI API KEY',
            style: TextStyle(
              color: JarvisTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please enter your Google Gemini API Key. Your key is stored encrypted on your device and never committed or shared, Sir.',
            style: TextStyle(color: JarvisTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscureText,
            style: const TextStyle(color: JarvisTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'AIzaSy...',
              hintStyle: const TextStyle(color: JarvisTheme.textMuted),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: JarvisTheme.cyanAccent.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: JarvisTheme.cyanAccent.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: JarvisTheme.cyanAccent),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: JarvisTheme.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (widget.onClear != null)
          TextButton(
            onPressed: () {
              widget.onClear!();
              Navigator.pop(context);
            },
            child: const Text('CLEAR', style: TextStyle(color: JarvisTheme.redError)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: JarvisTheme.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: JarvisTheme.cyanAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            final key = _controller.text.trim();
            if (key.isNotEmpty) {
              widget.onSave(key);
              Navigator.pop(context);
            }
          },
          child: const Text('SAVE KEY', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

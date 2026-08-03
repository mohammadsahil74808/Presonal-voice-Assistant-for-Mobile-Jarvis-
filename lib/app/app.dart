import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../ui/conversational_screen.dart';
import '../ui/theme/jarvis_theme.dart';

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: JarvisTheme.darkTheme,
      home: const ConversationalScreen(),
    );
  }
}

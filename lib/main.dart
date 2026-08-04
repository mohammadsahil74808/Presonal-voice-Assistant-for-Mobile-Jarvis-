import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Graceful fallback if .env is not provided
  }
  
  await ServiceLocator.instance.initialize();
  // Enable system invocation service for background "Hey JARVIS" wake-word listening
  await ServiceLocator.instance.systemAssistantService.enableSystemInvocation();

  runApp(const JarvisApp());
}

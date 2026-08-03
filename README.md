# JARVIS Mobile

A standalone Android personal AI voice assistant built with Flutter, powered by Google Gemini, designed with an architecture supporting personalized memory, Hinglish conversation capabilities, and native phone tools.

## Architecture

- **`lib/app/`**: Root application widget and themes.
- **`lib/core/`**: Core enums (`AssistantState`), constants, and system types.
- **`lib/config/`**: App environment configuration and API key loaders.
- **`lib/ai/`**: Abstract AI Provider interfaces (Gemini / Local LLM ready).
- **`lib/voice/`**: Voice pipeline abstractions (Speech-To-Text & Text-To-Speech).
- **`lib/memory/`**: Short-term context & long-term memory abstractions.
- **`lib/tools/`**: Phone actions & tool router interface.
- **`lib/permissions/`**: Permission management layer.
- **`lib/settings/`**: User preferences & app settings foundation.
- **`lib/ui/`**: Futuristic JARVIS HUD user interface.

## Getting Started

1. Copy `.env.example` to `.env` and add your `GEMINI_API_KEY`.
2. Run `flutter pub get`.
3. Run `flutter run` on a connected Android device or emulator.

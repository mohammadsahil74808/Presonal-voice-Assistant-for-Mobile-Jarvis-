---
name: flutter-ai-assistant-and-agents
description: Specialized Flutter skill for building state-of-the-art AI assistant, AI agent, and voice-first mobile operating interfaces. Enforces non-chatbot AI operating environment paradigms, multi-state visual & motion systems, transparent agent tool activity tracking, high-performance 3D visualizers, human-readable reasoning flows, multimodal input bars, granular permission controls, user-manageable memory systems, offline/online orchestration, and 60 FPS mobile ergonomics. Use whenever creating, designing, or upgrading Flutter AI mobile apps, Jarvis-like voice assistants, AI agents, HUD interfaces, or multimodal AI applications.
---

# 🚀 Flutter AI Assistant & AI Agent Mobile Operating Environment Skill

This skill governs the creation of next-generation Flutter mobile applications for AI assistants, autonomous agents, and voice/multimodal operating environments. 

It strictly prohibits generic chatbot clones and enforces an **AI Operating System interface paradigm**—making users feel they are interacting with an active, intelligent system capable of perception, reasoning, tool execution, and contextual memory.

---

## 🧭 1. Core Design Philosophy

### ❌ What to NEVER Build
* **Generic Chatbot Clones**: Standard scrollable chat bubbles with a plain text field and send button.
* **Fake Futuristic Visuals**: Meaningless sci-fi lines, excessive glassmorphic clutter, or random glowing gradients.
* **Decorations Without Purpose**: Orbs, spinners, or particle fields that don't react to actual AI state or audio input.
* **Opaque Execution**: Dumping raw JSON logs, hidden multi-step actions, or claiming tools succeeded when they failed.

### ✅ The AI Operating Environment Standard
* **Active Perception**: The UI visually reflects what the AI hears, sees, reads, and processes in real-time.
* **Transparent Agent Reasoning**: Multi-step workflows (Planning → Searching → Tool Use → Synthesizing) are displayed as clean, human-readable activity cards with expandable technical details.
* **Voice-First Dignity**: Voice is treated as a primary modal interface with smooth, non-disruptive state transitions.
* **Ergonomic Mobile UX**: Primary interaction points stay within natural thumb reach, with tactile haptic feedback and dynamic keyboard avoidance.

---

## ⚡ 2. AI State System & Visual Motion Language

The application state machine must explicitly track and visualize the AI's operational status. Each state possesses a distinct, coherent visual and motion identity:

| State | Visual Indicator | Motion & Haptics | User Expectation |
| :--- | :--- | :--- | :--- |
| **`IDLE`** | Minimal, calm core element, low opacity ambient glow. | Slow breathing curve (`Curves.easeInOutSine`, 3-4s pulse). | System is ready and listening for triggers. |
| **`LISTENING`** | Real-time audio waveform / spectral bars, microphone amplitude ring. | Dynamic scaling based on normalized mic input (0.0 - 1.0). Heavy soft haptic on trigger. | System is capturing user voice input. |
| **`THINKING`** | Computational geometric rotations, subtle particle convergence. | Steady mathematical rotation (`CustomPaint`), crisp rhythm. | AI is parsing intent and forming a execution plan. |
| **`PROCESSING`** | Smooth continuous morphing without layout shifting spinners. | Fluid gradient sweep across status headers. | Data is being processed or context is loading. |
| **`EXECUTING`** | Dynamic progress track, step sequence highlights. | Micro pulse per completed sub-step. Medium haptic on step complete. | Agent is running real tasks. |
| **`USING_TOOL`** | Dedicated Tool Card showing target service icon (Web, Calendar, Camera, API). | Pulse border around tool badge. | Agent is interacting with an external integration. |
| **`WAITING_FOR_USER`**| Highlighted permission / input modal card. | Attention-getting subtle bouncing ring (`Curves.elasticOut`). | User action required before continuing. |
| **`SPEAKING`** | Audio-synced soundwave canvas, dynamic speech energy ring. | Harmonic sine-wave modulation synchronized with TTS output. | Assistant is talking back to user. |
| **`COMPLETED`** | Clean success checkmark ring, subtle green/cyan ambient pulse. | Single smooth scale-in + light tap haptic. | Task completed successfully. |
| **`ERROR`** | Muted coral/amber border glow, explanatory error card with retry action. | Micro shake animation (`Curves.elasticIn`, 300ms). Heavy error haptic. | Something failed with clear recovery steps. |
| **`INTERRUPTED`** | Instant state transition back to IDLE or LISTENING. | Immediate cancellation of animations, brief dampening curve. | User canceled or spoke over system. |
| **`OFFLINE`** | Status badge showing "Local Model Only" or "Offline Mode". | Static indicator, disabled cloud tool badges. | System operating on edge/local context. |

---

## 🎨 3. Interaction Models & Home Screen Paradigms

Never default the main screen to a full-screen messaging thread. Select or combine interaction models based on product intent:

1. **AI Command Center**: Dominant central visual core/orb, quick action action chips, active agent task tiles, and recent context widgets.
2. **Conversational Workspace**: Dynamic canvas where messages, streaming response blocks, rendered charts, and tool output cards coexist cleanly.
3. **Voice-First HUD**: Full-screen reactive 3D core/canvas with floating heads-up display metrics, voice controls, and gesture swipe-up cards.
4. **Multimodal Canvas**: Split-view or floating panel designed for simultaneous text, camera viewport, file drop, and screen analysis.
5. **Task-Oriented Dashboard**: Focused on active agent queues, background tasks, pending approvals, and scheduled automations.

---

## 🎙️ 4. Voice-First Experience & Interruption

Voice interactions must feel conversational, fast, and continuous:

```
[ Idle State ] ──(User Voice / Tap)──> [ Listening State ]
                                             │ (Silence Detected)
[ Speaking State ] <──(TTS Stream)── [ Thinking / Processing ]
        │
        ├──(User Tap / Speak)──> [ Interrupted State ] ──> [ Listening State ]
        └──(TTS Finished)──────> [ Idle State ]
```

* **Seamless Transitions**: Transition from listening to processing without replacing or flickering screen layouts.
* **Instant Interruption**: Provide tap-to-interrupt overlay zones and audio ducking to let users stop TTS generation at any millisecond.
* **Soundwave Rendering**: Use `CustomPainter` to draw multi-harmonic sine waves driven by audio amplitude inputs:
  $$\text{y}(x) = \text{center} + \sin(x \cdot \text{frequency} + \text{phase}) \cdot \text{amplitude}$$

---

## 🌐 5. 3D Assistant Core System

When 3D visualization is used, it must directly reflect AI state, energy, and speech, functioning as a real-time system visualization rather than background video.

### Architecture Rules for 3D in Flutter:
1. **Decouple UI & 3D Render Loop**: Flutter manages application UI, navigation, business logic, state, and controls. Specialized 3D visualizers (e.g., custom vector canvas shaders, Filament, `flutter_3d_controller`, or SceneKit/Three.js bridges) run in dedicated render bounds.
2. **Asset Management**: Support external GLB/GLTF assets, PBR textures, and HDR lighting environments dynamically loaded from assets or local storage.
3. **State Reflection**: Pass AI state enums and continuous normalized audio levels down to the 3D container to drive vertex shaders, rotation speed, scale, and color stops.

---

## 🛠️ 6. Agent Activity & Tool Visualization

When an agent executes multi-step plans, visualize the progression using a structured **Activity Hierarchy**:

```
┌─────────────────────────────────────────────────────────────┐
│ ⚡ Agent Task: "Book flight & update calendar"              │
├─────────────────────────────────────────────────────────────┤
│  ✓  Understanding request                     [Completed]   │
│  ✓  Searching Web: "SFO to JFK flights"       [Completed]   │
│  ⚙  Using Tool: Google Calendar API          [Executing]   │
│     └─ Checking conflict for Aug 12, 2026                 │
│  ○  Confirming details with user              [Queued]      │
├─────────────────────────────────────────────────────────────┤
│ ▶ Show Technical Logs & Raw Payload                        │
└─────────────────────────────────────────────────────────────┘
```

* **Default View**: Clean, human-readable step indicators with live icons and status chips.
* **Expandable Details**: Allow technical users to unfold raw payload JSON, search terms, or API response bodies without cluttering the main flow.
* **Honest Tool Status**: Always reflect real network and execution states. If a tool fails, present the exact error step with actionable recovery (Retry, Edit Inputs, Override).

---

## 🔐 7. Permissions, Memory & Connected Services

### A. Transparent Permission System
When an agent requests sensitive device or account operations (Location, Camera, Contacts, Payment, File Deletion):
* **What**: Explicitly state the target action.
* **Why**: Explain the AI's rationale for needing access.
* **Impact**: Clearly outline what will happen upon granting or denying.
* **Controls**: Provide unambiguous `Allow Once`, `Allow Always`, `Deny`, and `Cancel Task` buttons.

### B. User-Controlled Memory System
Design memory as an interactive feature where users can review, edit, or delete stored context:
* **Categories**: Personal Preferences, Stored Credentials/Services, Project Context, Learned Instructions.
* **Management UI**: Provide toggle switches for active memory, inline editing of stored items, and explicit "Forget Item" buttons.

### C. Connected Services Management
Dedicated integration hub displaying real connection states (`Connected`, `Re-authentication Needed`, `Disconnected`) and granted API scopes.

---

## 📱 8. Mobile Ergonomics & Performance Rules

### A. Ergonomics & Reachability
* Keep key interaction triggers (Microphone floating button, Input Bar, Action Confirmations) in the **Bottom Ergonomic Zone** (lower 40% of the screen).
* Ensure minimum touch target sizes of **48×48 dp**.
* Use subtle tactile haptics (`HapticFeedback.lightImpact()`, `mediumImpact()`) for state shifts, tool completions, and audio triggers.

### B. 60 FPS Performance Hygiene
1. **Isolate Animated Subtrees**: Always wrap high-frequency animated widgets in `AnimatedBuilder` or `ValueListenableBuilder`. Never execute parent `setState()` calls at 60 FPS.
2. **Repaint Boundaries**: Enclose complex custom canvases and 3D viewports in `RepaintBoundary` widgets to prevent unneeded rasterization passes across surrounding UI.
3. **Async Isolate Compute**: Offload heavy JSON parsing, vector embeddings, and local model inference to background Dart isolates using `compute()`.
4. **Ticker Disposal**: Rigorously dispose all `AnimationController` and stream subscriptions in `State.dispose()`.

---

## 🏗️ 9. Maintainable Flutter Architecture

Organize the codebase into decoupled layers:

```
lib/
├── core/
│   ├── theme/          # Color tokens, Google Fonts, gradients, motion curves
│   ├── network/        # Cloud API clients & SSE streaming handlers
│   └── services/       # Audio recorder, TTS, permissions, local storage
├── domain/
│   ├── models/         # AI state, Agent step, Tool request, Memory item schemas
│   └── agent/          # State machine, Tool execution engine, Orchestration logic
├── presentation/
│   ├── state/          # Riverpod / Bloc / ValueNotifier providers
│   ├── screens/        # Home HUD, Command Center, Memory Manager, Integrations
│   ├── widgets/        # Vector Core, Soundwave canvas, Activity cards, Permission modals
│   └── animations/     # Custom painters, dynamic shaders, spring transitions
```

---

## ✅ 10. Quality Gate Checklist

Before declaring any Flutter AI Assistant or Agent UI complete, verify against this 12-point quality checklist:

- [ ] **1. Non-Chatbot Identity**: Does the UI feel like an intelligent mobile operating environment rather than a standard messaging thread?
- [ ] **2. State Clarity**: Can a user immediately identify whether the AI is `Listening`, `Thinking`, `Executing Tool`, or `Waiting` without reading raw logs?
- [ ] **3. Voice Ergonomics**: Is voice interaction smooth with real-time visual feedback and instant tap-to-interrupt capabilities?
- [ ] **4. Tool Transparency**: Are multi-step agent actions presented as clear, human-readable progress cards with expandable technical details?
- [ ] **5. Honest Execution**: Are real tool outputs and failures displayed without deceptive success states?
- [ ] **6. Permission Dignity**: Does every sensitive agent permission request clearly convey What, Why, and What Happens Next?
- [ ] **7. Memory Governance**: Can the user easily view, edit, disable, or delete what the AI remembers about them?
- [ ] **8. Purposeful Visualizer**: Does the 3D/canvas core reflect active system state, speech, and energy rather than serving as static eye candy?
- [ ] **9. Mobile Ergonomics**: Are critical controls positioned within the bottom thumb zone with tactile haptic feedback?
- [ ] **10. 60 FPS Performance**: Are rebuilds isolated with `AnimatedBuilder` and `RepaintBoundary`, maintaining 60 FPS without jank?
- [ ] **11. Error Recovery**: Do network failures, tool errors, or rate limits provide helpful human-language explanations and immediate retry paths?
- [ ] **12. Multimodal Coherence**: Do text, voice, camera, and file inputs merge into a single, unified interaction bar?

---

## 🎯 Final Standard

The resulting application must feel like an **intelligent mobile operating interface**—responsive, transparent, state-aware, fast, and beautiful.

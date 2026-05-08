# Riri: Gen Z Taglish Reminder App

Riri is a Filipino Gen Z lifestyle and reminder Android application designed with an offline-first, on-device AI approach. It uses personality-driven notifications and a witty Taglish tone to help users manage their tasks.

## Project Structure

- **`app/`**: The primary Android application module.
  - **Architecture**: MVVM + Clean Architecture.
  - **Tech Stack**: Kotlin, Jetpack Compose, Room (SQLite), WorkManager, AlarmManager, Koin (DI).
  - **AI Core**: MediaPipe GenAI (Gemma/Qwen), ONNX Fallback, and heuristic Keyword Classifier.
- **`riri_frontend/`**: A Vite + React + TailwindCSS design reference bundle (Figma-derived).
- **`reaction_stickers/`**: Asset directory for Riri's character expressions.

## Building and Running

### Android Application (`app/`)
The project uses Gradle with Kotlin DSL.
- **Assemble Debug APK**: `./gradlew assembleDebug`
- **Run Unit Tests**: `./gradlew test`
- **Run Instrumentation Tests**: `./gradlew connectedAndroidTest`
- **Linting**: `./gradlew ktlintFormat` (auto-format) or `./gradlew ktlintCheck`

### Frontend Design Reference (`riri_frontend/`)
- **Install Dependencies**: `cd riri_frontend && npm install`
- **Start Dev Server**: `npm run dev` (Refer to local instructions for manual server startup protocol)
- **Build**: `npm run build`

## Development Conventions

### Engineering Standards
- **Offline-First**: All core features (NLP, reminders, AI categorization) MUST work without an internet connection.
- **Reactive UI**: Use ViewModels with `StateFlow` and Jetpack Compose.
- **Lifecycle Awareness**: Ensure `WorkManager` and `AlarmManager` are resilient to Doze mode and process death.
- **Defensive Android**: Handle configuration changes and missing permissions before happy-path logic.
- **DI**: Use **Koin** for dependency injection (avoid Hilt/Dagger).
- **Documentation Sync**: Automatically update `GEMINI.md` (Maintenance Log) and `PLANNING.md` (Bug fixes/Progress) after every significant task or prompt to maintain an accurate project state.
- **Systematic Workflow**: Perform tasks 1-by-1 systematically. Avoid batching multiple unrelated changes or styles unless explicitly requested.

### Branding & UI
- **Theme**: Dark mode by default (`#1A1A2E`).
- **Accents**: Primary `#7C5CBF` (Violet), Secondary `#F5A623` (Amber).
- **Assets**: Character expressions (21 total) map to specific app states (e.g., "Barkada Mode", "Broken Streak").
- **Canvas**: Use Canvas/Skia for generating "Chaos Report" share cards.

### Copywriting & Tone
- **Language**: **Taglish** (Tagalog-English mix) is the default for UI and notifications.
- **Personality Modes**:
  - **Bestie**: Supportive, witty, default mode.
  - **Malupit**: Maximum roast, tough love.
  - **Chill**: Low pressure, relaxed.
  - **Tita**: Nagging but caring, traditional "Tita" vibe.
- **Terminology**: Use Gen Z slang and witty lines (e.g., "Weekly Receipts" for reports).

## Custom Agents

The project includes specialized agent definitions in `.github/agents/` for specific tasks:
- **Adversarial-Auditor**: Security and edge-case testing.
- **Copy-Tone**: Ensuring Taglish and personality-driven consistency.
- **UI-Engineer**: Jetpack Compose and branding implementation.
- **UI-Reviewer**: Design fidelity and UX consistency checks.

## Key Files & Documentation

- **`PLANNING.md`**: Detailed technical roadmap and requirements.
- **`STATUS.md`**: Current feature completion and migration status.
- **`.github/instructions/riri-project.instructions.md`**: Foundational agentic protocol for Riri.
- **`app/src/main/java/com/riri/app/core/ai/AIEngineRouter.kt`**: Main AI orchestration logic.
- **`app/src/main/java/com/riri/app/core/notifications/PersonalityNotificationCopy.kt`**: Tone definitions for notifications.

## Maintenance Log

### May 9, 2026
- **Build Stabilization**: 
    - Resolved widespread 'Unresolved reference' errors in Compose components (`MaterialTheme`, `Image`, `drawBehind`, `shadow`, `graphicsLayer`) by fixing missing imports across `MainActivity.kt`, `DashboardScreen.kt`, `OnboardingScreen.kt`, and `AddReminderBottomSheet.kt`.
    - Aligned Kotlin version to `2.1.20` and AGP to `9.2.0` as per project requirements.
    - Fixed ambiguous property access in `DashboardScreen.kt` by explicitly using `this.size` within `drawBehind` scopes.
- **Lite AI Mode**: 
    - **Onboarding**: Modified `OnboardingScreen.kt` to allow skipping the LLM download. Added "Start with Lite AI" option to proceed to the home screen using fallback mechanisms.
    - **Chat**: Updated `ChatViewModel.kt` with `generateLiteResponse` logic to provide witty Taglish replies even when the LLM is not loaded.
- **UI Interactivity**:
    - **MainActivity.kt**: Ensured all navigation and action lambdas are functional. Linked reminder card clicks to completion toggling.
    - **Theme**: Updated root `Surface` in `MainActivity` to use dynamic theme background color for visual alignment.
- **App Icon**: 
    - Configured Adaptive Icons in `mipmap-anydpi-v26` using the Riri logo foreground and a brand-aligned dark background (`#1A1A2E`).
    - Successfully replaced the generic Android launcher icon with `riri_logo.png` across supported devices.
    - Verified `AndroidManifest.xml` points to the correct launcher resources.
- **UI Refactor**: Realigned all major screens with `RIRI_DESIGN`.
- **Mandate**: Added **Documentation Sync** rule to `GEMINI.md`.
- **Documentation**: Synchronized `PLANNING.md` and `GEMINI.md`.

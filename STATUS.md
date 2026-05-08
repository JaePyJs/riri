# Riri Project Status - May 8, 2026

## Core Migration: COMPLETE ✅
- **Package Name:** Migrated from `com.example.riri` to `com.riri.app`.
- **Directory Structure:** All source files moved to `src/main/java/com/riri/app/`.
- **Imports:** All source files updated with new package references.
- **Resources:** `AndroidManifest.xml` and `build.gradle.kts` updated to `com.riri.app`.

## Feature Status

### 1. AI Engine (Offline-First) ✅
- **AIEngineRouter:** Orchestrates routing between Local LLM, ONNX Fallback, and Keyword Classifier.
- **LocalLLMEngine:** MediaPipe GenAI implementation for on-device inference (Qwen 1.5B).
- **OnnxFallbackEngine:** MobileBERT-based classification with Taglish support.
- **KeywordClassifier:** Heuristic-based fallback for critical Filipino slang/patterns.
- **ModelDownloadManager:** Handles background downloading of GGUF/Bin models to `filesDir`.

### 2. UI & Navigation ✅
- **Onboarding:** 4-screen flow implemented and functional.
- **Dashboard:** Main task view with "Riri" character expressions and status mapping.
- **Add Reminder:** Bottom sheet with text and voice input (Whisper integration).
- **Chat:** Interactive Taglish chat with Riri using the local LLM.
- **Profile:** User stats visualization and weekly "Receipts" generation.
- **Settings:** Personality mode selection (Bestie, Malupit, Chill, Tita) and notification toggles.

### 3. Data & Persistence ✅
- **Room DB:** Entities for Reminders, UserStats, and ChatHistory.
- **DataStore:** User preferences (personality, notifications) persisted.
- **Repository Pattern:** Clean abstraction for all data sources.

### 4. Notifications & WorkManager ✅
- **AlarmManager:** Exact alarms for reminders with personality-aware copy.
- **WorkManager:** Weekly "Chaos Report" generation and background maintenance.
- **BootReceiver:** Alarms automatically rescheduled on device reboot.

### 5. Share Cards ✅
- **BuildShareCardUseCase:** Generates 1080x1920 bitmaps for social sharing.
- **ShareService:** FileProvider-based sharing to external apps (IG, TikTok).

## Beta Readiness Checklist

1. [ ] **Manual Verification:** Perform a full walkthrough of the Onboarding -> Add Reminder -> Notification flow.
2. [ ] **Model Testing:** Verify `LocalLLMEngine` initializes correctly after download on a physical device.
3. [ ] **Asset Audit:** Ensure all Riri expression PNGs are correctly mapped in `RiriAssetMapper`.

## Current Blockers
- None. (Package migration resolved).

---
**Build Info:**
- **Namespace:** com.riri.app
- **Min SDK:** 26
- **Target SDK:** 35
- **DI:** Koin 3.5+

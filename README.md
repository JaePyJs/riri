# Riri: Gen Z Taglish Reminder App

Riri is a lifestyle and reminder companion designed with an offline-first, on-device architecture. It addresses the procrastination crisis by replacing dry, mechanical notifications with personality-driven, witty Taglish (Tagalog-English mix) nudges tailored for modern users.

---

## Projects in this repo

* **[riri_flutter/](file:///c:/Users/jmbar/AndroidStudioProjects/riri/riri_flutter/)** – The primary production app built in **Flutter (Dart 3)**. It is highly optimized, cross-platform, and fully persistent via local SQLite.
* **[legacy_android/](file:///c:/Users/jmbar/AndroidStudioProjects/riri/legacy_android/)** – Archived native Android application (Kotlin + Jetpack Compose). Kept strictly as a historic codebase reference (no longer maintained).

---

## The Core Solution

Standard productivity apps fail because generic notifications like *"Task due in 15 mins"* are easily ignored. Riri acts as an offline, reactive buddy that naggingly but lovingly keeps you on track:
* **Taglish Keyword Parser**: Schedules reminders through natural language sentences (e.g., *"Remind me to buy coffee in 2 hours"*).
* **Personality-Driven Copy**: Select between **Bestie**, **Malupit**, **Chill**, and **Tita** modes. Your choice dynamically updates Riri's expressions, dialogue templates, and notifications. Details on profiles reside in [docs/personas.md](file:///c:/Users/jmbar/AndroidStudioProjects/riri/docs/personas.md).
* **Status-Adaptive Dashboard**: Dynamic character expressions (wink, angry, confident, streak-hype) update reactively based on your daily task progress.

---

## Technical Stack & Architecture

Riri's production environment utilizes a Clean Architecture format divided into core infrastructures and isolated presentation features:
1. **Framework**: Flutter (Dart 3) for multi-platform (Windows, Web, Android, iOS) compiling.
2. **State Management**: Riverpod for reactive views and data flows.
3. **Database (Offline-First)**: Drift (SQLite ORM) for persistent query streams.
4. **Local AI**: Fast Taglish keyword classifier and intent parser.

Detailed layout specifications reside in:
* 🗺️ [Architecture Guide](file:///c:/Users/jmbar/AndroidStudioProjects/riri/docs/architecture.md) – Clean architecture mapping.
* 🔒 [Offline-First Principles](file:///c:/Users/jmbar/AndroidStudioProjects/riri/docs/offline-first.md) – local sovereignty and thread caching rules.
* 📦 [Source Folder Layout](file:///c:/Users/jmbar/AndroidStudioProjects/riri/riri_flutter/lib/README.md) – Directory guidelines and codegen commands.

---

## Getting Started

To launch Riri on your machine for local development and testing:

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
* Dart 3.x

### Commands
```bash
# 1. Navigate to active source
cd riri_flutter

# 2. Get dependencies
flutter pub get

# 3. Generate SQLite files
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run tests
flutter test

# 5. Launch (Desktop or Chrome Web)
flutter run
```

---

## Working in Google Antigravity

Riri is fully prepared for agent-assisted pair programming in the **Google Antigravity** IDE.

* **Recommended Settings**: Open the workspace and select **Review-driven development** to prompt approvals before running commands.
* **Specialized Agent Workflows**: We ship native prompt specs under `.agents/skills/` allowing you to trigger targeted agent workflows:
  - `"Antigravity, generate Taglish copywriting variants using riri_copywriter.json"`
  - `"Antigravity, refactor this controller layer using riri_refactor.json"`

For full configuration guidelines, refer to the [Antigravity Guide](file:///c:/Users/jmbar/AndroidStudioProjects/riri/docs/antigravity.md).

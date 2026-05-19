# Riri: Gen Z Taglish Reminder App

Riri is a lifestyle and reminder companion designed with an offline-first, on-device architecture. It addresses the procrastination crisis by replacing dry, mechanical notifications with personality-driven, witty Taglish (Tagalog-English mix) nudges tailored for modern users.

---

## The Problem
Generic productivity and calendar applications fail because their notifications are easily ignored. Users become desensitized to standard alerts like "Task due in 15 minutes." The friction of manual task scheduling and categorization further discourages users from keeping track of their daily goals.

## The Solution
Riri acts as an offline, reactive buddy that naggingly but lovingly keeps you on track.
* **On-Device Taglish Classifier**: Quickly schedules reminders through natural language inputs (e.g., *Remind me to buy coffee in 2 hours* or *Submit thesis kay Prof*).
* **Personality-Driven Copy**: Delivers alerts through four custom selectable modes:
  * **Bestie Mode**: Warm, supportive, and full of hype.
  * **Malupit Mode**: Tough love, dry humor, and absolute zero tolerance for slacking.
  * **Chill Mode**: Low-pressure, calming, relaxed vibes.
  * **Tita Mode**: Caring, maternal nagging, and traditional protective wisdom.
* **Reactive UI States**: Riri's character expressions (wink, angry, confident, celebratory) update dynamically based on your performance, task completion streak, and overdue counts.

---

## Technology Stack

The application has been migrated to a highly performant **cross-platform Flutter** codebase:

1. **Framework**: Flutter (Dart 3) for clean, native-speed UI layouts.
2. **State Management**: Riverpod for reactive state orchestration and data flow.
3. **Database (Offline-First)**: Drift SQLite for local caching, ensuring 100% functionality without internet.
4. **NLP Classifier**: Highly optimized Taglish heuristic natural language processor for fast local scheduling.
5. **Aesthetics**: Curated HSL dark palette (`#1A1A2E` background, `#7C5CBF` primary purple, `#F5A623` accent amber) with Outfit and Inter Google Fonts.

---

## Repository Structure

```
riri/
├── riri_flutter/              # Primary cross-platform codebase
│   ├── lib/
│   │   ├── core/
│   │   │   ├── ai/            # Natural language classifiers & AI routing
│   │   │   ├── notifications/ # Personality mode copy templates
│   │   │   └── persistence/   # Drift SQLite tables & data repositories
│   │   ├── theme/             # HSL-derived color tokens & typography
│   │   ├── features/
│   │   │   ├── onboarding/    # Interactive user onboarding
│   │   │   ├── dashboard/     # Dynamic tasks, stickers, and status indicators
│   │   │   ├── chat/          # Intelligent conversational assistant interface
│   │   │   ├── settings/      # Personality & notification controls
│   │   │   └── reminders/     # Sliding add-reminder forms
│   │   └── main.dart          # App startup and root shell coordinator
│   └── test/                  # Verification and unit test suites
└── reaction_stickers/         # Source sticker graphics for dynamic states
```

---

## Key Features & UI Overview

### 🗓️ Status-Adaptive Dashboard
Riri watches your schedule in real time. The main dashboard houses a dynamic character status card that changes expressions based on task progress:
* **Overdue Tasks**: Riri displays a concerned/angry face and issues nagging reminders.
* **All Complete**: Celebrates with you using warm, supportive reactions.
* **Priority Borders**: Tasks are visually framed with distinct left-accent colors matching their urgency (Urgent, Completed, or Pending).

### 💬 Interactive Chat Assistant
Chat directly with Riri to talk about your day or configure tasks. The integrated offline conversational engine:
* Automatically detects when you want to schedule a task from your sentences.
* Responds dynamically in Taglish using your active personality mode.

### ⚙️ Settings Panel
Easily switch between **Bestie**, **Malupit**, **Chill**, and **Tita** modes. Your choice instantly updates Riri's copywriting, dialogue, and UI expressions across the entire application.

---

## Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable release)
* Dart 3.x

### Quick Installation

1. Clone the repository and navigate to the project directory:
   ```bash
   git clone https://github.com/JaePyJs/riri.git
   cd riri/riri_flutter
   ```

2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```

3. Run automated tests to verify the classifier and data layers:
   ```bash
   flutter test
   ```

4. Launch the application on your connected emulator or hardware device:
   ```bash
   flutter run
   ```

---

## Developer Guidelines
* **Offline-First Policy**: All features, classifications, and messages must operate locally on the device.
* **Reactive State**: Always maintain proper isolation between UI components and the reactive data layer using repositories and Riverpod providers.

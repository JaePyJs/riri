---
description: "Use when working on the Riri Android app: offline-first Kotlin/Compose, on-device AI, Gen Z Taglish copy, and brand-specific UI constraints."
applyTo: ["**/*.kt", "**/*.kts", "**/*.xml", "**/*.gradle", "**/*.gradle.kts", "**/*.md"]
name: "Riri Project Protocol"
---

# Riri Project: Agentic Protocol & Context

- Project: Riri, a Filipino Gen Z reminder/lifestyle Android app. Offline-first, native Android.
- Tech stack: Kotlin, Jetpack Compose, Room (SQLite), WorkManager + AlarmManager, Canvas/Skia for card generation.
- AI core: Gemini Nano via Android AICore API. Strictly on-device for core features.

## Engineering Constraints

- Use ViewModels with StateFlow and reactive UI observation.
- Keep all reminder logic, Taglish NLP parsing, and procrastination pattern detection local.
- Ensure WorkManager and AlarmManager are resilient to Doze mode and process death.
- Optimize Canvas rendering for Chaos Report; avoid memory leaks when handling PNG/SVG sticker assets in Compose.

## Branding & UI Guidelines

- Dark mode default. Background #1A1A2E, text #F0F0F0.
- Accents: primary #7C5CBF, secondary #F5A623.
- Gradients: Pink #FF6B9D to Purple #7C5CBF.
- Character expressions map cleanly to app states (21 assets total).

## Copywriting & Domain Lingo

- Use Taglish for UI text, notifications, and AI outputs.
- Tone: Gen Z, witty, supportive best friend.
- Support text variations for Bestie (default), Tita (tough love), Chill (low pressure), Malupit (maximum roast).
- Avoid sterile copy like "Task Overdue". Use dynamic, expressive lines.

## Standard Development Directives

- Zero-BS: high-signal output only; no filler or apologies.
- Defensive Android: handle configuration changes, lifecycle events, and missing permissions before happy-path UI.
- Use MCP tools for local indexing and Android docs when implementing AICore or complex UI.

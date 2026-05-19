# Riri Flutter Source Directory

This directory holds the primary source code of the **Riri** Flutter client.

---

## Directory Modules

### `core/`
Holds reusable cross-feature resources and system infrastructure:
- **`ai/`**: Heuristics keyword parser and local LLM routers.
- **`notifications/`**: Persona configurations, templates, and alarm schedules.
- **`persistence/`**: SQLite Drift ORM database schemas (`riri_database.dart`) and the central `RiriRepository`.

### `features/`
Holds standalone product screens. Features are entirely decoupled from direct SQLite commands and only interact via repository data streams:
- `onboarding/`: Nickname select & onboarding setup.
- `dashboard/`: Dynamic user reminder list and reactive sticker card.
- `chat/`: Dynamic chat tab to converse in Taglish with Riri.
- `settings/`: Personality profile picker and system options.
- `reminders/`: Bottom sheets to add tasks.

### `theme/`
- `riri_theme.dart`: Design system parameters (color tokens, Outfit/Inter google font layouts, unified Material 3 input decorations).

---

## Database Code Generation

When you modify table schemas inside `lib/core/persistence/riri_database.dart`, you must compile the Drift files by running:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

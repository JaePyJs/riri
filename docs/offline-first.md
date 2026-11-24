# Riri Offline-First Principles

Riri stores reminders and chat history locally and can propose reminders using on-device rules. If you add a Gemini API key in Settings, Riri sends your current chat message, nickname, and recent chat context to Google to generate a reply. If the request fails or no key is configured, Riri uses its local rules.

---

## Architectural Guidelines

To maintain these strict guidelines, all developers and AI agents must follow these rules:

### 1. Zero Direct Network Dependency inside Features
- Under no circumstances should feature screen widgets (`lib/features/`) import or execute direct HTTP, Dio, or WebSocket requests.
- All dynamic data reads must stream reactively from local sqlite persistence wrappers inside `lib/core/persistence/`.

### 2. Local Database Sovereignty
- All persistent entities (Reminders, ChatLogs) must map directly to tables defined in the Drift reactive SQLite schema (`lib/core/persistence/riri_database.dart`).
- Data flows out from the database via Streams (`watchAllReminders()`), ensuring any local table modification instantly reflects across the app without manual refresh actions.

### 3. Asynchronous Cache Persistence
- User settings (active Persona, notification flags, onboarding completes) are persisted locally using the non-blocking `SharedPreferencesAsync` API.
- Synchronous blockages (`SharedPreferences.getInstance()`) are banned at runtime to prevent micro-jank and main-thread stutter.

### 4. Code Parity Checklist
Before shipping any feature expansion, confirm:
- `[ ]` No `http`, `dio`, or cloud-sync client libraries are imported in feature code.
- `[ ]` All model CRUD modifications are performed through `RiriRepository`.
- `[ ]` SQLite schemas are updated and regenerated cleanly via Drift build runner (`flutter pub run build_runner build`).

# Riri Offline-First Principles

Riri is designed as an **offline-first application**. It ensures that no personal user data (chat logs, reminders, configuration schedules) ever leaves the local device, ensuring maximum privacy, zero network latency, and continuous survivability.

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

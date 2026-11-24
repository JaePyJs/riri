# Riri

Riri is a Taglish reminder and chat app for Filipino Gen Z users. It pairs a task dashboard with a chat companion that can turn an everyday message into a reminder you can review and save.

## Try Riri locally

The active app is [riri_flutter](riri_flutter/). This checkout includes a web runner. Use [Flutter 3.47.4](https://docs.flutter.dev/install/archive) and Chrome. Flutter 3.50.1 hits a dependency resolution conflict with this checkout.

```sh
cd riri_flutter
flutter pub get
flutter run -d chrome
```

1. Finish onboarding and open **Riri Chat**. For the local chat flow, leave the Gemini API key blank in **Settings**.
2. Send `Remind me to buy coffee in 2 hours` or `Paalala mo thesis draft pagkalipas ng 30 minuto`.
3. Review the proposed title and due time on the reminder card. Use its save button, then find the reminder in **Dashboard**.

Choose Bestie (Barkada), Malupit, Chill, or Tita in **Settings** to change Riri’s tone. The dashboard changes its sticker and nudge as your task status changes. [Persona guide](docs/personas.md)

## How it works

- Flutter renders the interface and Riverpod connects screens to app state.
- Drift and SQLite store reminders and chat messages locally. On the web, Drift uses the bundled SQLite WebAssembly and worker files.
- Local rules propose reminder titles and due times without an API key. Use `in` or `pagkalipas ng` followed by a positive whole number and a unit such as `minutes`, `hours`, `minuto`, or `oras`. Optional Gemini chat sends the current message and recent chat context to Google when configured. [Offline-first guide](docs/offline-first.md)

## Development

Run `flutter test` from `riri_flutter/`. Drift’s generated Dart files are checked in. Regenerate them when editing the schema. [Source layout and code generation](riri_flutter/lib/README.md) · [Architecture](docs/architecture.md)

Riri began as a Kotlin and Jetpack Compose Android app. The [Flutter migration](https://github.com/JaePyJs/riri/commit/807556a7426f07ab637315b49c534838ca541663) and [removal of the archived Android source](https://github.com/JaePyJs/riri/commit/f54057143d852abb1217905756290ff34ca12362) are recorded in Git history.

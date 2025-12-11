<!-- GitHub Copilot Instructions for AI coding agents (kasir_go) -->

# Quick Context

This repository is a Flutter application (root entry `lib/main.dart`). It's a standard multi-platform Flutter project with platform folders: `android/`, `ios/`, `windows/`, `macos/`, `linux/`, and `web/`. Dependencies and SDK constraints are declared in `pubspec.yaml`.

# What to prioritize

- Make minimal, focused edits — this repo uses the default Flutter starter template. Preserve platform-specific folders and `pubspec.yaml` unless explicitly changing dependencies.
- Entry point: `lib/main.dart`. UI and navigation are likely in `lib/` (currently starter app).
- Tests: unit/widget tests live under `test/` (see `test/widget_test.dart`). Run `flutter test` to validate.

# Local build & debug commands (PowerShell)

Use the Flutter toolchain already referenced by the project. Common commands:

```
flutter pub get;                        # fetch deps
flutter run -d windows;                 # run on Windows desktop
flutter run -d chrome;                  # run web in Chrome
flutter run -d emulator-5554;           # run on Android emulator
flutter build apk;                      # build Android APK
flutter build windows;                  # build Windows executable
flutter test;                           # run tests
```

Notes:
- On Windows you can also call Gradle directly for Android builds: `cd android; .\gradlew.bat assembleDebug`.
- Use `r` in the terminal for hot reload when running via `flutter run`. Use hot restart to reset state.

# Project-specific conventions & patterns

- Material 3 is enabled in `lib/main.dart` (`useMaterial3: true`) and the `ColorScheme.fromSeed` pattern is used for theming.
- Lints: `flutter_lints` is configured in `pubspec.yaml`; follow its suggestions when editing code.
- Assets: none declared in `pubspec.yaml` (check `flutter:` section before adding assets). If you add assets, update `pubspec.yaml` and run `flutter pub get`.

# Integration points & important files

- `pubspec.yaml`: dependency and SDK constraint source of truth.
- `lib/main.dart`: app entry; most PRs will touch `lib/` files.
- `android/` and `ios/`: native platform build wrappers; avoid changing unless you know native build implications.
- `build/` and `flutter_assets/` are generated — do not edit directly.

# Editing guidance for AI agents

- Keep changes narrowly scoped; prefer edits in `lib/` and `test/` unless asked to modify platform code.
- When changing dependencies, update `pubspec.yaml` and ensure `flutter pub get` succeeds. Prefer minimal version bumps.
- Follow lints; keep Flutter idioms (use `setState`, Provider/Bloc etc. only if the repo already uses them). There are no state-management libraries currently declared.
- For UI examples reference `lib/main.dart` (counter example) for layout, `Scaffold`, `AppBar`, `Column`, and `FloatingActionButton` usage.

# Example PR checklist for small changes

- Run `flutter analyze` and fix obvious analyzer warnings.
- Run `flutter test` and ensure tests pass.
- Update `pubspec.yaml` only if required and run `flutter pub get`.
- Do not modify generated files under `build/` or platform-generated files without explicit reason.

# When you need more context

- Ask the repository owner for target devices (which platforms to prioritize) and any required external services (APIs, databases) — none are declared in the codebase.
- If adding significant architecture (state management, backend integration), propose a short RFC and include files to change.

---
If anything here is unclear or you want me to emphasize other workflows (CI, release steps, or platform-specific build quirks), tell me what to expand and I will iterate.

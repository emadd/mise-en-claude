# Stack: flutter  — Flutter (Dart)

- **detect:** `pubspec.yaml`; `lib/main.dart`; `.dart` sources; `analysis_options.yaml`; `ios/` +
  `android/` runner dirs.
- **structure:** `lib/` organized by feature (`feature/{ui,data,domain}`) or layered; `test/`
  mirrors `lib/`. Keep widgets small and dumb; push logic into your state layer. Enable the
  recommended lints in `analysis_options.yaml` (`flutter_lints`).
- **gitignore:** `build/`, `.dart_tool/`, `.flutter-plugins`, `.flutter-plugins-dependencies`,
  `.idea/`, `*.iml`, `ios/Pods/`, `ios/.symlinks/`, `.env*` (keep `.env.example`), `.DS_Store`.
  **`pubspec.lock`:** commit it for an app, gitignore it for a reusable package. Never commit
  signing keys.
- **connectors:** the backend / Firebase / API if used.
- **cli_tools:** `gh`; the `flutter` and `dart` CLIs; CocoaPods (iOS); the platform toolchains
  (Xcode for iOS, Android SDK). **iOS/macOS builds need a Mac** — local-only step.
- **skills:** `/mise-cook`, `/mise-handoff`, `/mise-clean`.
- **claude_md_notes:** the **state-management choice** (Riverpod / Bloc / Provider — pick one and
  say which, it shapes everything); routing (`go_router`?); platform-channel usage for native;
  target platforms (iOS / Android / web / desktop); the `flutter run` / `flutter test` commands;
  the `pubspec.lock` commit policy.
- **first_command:** `flutter run` (or `flutter test`).

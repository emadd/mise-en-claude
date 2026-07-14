# Stack: react-native  — React Native (Expo or bare)

- **detect:** `package.json` with `react-native` (and/or `expo`); a `metro.config.js`; either
  `app.json` / `app.config.*` (Expo) **or** `ios/` + `android/` native project dirs (bare).
- **⚠️ The first thing to establish: Expo (managed) vs bare.** It changes almost everything —
  build system, native-module access, how you run the app, CI. Detect it and put it at the top of
  the `CLAUDE.md`; a fresh session guessing wrong will fight the toolchain.
- **structure:** `src/` with `screens/`, `components/`, `navigation/`, `hooks/`, `lib/`.
  TypeScript with `strict`. Keep native-touching code isolated behind a thin module.
- **gitignore:** `node_modules/`, `.expo/`, `ios/Pods/`, `ios/build/`, `android/build/`,
  `android/app/build/`, `android/.gradle/`, `*.jsbundle`, `.env*` (keep `.env.example`),
  `.DS_Store`. **Never commit signing keys / keystores or a real `.env`.**
- **connectors:** none typically; the backend/API if there is one; EAS if Expo.
- **cli_tools:** `gh`; the package manager; the **Expo CLI** (`npx expo`) or **RN CLI**
  (`npx react-native`); CocoaPods (bare iOS); the Android SDK + an emulator. **iOS builds need a
  Mac with Xcode** — flag this as a local-only step (the `/mise-cook` local-first rule).
- **skills:** `/mise-cook`, `/mise-handoff`, `/mise-clean`.
- **claude_md_notes:** **Expo vs bare** (lead with it); navigation lib (React Navigation / Expo
  Router); state approach; native-module boundaries; which platforms build **locally** (iOS →
  Mac + Xcode; Android → SDK); EAS Build if Expo; the per-platform run commands.
- **first_command:** `npx expo start` (Expo) or `npx react-native start` then `run-ios` /
  `run-android` (bare).

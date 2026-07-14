# Stack: ios-swiftui  — iOS / iPadOS / macOS (the fleshed-out flagship)

- **detect:** `*.xcodeproj` / `*.xcworkspace`, `Package.swift`, `.swift` sources, `Info.plist`,
  `Assets.xcassets`.
- **structure:** a clear split of Models / Services / Views; push business rules into services,
  keep view files small. Where it pays off, put the UI-agnostic core in a **local Swift package**
  so the app, its tests, and any extensions (widgets, share, Watch) link one shared layer. Tests
  in their own target.
- **gitignore:** `DerivedData/`, `build/`, `.build/` (SPM), `*.xcuserstate`, `xcuserdata/`,
  `.DS_Store`, `*.ipa`, `*.dSYM.zip`. **Never** commit signing certs, provisioning profiles, or
  API keys — surface them for a config/secret store. **`project.pbxproj`:** if the project is
  hand-managed (plain Xcode), **track it** — it's the project's source of truth, and ignoring it
  orphans the project. If a generator owns it (XcodeGen `project.yml`, Tuist), ignore the generated
  `*.xcodeproj` and track the generator's config instead.
- **connectors:** usually none beyond `gh` — the toolchain is local.
- **cli_tools:** `gh`; `xcodebuild` / `xcrun` (ship with Xcode); `swift` (SPM); optionally
  `xcbeautify` (readable logs), `swiftlint` / `swift-format` (style).
- **skills:** `/mise-cook`, `/mise-handoff`, `/mise-clean`.
- **claude_md_notes:** the model layer + persistence approach (SwiftData / Core Data / CloudKit,
  and any sync rules), the build/test invocation (scheme + destination), deployment targets, and
  any schema-migration cautions — what a fresh session must know before editing.
- **first_command:** build-and-test the scheme on a simulator, or run the app:
  `xcodebuild -scheme <App> -destination 'platform=iOS Simulator,name=<device>' build test`.

Notes: iPadOS and macOS are the same multiplatform SwiftUI stack — flag Catalyst / multiplatform
targets in the `CLAUDE.md`. This is mise's **reference stack**; keep it the most complete.

**Automation (drive it yourself):** build, run, and test via `xcodebuild` / `xcrun` / `swift` in
*your* shell — never tell the user to open Xcode and hit Run, and never hand them terminal commands
to paste. The irreducibly-manual Apple steps to hand off (and name for them): loading a plugin
(**Audio Unit / AUv3**) into its host to actually hear it (**Logic Pro**, GarageBand, a DAW),
on-device runs + code signing, permission prompts, and Instruments profiling. Automate everything
else. (macOS audio-plugin / Audio Unit work lives under this stack until it gets its own module.)

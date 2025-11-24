<!-- Copilot / AI agent instructions for the Journey Flutter app -->
# Copilot instructions — Journey (Flutter)

Purpose: quickly orient AI coding agents to this repository so they can make high-quality, low-risk changes.

1) Big picture
- **Type:** Flutter mobile app (multi-platform: Android, iOS, web, Windows, macOS, Linux).
- **Root app entry:** `lib/main.dart` — sets up a `ChangeNotifierProvider` for `ThemeProvider` and launches `LoginScreen`.
- **Key folders:**
  - `lib/screens/` — UI screens (e.g., `login_screen.dart`, `home_screen.dart`, `profile_screen.dart`).
  - `lib/authentication/` — HTTP-based auth helpers (`authentication.dart` uses `http` + `flutter_secure_storage`).
  - `lib/providers/` — app-wide providers (e.g., `theme_provider.dart` uses `shared_preferences`).
  - `assets/` — images and fonts referenced from `pubspec.yaml`.

2) Architecture & conventions to preserve
- **State management:** `provider` package + `ChangeNotifier` classes (see `ThemeProvider`). Avoid introducing other global state systems unless necessary.
- **Navigation pattern:** screens use `Navigator.push` and custom `PageRouteBuilder` (slide transitions). Follow existing transition style in `lib/screens/login_screen.dart`.
- **Assets & fonts:** Declared in `pubspec.yaml`. Example fonts: `OCR A Extended` and `Itim` — note there is an inconsistent font-family string used in `login_screen.dart` (`'OCR Extended A'`) vs `pubspec.yaml` (`'OCR A Extended'`) — prefer matching the `pubspec.yaml` name when adding fonts or changing references.
- **Network/backend integration:** `lib/authentication/authentication.dart` targets a local backend at `localhost:5000` (uses `10.0.2.2` for Android emulator and `127.0.0.1` for web). Any backend changes must respect these host mappings and platform checks.

3) External integrations & important deps (from `pubspec.yaml`)
- `supabase_flutter` — present in deps (may be used in parts of the app or planned integrations).
- `google_sign_in`, `google_fonts`, `provider`, `shared_preferences`, `flutter_secure_storage`, `video_player`, `fl_chart`, `http`, `image_picker`, `share_plus`.

4) Build / run / test workflows (practical commands)
- Get dependencies:
  - `flutter pub get`
- Run app (preferred):
  - Mobile (connected device or emulator): `flutter run -d <device-id>`
  - Windows desktop: `flutter run -d windows`
- Build artifacts:
  - Android APK: `flutter build apk`
  - iOS: `flutter build ios` (use Xcode for provisioning/signing)
  - Windows (msix/app): `flutter build windows`
- Run tests: `flutter test`
- Android-specific Gradle (Windows PowerShell):
  - `cd android; .\gradlew.bat assembleDebug`

5) Project-specific gotchas & notes for agents
- **Local backend expectation:** `AuthService` uses HTTP endpoints at `/api/auth` on port `5000`. When modifying auth flows, ensure backend URL logic in `authentication.dart` remains correct for Android emulators (`10.0.2.2`) and web (`127.0.0.1`). If you introduce env-based configuration, document it and avoid breaking the existing hard-coded fallbacks.
- **Storage patterns:** short-lived tokens and secure secrets use `flutter_secure_storage`. Non-sensitive preferences use `shared_preferences` (see `ThemeProvider`). Don't substitute storage types without a migration plan.
- **UI conventions:** Many screens use full-screen background images (assets under `assets/images/*`) and specific color constants. Maintain visual layout approach when adding screens.
- **Font name mismatch:** If you update fonts, fix both `pubspec.yaml` and string references in UI files to the same family name.

6) Helpful file examples (copyable snippets)
- Theme provider: `lib/providers/theme_provider.dart` — uses `SharedPreferences` and `ThemeMode` names; prefer `mode.name` when persisting.
- Auth host selection (platform-aware): `lib/authentication/authentication.dart` — uses `kIsWeb` and `defaultTargetPlatform` to select host string (localhost vs `10.0.2.2`).

7) When creating PRs
- Keep changes small and self-contained. For UI changes, include screenshots or a short demo command that reproduces the view.
- If changing network endpoints or auth flows, update `README.md` and add a short `docs/` note explaining local backend setup (port, endpoints, emulator mapping).

8) Safety & risk guidelines
- Avoid broad refactors of state management (e.g., switch from `provider` to Redux) in a single PR — break into small migrations.
- When adding platform-specific code, test on at least one mobile platform and one desktop/web if applicable.

9) If you need more context
- Look at these files first:
  - `lib/main.dart` (app bootstrap)
  - `lib/providers/theme_provider.dart` (state persistence pattern)
  - `lib/authentication/authentication.dart` (backend mapping + secure storage)
  - `lib/screens/login_screen.dart` (navigation/transition example)
  - `pubspec.yaml` (dependencies, assets, fonts)

---
If any section is unclear or you want me to expand examples (e.g., add suggested environment variable support or a small backend README), tell me which part to iterate on.

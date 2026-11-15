# EchoStream Autonomous Sprint Framework (GEMINI Engine)

## 6-Phase Autonomous Sprint Protocol

### Phase 1: Architecture & Environment Integrity
- Enforce Feature-First Clean Architecture (`core/`, `domain/`, `data/`, `presentation/`).
- Android SDK 36: Explicitly maintain `compileSdk = 36`, `targetSdk = 36`, and `minSdk = 21`.
- Impeller Vulkan crash defense: Keep `io.flutter.embedding.android.EnableImpeller = false` on Android.
- Cross-SDK analyzer stability: Keep `deprecated_member_use: ignore` in `analysis_options.yaml`.

### Phase 2: Core Domain & Data Resilience
- Domain entities must remain pure, immutable Dart classes using `equatable`.
- Data persistence through `sqflite` (`AppDatabase`) and `SharedPreferences` without external paid APIs.
- Zero-cost determinism: Seed catalog with rich fixtures and realistic audio chapters.

### Phase 3: BLoC State Machines & Native Platform Bridge
- Primary state management must utilize `flutter_bloc` (`Bloc` and `Cubit`).
- Platform channels (`MethodChannel` and `EventChannel`) must have mirrored Kotlin and Swift native handlers.
- All asynchronous streams and token emitters must guarantee cleanup inside `try ... finally` blocks.

### Phase 4: UI/UX & Adaptive Ergonomics
- Zero hardcoded colors: Derive all colors dynamically via `Theme.of(context).colorScheme`.
- Unique Hero tags: Every `FloatingActionButton` must have an explicit, unique string `heroTag`.
- 360dp landscape safety: Use compact `NavigationRail` (minWidth 56dp) wrapped in `SingleChildScrollView` + `IntrinsicHeight`.
- Compressed landscape app bar: Set `toolbarHeight: 36.0` on landscape AppBar.
- Explicit grid extents: Grids must specify `mainAxisExtent` to prevent RenderFlex overflow.
- Docked keyboard safety: Chat and input sheets must dock against software keyboard cleanly.

### Phase 5: Automated Testing & Gate Verification
- Automated test suite must cover unit logic, state emissions, Hero safety, landscape render, and theme switching.
- Gate execution via `dart run tool/sprint_gate.dart`.
- Zero analyzer warnings or errors with `flutter analyze --no-fatal-infos`.

### Phase 6: CI/CD & Git Hygiene
- Zero emojis anywhere in source code, strings, logs, or commit messages.
- GitHub Actions CI workflow in `.github/workflows/ci.yml`.
- Conventional commit messaging format (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`).

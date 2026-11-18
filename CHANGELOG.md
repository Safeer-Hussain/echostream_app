# Changelog

All notable changes to the EchoStream audio platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1+2] - 2026-11-18

### Added
- Sprint 26: A/B Repeat Loop Engine in `AudioPlayerBloc` with `LoopMode.off`, `LoopMode.track`, and `LoopMode.abRepeat`.
- Interactive A-B loop marker controls in `SpatialPlayerDeckView` with Point A, Point B, and Clear triggers.
- Active loop duration pill indicator under playback scrubber with dynamic color mapping.
- 3 new unit tests in `audio_player_bloc_test.dart` validating mode cycling, marker setting, and boundary tick looping.
- Automated release workflow in `.github/workflows/release.yml` for automated APK artifact packaging.

### Changed
- Enhanced scrubber slider styling to dynamically tint with secondary accent when A-B looping is active.
- Updated automated sprint test suite to 24 test cases with 100% pass rate.

## [1.0.0+1] - 2026-11-15

### Added
- Initial release of EchoStream Lossless Spatial Audio Streaming Platform.
- Native 10-Band Hardware DSP Equalizer Bridge for Android Kotlin and iOS Swift.
- Real-time 32-band FFT Spectrum Analyzer with 60fps CustomPainter visualizer.
- Live Interactive Audio Room Studio with speaker roster, hand-raising, and reactions.
- Offline Media Vault with SQLite storage allocation and custom playlist manager.
- On-Device AI Transcript Copilot with streaming token processing.
- Adaptive ergonomics with 360dp landscape-safe NavigationRail and 36dp toolbar.
- Automated sprint gate verification script (`tool/sprint_gate.dart`).
- GitHub Actions CI/CD pipeline (`.github/workflows/ci.yml`).

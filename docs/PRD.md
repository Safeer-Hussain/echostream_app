# EchoStream Product Requirements Document (PRD)

## 1. Executive Summary & Vision
EchoStream is an enterprise-grade, high-fidelity spatial audio streaming platform and live interactive audio broadcast studio built in Flutter. Designed for audiophiles, sound designers, engineers, and podcast creators, EchoStream delivers bit-perfect 192kHz / 24-bit FLAC audio streaming, live 32-band FFT spectrum visualization, hardware-level DSP equalization, collaborative live audio stages, local offline media vault storage via SQLite, and an on-device AI copilot for contextual transcript analysis.

---

## 2. Target Personas & Core User Journeys
1. **Audiophile & Acoustic Engineer:**
   - Desires bit-perfect DAC pass-through, customizable 10-band hardware DSP equalization (+12dB to -12dB), real-time 32-band FFT audio spectrum analysis, and dynamic range verification.
2. **Interactive Audio Host & Listener:**
   - Hosts and participates in live audio rooms with real-time speaker promotion, audience hand-raising, backchannel discussion, and low-latency audience reactions.
3. **Commuter & Offline Power User:**
   - Downloads lossless albums and podcast episodes into an offline vault with local SQLite persistence and deterministic offline playback.
4. **Researcher & Power Listener:**
   - Leverages an on-device AI copilot to query podcast transcripts, extract timestamps, summarize complex architectural discussions, and generate key takeaways.

---

## 3. System Architecture & Component Design

### 3.1 Feature-First Clean Architecture
- **Core Layer (`lib/core/`):**
  - Design system with Dark/Light theme parity (`AppTheme`, `AppColors`).
  - Native platform channels (`AudioDspBridge`) for MethodChannel and EventChannel communication.
  - Network resilience via `MockDioInterceptor` supporting latency simulation and offline detection.
  - Dependency Injection via `ServiceLocator` (`get_it`).
  - Unified user notifications (`AppFeedback`).
- **Domain Layer (`lib/domain/`):**
  - Pure Dart immutable entities (`AudioTrack`, `TranscriptChapter`, `TimestampClip`, `LiveRoom`, `DspPreset`, `SpectrumData`, `UserProfile`).
  - Abstract repository interfaces (`AudioRepository`, `LiveRoomRepository`, `DspRepository`, `AnalyticsRepository`).
- **Data Layer (`lib/data/`):**
  - Local SQLite persistence engine (`AppDatabase`) managing 7 relational tables with automatic schema migrations and indexing.
  - Repository implementations reading from local SQLite storage and persistent `SharedPreferences`.
  - Comprehensive seed catalog (`MockAudioCatalog`) providing 24 lossless audio tracks and synchronized chapters.
- **Presentation Layer (`lib/presentation/`):**
  - State management powered by `flutter_bloc` (`Bloc` and `Cubit`).
  - Adaptive layout (`AdaptiveScaffold`) switching between compact portrait navigation and 360dp landscape `NavigationRail`.
  - High-performance CustomPainters (`FftSpectrumPainter`, `FrequencyCurvePainter`) optimized for 60fps rendering with repaint boundaries.

---

## 4. Key Functional Modules

### 4.1 Lossless Spatial Audio Engine
- **Playback Capabilities:** Play, pause, seek, scrub, variable playback speeds (0.5x to 2.5x), track queue management, and deterministic clock ticks.
- **Timestamp Clipping:** Allows listeners to bookmark key audio moments with notes and persist clips to SQLite.
- **Spatial Audio & Bit-Perfect Mode:** MethodChannel toggle for 3D HRTF spatial rendering and DAC direct-stream passthrough.

### 4.2 Native 10-Band Hardware DSP Equalizer Bridge
- **Frequency Bands:** 31Hz, 63Hz, 125Hz, 250Hz, 500Hz, 1kHz, 2kHz, 4kHz, 8kHz, 16kHz.
- **Presets:** Flat Reference, Club Bass Boost, Vocal Master, Spatial Acoustic, Treble Air, Warm Vinyl, and Custom User Presets.
- **Real-Time FFT Spectrum Bridge:** Streams 32 frequency magnitude bins, peak dBFS loudness, sample rate, dynamic range, and buffer latency via platform `EventChannel`.

### 4.3 Live Interactive Podcast & Audio Room Studio
- **Audio Stages:** Dynamic speaker roster, listeners gallery, role management (Host, Speaker, Listener).
- **Interactive Protocols:** One-tap Hand Raising promoting listeners to speakers stage, real-time backchannel messaging, and reaction counters (Clap, Heart, Fire, Mindblown).

### 4.4 Offline Media Vault & Storage Manager
- **Storage Tracking:** Real-time calculation of offline storage utilization across lossless tracks, cache, and system data.
- **Playlist Management:** Custom user-defined playlist creation with track associations stored in SQLite.
- **Offline Mode:** Seamless fallback when network connectivity is lost, reading cached tracks directly from local disk/database.

### 4.5 On-Device AI Transcript Copilot
- **Interactive Assistant:** Conversational query engine over podcast and track transcripts.
- **Quick Action Chips:** Pre-built prompts for summary extraction, key insights, speaker highlights, and actionable takeaways.
- **Streaming Guardrails:** Deterministic token streaming wrapped in defensive `try ... finally` blocks ensuring non-blocking UI states.

---

## 5. Non-Functional & Reliability Requirements
1. **Zero Hardcoded Colors:** All UI elements dynamically resolve through `Theme.of(context).colorScheme` with full dark and light mode parity.
2. **Hero Tag Collision Prevention:** Every `FloatingActionButton` defines an explicit, unique `heroTag`.
3. **Landscape 360dp Viewport Safety:** NavigationRail width strictly constrained to 56dp with no text labels, app bar compressed to 36dp toolbar height, and grid cards with explicit `mainAxisExtent`.
4. **Keyboard Safety:** Modal sheets and copilot text fields utilize keyboard insets defensively to prevent obscuring or overflow.
5. **Deterministic Testing:** 100% passing automated test suite covering unit, BLoC, and widget integration cases.

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/audio_track.dart';
import '../../../domain/entities/spectrum_data.dart';
import '../../../domain/entities/timestamp_clip.dart';
import '../../../domain/entities/transcript_chapter.dart';
import '../../../domain/repositories/audio_repository.dart';
import '../../../domain/repositories/dsp_repository.dart';

// Events
abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();
  @override
  List<Object?> get props => [];
}

enum LoopMode { off, track, abRepeat }

class LoadTrackEvent extends AudioPlayerEvent {
  final AudioTrack track;
  final bool autoPlay;
  const LoadTrackEvent(this.track, {this.autoPlay = true});
  @override
  List<Object?> get props => [track, autoPlay];
}

class TogglePlayPauseEvent extends AudioPlayerEvent {}

class SeekPositionEvent extends AudioPlayerEvent {
  final int positionSec;
  const SeekPositionEvent(this.positionSec);
  @override
  List<Object?> get props => [positionSec];
}

class SkipForwardEvent extends AudioPlayerEvent {
  final int seconds;
  const SkipForwardEvent({this.seconds = 30});
  @override
  List<Object?> get props => [seconds];
}

class SkipBackwardEvent extends AudioPlayerEvent {
  final int seconds;
  const SkipBackwardEvent({this.seconds = 15});
  @override
  List<Object?> get props => [seconds];
}

class SetPlaybackSpeedEvent extends AudioPlayerEvent {
  final double speed;
  const SetPlaybackSpeedEvent(this.speed);
  @override
  List<Object?> get props => [speed];
}

class ToggleLikeCurrentTrackEvent extends AudioPlayerEvent {}

class SaveTimestampClipEvent extends AudioPlayerEvent {
  final String note;
  const SaveTimestampClipEvent(this.note);
  @override
  List<Object?> get props => [note];
}

class SpectrumUpdateEvent extends AudioPlayerEvent {
  final SpectrumData spectrum;
  const SpectrumUpdateEvent(this.spectrum);
  @override
  List<Object?> get props => [spectrum];
}

class TickerTickEvent extends AudioPlayerEvent {}

class CycleLoopModeEvent extends AudioPlayerEvent {}

class SetAbLoopPointAEvent extends AudioPlayerEvent {
  final int? posSec;
  const SetAbLoopPointAEvent([this.posSec]);
  @override
  List<Object?> get props => [posSec];
}

class SetAbLoopPointBEvent extends AudioPlayerEvent {
  final int? posSec;
  const SetAbLoopPointBEvent([this.posSec]);
  @override
  List<Object?> get props => [posSec];
}

class ClearAbLoopEvent extends AudioPlayerEvent {}

// State
class AudioPlayerState extends Equatable {
  final AudioTrack? currentTrack;
  final bool isPlaying;
  final int currentPositionSec;
  final double playbackSpeed;
  final SpectrumData spectrum;
  final List<AudioTrack> queue;
  final int queueIndex;
  final String? lastSavedClipId;
  final LoopMode loopMode;
  final int? abLoopStartSec;
  final int? abLoopEndSec;

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.currentPositionSec = 0,
    this.playbackSpeed = 1.0,
    required this.spectrum,
    this.queue = const [],
    this.queueIndex = 0,
    this.lastSavedClipId,
    this.loopMode = LoopMode.off,
    this.abLoopStartSec,
    this.abLoopEndSec,
  });

  bool get isAbLoopValid =>
      abLoopStartSec != null &&
      abLoopEndSec != null &&
      abLoopStartSec! < abLoopEndSec!;

  TranscriptChapter? get activeChapter {
    if (currentTrack == null || currentTrack!.chapters.isEmpty) return null;
    for (final chapter in currentTrack!.chapters) {
      if (currentPositionSec >= chapter.startTimeSec &&
          currentPositionSec < chapter.endTimeSec) {
        return chapter;
      }
    }
    return currentTrack!.chapters.last;
  }

  AudioPlayerState copyWith({
    AudioTrack? currentTrack,
    bool? isPlaying,
    int? currentPositionSec,
    double? playbackSpeed,
    SpectrumData? spectrum,
    List<AudioTrack>? queue,
    int? queueIndex,
    String? lastSavedClipId,
    LoopMode? loopMode,
    int? abLoopStartSec,
    int? abLoopEndSec,
    bool clearAbLoop = false,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPositionSec: currentPositionSec ?? this.currentPositionSec,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      spectrum: spectrum ?? this.spectrum,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      lastSavedClipId: lastSavedClipId,
      loopMode: loopMode ?? this.loopMode,
      abLoopStartSec: clearAbLoop
          ? null
          : (abLoopStartSec ?? this.abLoopStartSec),
      abLoopEndSec: clearAbLoop ? null : (abLoopEndSec ?? this.abLoopEndSec),
    );
  }

  @override
  List<Object?> get props => [
    currentTrack,
    isPlaying,
    currentPositionSec,
    playbackSpeed,
    spectrum,
    queue,
    queueIndex,
    lastSavedClipId,
    loopMode,
    abLoopStartSec,
    abLoopEndSec,
  ];
}

// BLoC
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioRepository _audioRepository;
  final DspRepository _dspRepository;
  Timer? _tickerTimer;
  StreamSubscription<SpectrumData>? _spectrumSubscription;

  AudioPlayerBloc({
    required AudioRepository audioRepository,
    required DspRepository dspRepository,
  }) : _audioRepository = audioRepository,
       _dspRepository = dspRepository,
       super(AudioPlayerState(spectrum: SpectrumData.initial())) {
    on<LoadTrackEvent>(_onLoadTrack);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<SeekPositionEvent>(_onSeekPosition);
    on<SkipForwardEvent>(_onSkipForward);
    on<SkipBackwardEvent>(_onSkipBackward);
    on<SetPlaybackSpeedEvent>(_onSetPlaybackSpeed);
    on<ToggleLikeCurrentTrackEvent>(_onToggleLikeCurrentTrack);
    on<SaveTimestampClipEvent>(_onSaveTimestampClip);
    on<SpectrumUpdateEvent>(_onSpectrumUpdate);
    on<TickerTickEvent>(_onTickerTick);
    on<CycleLoopModeEvent>(_onCycleLoopMode);
    on<SetAbLoopPointAEvent>(_onSetAbLoopPointA);
    on<SetAbLoopPointBEvent>(_onSetAbLoopPointB);
    on<ClearAbLoopEvent>(_onClearAbLoop);

    _spectrumSubscription = _dspRepository.getSpectrumStream().listen((
      spectrum,
    ) {
      if (state.isPlaying) {
        add(SpectrumUpdateEvent(spectrum));
      }
    });
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TickerTickEvent());
    });
  }

  void _stopTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  Future<void> _onLoadTrack(
    LoadTrackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final track = event.track;
    emit(
      state.copyWith(
        currentTrack: track,
        currentPositionSec: track.playbackProgressSec,
        isPlaying: event.autoPlay,
      ),
    );

    if (event.autoPlay) {
      _startTicker();
    } else {
      _stopTicker();
    }
  }

  void _onTogglePlayPause(
    TogglePlayPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (state.currentTrack == null) return;
    final nextPlaying = !state.isPlaying;
    emit(state.copyWith(isPlaying: nextPlaying));

    if (nextPlaying) {
      _startTicker();
    } else {
      _stopTicker();
    }
  }

  void _onSeekPosition(
    SeekPositionEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (state.currentTrack == null) return;
    final clamped = event.positionSec.clamp(0, state.currentTrack!.durationSec);
    emit(state.copyWith(currentPositionSec: clamped));
    _audioRepository.updatePlaybackProgress(state.currentTrack!.id, clamped);
  }

  void _onSkipForward(SkipForwardEvent event, Emitter<AudioPlayerState> emit) {
    if (state.currentTrack == null) return;
    final target = (state.currentPositionSec + event.seconds).clamp(
      0,
      state.currentTrack!.durationSec,
    );
    emit(state.copyWith(currentPositionSec: target));
    _audioRepository.updatePlaybackProgress(state.currentTrack!.id, target);
  }

  void _onSkipBackward(
    SkipBackwardEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (state.currentTrack == null) return;
    final target = (state.currentPositionSec - event.seconds).clamp(
      0,
      state.currentTrack!.durationSec,
    );
    emit(state.copyWith(currentPositionSec: target));
    _audioRepository.updatePlaybackProgress(state.currentTrack!.id, target);
  }

  void _onSetPlaybackSpeed(
    SetPlaybackSpeedEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(playbackSpeed: event.speed));
  }

  Future<void> _onToggleLikeCurrentTrack(
    ToggleLikeCurrentTrackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state.currentTrack == null) return;
    final current = state.currentTrack!;
    final updated = current.copyWith(isLiked: !current.isLiked);
    emit(state.copyWith(currentTrack: updated));
    await _audioRepository.toggleLikeTrack(current.id);
  }

  Future<void> _onSaveTimestampClip(
    SaveTimestampClipEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state.currentTrack == null) return;
    final clip = TimestampClip(
      id: 'clip_${DateTime.now().millisecondsSinceEpoch}',
      trackId: state.currentTrack!.id,
      trackTitle: state.currentTrack!.title,
      timestampSec: state.currentPositionSec,
      noteText: event.note.trim().isEmpty
          ? 'Insight bookmark'
          : event.note.trim(),
      createdAt: DateTime.now()
          .toIso8601String()
          .substring(0, 16)
          .replaceAll('T', ' '),
    );
    await _audioRepository.saveTimestampClip(clip);
    emit(state.copyWith(lastSavedClipId: clip.id));
  }

  void _onSpectrumUpdate(
    SpectrumUpdateEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(spectrum: event.spectrum));
  }

  void _onTickerTick(TickerTickEvent event, Emitter<AudioPlayerState> emit) {
    if (!state.isPlaying || state.currentTrack == null) return;

    // Check A-B repeat boundary
    if (state.loopMode == LoopMode.abRepeat && state.isAbLoopValid) {
      final nextSec = state.currentPositionSec + 1;
      if (nextSec >= state.abLoopEndSec!) {
        emit(state.copyWith(currentPositionSec: state.abLoopStartSec!));
        return;
      }
    }

    final nextSec = state.currentPositionSec + 1;
    if (nextSec >= state.currentTrack!.durationSec) {
      if (state.loopMode == LoopMode.track) {
        emit(state.copyWith(currentPositionSec: 0));
      } else {
        emit(state.copyWith(isPlaying: false, currentPositionSec: 0));
        _stopTicker();
      }
    } else {
      emit(state.copyWith(currentPositionSec: nextSec));
      if (nextSec % 5 == 0) {
        _audioRepository.updatePlaybackProgress(
          state.currentTrack!.id,
          nextSec,
        );
      }
    }
  }

  void _onCycleLoopMode(
    CycleLoopModeEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    final nextMode = switch (state.loopMode) {
      LoopMode.off => LoopMode.track,
      LoopMode.track => LoopMode.abRepeat,
      LoopMode.abRepeat => LoopMode.off,
    };
    emit(state.copyWith(loopMode: nextMode));
  }

  void _onSetAbLoopPointA(
    SetAbLoopPointAEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    final pos = event.posSec ?? state.currentPositionSec;
    int? end = state.abLoopEndSec;
    if (end != null && pos >= end) {
      end = null;
    }
    emit(
      state.copyWith(
        abLoopStartSec: pos,
        abLoopEndSec: end,
        loopMode: LoopMode.abRepeat,
      ),
    );
  }

  void _onSetAbLoopPointB(
    SetAbLoopPointBEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    final pos = event.posSec ?? state.currentPositionSec;
    final start = state.abLoopStartSec ?? 0;
    if (pos <= start) return;
    emit(
      state.copyWith(
        abLoopStartSec: start,
        abLoopEndSec: pos,
        loopMode: LoopMode.abRepeat,
      ),
    );
  }

  void _onClearAbLoop(ClearAbLoopEvent event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(loopMode: LoopMode.off, clearAbLoop: true));
  }

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    _spectrumSubscription?.cancel();
    return super.close();
  }
}

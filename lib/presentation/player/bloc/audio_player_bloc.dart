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

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.currentPositionSec = 0,
    this.playbackSpeed = 1.0,
    required this.spectrum,
    this.queue = const [],
    this.queueIndex = 0,
    this.lastSavedClipId,
  });

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
    final nextSec = state.currentPositionSec + 1;
    if (nextSec >= state.currentTrack!.durationSec) {
      emit(state.copyWith(isPlaying: false, currentPositionSec: 0));
      _stopTicker();
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

  @override
  Future<void> close() {
    _tickerTimer?.cancel();
    _spectrumSubscription?.cancel();
    return super.close();
  }
}

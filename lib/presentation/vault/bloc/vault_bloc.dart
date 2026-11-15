import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/audio_track.dart';
import '../../../domain/entities/playlist.dart';
import '../../../domain/repositories/audio_repository.dart';

// Events
abstract class VaultEvent extends Equatable {
  const VaultEvent();
  @override
  List<Object?> get props => [];
}

class LoadVaultDataEvent extends VaultEvent {}

class StartDownloadTrackEvent extends VaultEvent {
  final AudioTrack track;
  const StartDownloadTrackEvent(this.track);
  @override
  List<Object?> get props => [track];
}

class DownloadProgressTickEvent extends VaultEvent {
  final String trackId;
  final double progress;
  const DownloadProgressTickEvent(this.trackId, this.progress);
  @override
  List<Object?> get props => [trackId, progress];
}

class PurgeCacheEvent extends VaultEvent {}

class CreatePlaylistEvent extends VaultEvent {
  final String title;
  final String description;
  const CreatePlaylistEvent({required this.title, required this.description});
  @override
  List<Object?> get props => [title, description];
}

class AddTrackToPlaylistEvent extends VaultEvent {
  final String playlistId;
  final String trackId;
  const AddTrackToPlaylistEvent(this.playlistId, this.trackId);
  @override
  List<Object?> get props => [playlistId, trackId];
}

class RemoveTrackFromPlaylistEvent extends VaultEvent {
  final String playlistId;
  final String trackId;
  const RemoveTrackFromPlaylistEvent(this.playlistId, this.trackId);
  @override
  List<Object?> get props => [playlistId, trackId];
}

// State
class VaultState extends Equatable {
  final List<AudioTrack> downloadedTracks;
  final List<Playlist> playlists;
  final Map<String, double> activeDownloads; // trackId -> progress 0.0 to 1.0
  final bool isLoading;
  final double totalStorageMb;

  const VaultState({
    this.downloadedTracks = const [],
    this.playlists = const [],
    this.activeDownloads = const {},
    this.isLoading = false,
    this.totalStorageMb = 0.0,
  });

  VaultState copyWith({
    List<AudioTrack>? downloadedTracks,
    List<Playlist>? playlists,
    Map<String, double>? activeDownloads,
    bool? isLoading,
    double? totalStorageMb,
  }) {
    return VaultState(
      downloadedTracks: downloadedTracks ?? this.downloadedTracks,
      playlists: playlists ?? this.playlists,
      activeDownloads: activeDownloads ?? this.activeDownloads,
      isLoading: isLoading ?? this.isLoading,
      totalStorageMb: totalStorageMb ?? this.totalStorageMb,
    );
  }

  @override
  List<Object?> get props => [
    downloadedTracks,
    playlists,
    activeDownloads,
    isLoading,
    totalStorageMb,
  ];
}

// BLoC
class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final AudioRepository _audioRepository;
  final Map<String, Timer> _downloadTimers = {};

  VaultBloc({required AudioRepository audioRepository})
    : _audioRepository = audioRepository,
      super(const VaultState()) {
    on<LoadVaultDataEvent>(_onLoadVaultData);
    on<StartDownloadTrackEvent>(_onStartDownloadTrack);
    on<DownloadProgressTickEvent>(_onDownloadProgressTick);
    on<PurgeCacheEvent>(_onPurgeCache);
    on<CreatePlaylistEvent>(_onCreatePlaylist);
    on<AddTrackToPlaylistEvent>(_onAddTrackToPlaylist);
    on<RemoveTrackFromPlaylistEvent>(_onRemoveTrackFromPlaylist);
  }

  Future<void> _onLoadVaultData(
    LoadVaultDataEvent event,
    Emitter<VaultState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final downloaded = await _audioRepository.getDownloadedTracks();
    final playlists = await _audioRepository.getPlaylists();

    double totalMb = 0.0;
    for (final t in downloaded) {
      totalMb += t.fileSizeMb;
    }

    emit(
      state.copyWith(
        downloadedTracks: downloaded,
        playlists: playlists,
        totalStorageMb: double.parse(totalMb.toStringAsFixed(1)),
        isLoading: false,
      ),
    );
  }

  Future<void> _onStartDownloadTrack(
    StartDownloadTrackEvent event,
    Emitter<VaultState> emit,
  ) async {
    final trackId = event.track.id;
    if (state.activeDownloads.containsKey(trackId)) return;

    final updatedDownloads = Map<String, double>.from(state.activeDownloads);
    updatedDownloads[trackId] = 0.05;
    emit(state.copyWith(activeDownloads: updatedDownloads));

    _downloadTimers[trackId]?.cancel();
    double currentProg = 0.05;
    _downloadTimers[trackId] = Timer.periodic(
      const Duration(milliseconds: 150),
      (timer) {
        currentProg += 0.15;
        if (currentProg >= 1.0) {
          timer.cancel();
          _downloadTimers.remove(trackId);
          add(DownloadProgressTickEvent(trackId, 1.0));
        } else {
          add(DownloadProgressTickEvent(trackId, currentProg));
        }
      },
    );
  }

  Future<void> _onDownloadProgressTick(
    DownloadProgressTickEvent event,
    Emitter<VaultState> emit,
  ) async {
    final updatedDownloads = Map<String, double>.from(state.activeDownloads);
    if (event.progress >= 1.0) {
      updatedDownloads.remove(event.trackId);
      await _audioRepository.setDownloadStatus(event.trackId, true);
      final downloaded = await _audioRepository.getDownloadedTracks();
      double totalMb = 0.0;
      for (final t in downloaded) {
        totalMb += t.fileSizeMb;
      }
      emit(
        state.copyWith(
          activeDownloads: updatedDownloads,
          downloadedTracks: downloaded,
          totalStorageMb: double.parse(totalMb.toStringAsFixed(1)),
        ),
      );
    } else {
      updatedDownloads[event.trackId] = event.progress;
      emit(state.copyWith(activeDownloads: updatedDownloads));
    }
  }

  Future<void> _onPurgeCache(
    PurgeCacheEvent event,
    Emitter<VaultState> emit,
  ) async {
    await _audioRepository.purgeOfflineCache();
    emit(
      state.copyWith(
        downloadedTracks: const [],
        totalStorageMb: 0.0,
        activeDownloads: const {},
      ),
    );
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylistEvent event,
    Emitter<VaultState> emit,
  ) async {
    await _audioRepository.createPlaylist(event.title, event.description);
    final playlists = await _audioRepository.getPlaylists();
    emit(state.copyWith(playlists: playlists));
  }

  Future<void> _onAddTrackToPlaylist(
    AddTrackToPlaylistEvent event,
    Emitter<VaultState> emit,
  ) async {
    await _audioRepository.addTrackToPlaylist(event.playlistId, event.trackId);
    final playlists = await _audioRepository.getPlaylists();
    emit(state.copyWith(playlists: playlists));
  }

  Future<void> _onRemoveTrackFromPlaylist(
    RemoveTrackFromPlaylistEvent event,
    Emitter<VaultState> emit,
  ) async {
    await _audioRepository.removeTrackFromPlaylist(
      event.playlistId,
      event.trackId,
    );
    final playlists = await _audioRepository.getPlaylists();
    emit(state.copyWith(playlists: playlists));
  }

  @override
  Future<void> close() {
    for (final timer in _downloadTimers.values) {
      timer.cancel();
    }
    return super.close();
  }
}

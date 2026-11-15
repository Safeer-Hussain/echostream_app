import 'dart:async';

import 'package:echo_stream_app/domain/entities/audio_track.dart';
import 'package:echo_stream_app/domain/entities/dsp_preset.dart';
import 'package:echo_stream_app/domain/entities/live_room.dart';
import 'package:echo_stream_app/domain/entities/playlist.dart';
import 'package:echo_stream_app/domain/entities/spectrum_data.dart';
import 'package:echo_stream_app/domain/entities/timestamp_clip.dart';
import 'package:echo_stream_app/domain/entities/transcript_chapter.dart';
import 'package:echo_stream_app/domain/entities/user_profile.dart';
import 'package:echo_stream_app/domain/repositories/analytics_repository.dart';
import 'package:echo_stream_app/domain/repositories/audio_repository.dart';
import 'package:echo_stream_app/domain/repositories/dsp_repository.dart';
import 'package:echo_stream_app/domain/repositories/live_room_repository.dart';

class MockAudioRepository implements AudioRepository {
  List<AudioTrack> tracks = [
    const AudioTrack(
      id: 'track_test_1',
      title: 'Systems & Compilers Test',
      artist: 'Test Architect',
      album: 'Test Album',
      coverAsset: 'assets/images/ambient_architecture.png',
      durationSec: 600,
      genre: 'Systems & AI',
      sampleRate: '192kHz',
      bitDepth: '24-bit',
      format: 'FLAC Master',
      isLossless: true,
      isDownloaded: false,
      fileSizeMb: 45.0,
      isLiked: false,
      isCached: false,
      playbackProgressSec: 0,
      transcriptText: 'Test transcript on SSA intermediate representation.',
      chapters: [
        TranscriptChapter(
          id: 'chap_1',
          trackId: 'track_test_1',
          title: 'Introduction',
          startTimeSec: 0,
          endTimeSec: 300,
          summary: 'Intro summary',
        ),
      ],
    ),
  ];

  final List<TimestampClip> clips = [];
  final List<Playlist> playlists = [];

  @override
  Future<List<AudioTrack>> getTracks({
    String? genreQuery,
    String? searchQuery,
  }) async {
    return tracks;
  }

  @override
  Future<AudioTrack?> getTrackById(String id) async {
    try {
      return tracks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> toggleLikeTrack(String trackId) async {
    final idx = tracks.indexWhere((t) => t.id == trackId);
    if (idx != -1) {
      tracks[idx] = tracks[idx].copyWith(isLiked: !tracks[idx].isLiked);
    }
  }

  @override
  Future<void> setDownloadStatus(String trackId, bool isDownloaded) async {
    final idx = tracks.indexWhere((t) => t.id == trackId);
    if (idx != -1) {
      tracks[idx] = tracks[idx].copyWith(isDownloaded: isDownloaded);
    }
  }

  @override
  Future<void> updatePlaybackProgress(String trackId, int positionSec) async {
    final idx = tracks.indexWhere((t) => t.id == trackId);
    if (idx != -1) {
      tracks[idx] = tracks[idx].copyWith(playbackProgressSec: positionSec);
    }
  }

  @override
  Future<List<Playlist>> getPlaylists() async => playlists;

  @override
  Future<void> createPlaylist(String title, String description) async {
    playlists.add(
      Playlist(
        id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        trackIds: const [],
        createdAt: '2026-11-15',
      ),
    );
  }

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {}

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {}

  @override
  Future<List<TimestampClip>> getTimestampClips({String? trackId}) async =>
      clips;

  @override
  Future<void> saveTimestampClip(TimestampClip clip) async {
    clips.add(clip);
  }

  @override
  Future<void> deleteTimestampClip(String clipId) async {
    clips.removeWhere((c) => c.id == clipId);
  }

  @override
  Future<List<AudioTrack>> getDownloadedTracks() async {
    return tracks.where((t) => t.isDownloaded).toList();
  }

  @override
  Future<void> purgeOfflineCache() async {
    for (int i = 0; i < tracks.length; i++) {
      tracks[i] = tracks[i].copyWith(isDownloaded: false);
    }
  }
}

class MockDspRepository implements DspRepository {
  List<double> currentBands = List.filled(10, 0.0);
  DspPreset currentPreset = DspPreset.defaultPresets.first;
  bool spatialEnabled = true;
  bool bitPerfect = false;
  int sleepMinutes = 0;

  final StreamController<SpectrumData> _controller =
      StreamController<SpectrumData>.broadcast();

  @override
  Future<List<DspPreset>> getPresets() async => DspPreset.defaultPresets;

  @override
  Future<void> saveCustomPreset(String name, List<double> bands) async {}

  @override
  Future<void> deletePreset(String presetId) async {}

  @override
  Future<void> setEqualizerBands(List<double> bands) async {
    currentBands = List.from(bands);
  }

  @override
  Future<void> applyPreset(DspPreset preset) async {
    currentPreset = preset;
    currentBands = List.from(preset.bands);
  }

  @override
  Future<void> setSpatialAudio(bool enabled) async {
    spatialEnabled = enabled;
  }

  @override
  Future<void> setBitPerfectMode(bool enabled) async {
    bitPerfect = enabled;
  }

  @override
  Future<void> setSleepTimer(int minutes) async {
    sleepMinutes = minutes;
  }

  @override
  Stream<SpectrumData> getSpectrumStream() => _controller.stream;
}

class MockLiveRoomRepository implements LiveRoomRepository {
  List<LiveRoom> rooms = [
    const LiveRoom(
      id: 'room_mock_1',
      title: 'DSP & Audio Systems',
      hostName: 'Dr. Sarah Lin',
      hostAvatar: 'assets/images/avatar_host_1.png',
      topicTag: 'DSP & Compilers',
      listenerCount: 50,
      isLive: true,
      isUserSpeaking: false,
      isUserHandRaised: false,
      reactionApplaud: 10,
      reactionInsightful: 5,
      reactionQuestion: 2,
      speakers: [
        LiveSpeaker(
          id: 'spk_1',
          name: 'Dr. Sarah Lin',
          role: 'Host',
          avatarAsset: 'assets/images/avatar_host_1.png',
          isSpeaking: true,
          isMuted: false,
        ),
      ],
      chatMessages: [],
    ),
  ];

  @override
  Future<List<LiveRoom>> getLiveRooms() async => rooms;

  @override
  Future<LiveRoom?> getRoomById(String id) async {
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> hostRoom({
    required String title,
    required String topicTag,
    required String hostName,
  }) async {
    rooms.add(
      LiveRoom(
        id: 'room_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        hostName: hostName,
        hostAvatar: 'assets/images/avatar_host_1.png',
        topicTag: topicTag,
        listenerCount: 1,
        isLive: true,
        isUserSpeaking: true,
        isUserHandRaised: false,
        reactionApplaud: 0,
        reactionInsightful: 0,
        reactionQuestion: 0,
        speakers: [
          LiveSpeaker(
            id: 'spk_host',
            name: hostName,
            role: 'Host',
            avatarAsset: 'assets/images/avatar_host_1.png',
            isSpeaking: true,
            isMuted: false,
          ),
        ],
        chatMessages: const [],
      ),
    );
  }

  @override
  Future<void> toggleRaiseHand(String roomId, bool raised) async {
    final idx = rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      rooms[idx] = rooms[idx].copyWith(isUserHandRaised: raised);
    }
  }

  @override
  Future<void> promoteToSpeaker(String roomId, String participantName) async {
    final idx = rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      final updatedSpeakers = List<LiveSpeaker>.from(rooms[idx].speakers)
        ..add(
          LiveSpeaker(
            id: 'spk_promoted',
            name: participantName,
            role: 'Speaker',
            avatarAsset: 'assets/images/avatar_host_2.png',
            isSpeaking: true,
            isMuted: false,
          ),
        );
      rooms[idx] = rooms[idx].copyWith(
        isUserSpeaking: true,
        isUserHandRaised: false,
        speakers: updatedSpeakers,
      );
    }
  }

  @override
  Future<void> incrementReaction(String roomId, String reactionType) async {
    final idx = rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      final room = rooms[idx];
      if (reactionType == 'applaud') {
        rooms[idx] = room.copyWith(reactionApplaud: room.reactionApplaud + 1);
      } else if (reactionType == 'insightful') {
        rooms[idx] = room.copyWith(
          reactionInsightful: room.reactionInsightful + 1,
        );
      } else {
        rooms[idx] = room.copyWith(reactionQuestion: room.reactionQuestion + 1);
      }
    }
  }

  @override
  Future<void> sendChatMessage(String roomId, LiveChatMessage message) async {
    final idx = rooms.indexWhere((r) => r.id == roomId);
    if (idx != -1) {
      final updated = List<LiveChatMessage>.from(rooms[idx].chatMessages)
        ..add(message);
      rooms[idx] = rooms[idx].copyWith(chatMessages: updated);
    }
  }
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<UserProfile> getUserProfile() async {
    return const UserProfile(
      name: 'Safeer Hussain',
      handle: '@safeer_hussain',
      email: 'safeer@echostream.studio',
      avatarAsset: 'assets/images/avatar_host_2.png',
      audioHardwareTier: 'Audiophile Reference 192kHz DAC',
      weeklyHoursListened: 26.5,
      totalTracksCompleted: 48,
      offlineVaultCount: 6,
      offlineVaultMb: 420.5,
    );
  }

  @override
  Future<Map<String, double>> getWeeklyListeningHours() async {
    return {
      'Mon': 3.5,
      'Tue': 4.2,
      'Wed': 5.0,
      'Thu': 3.8,
      'Fri': 4.5,
      'Sat': 6.2,
      'Sun': 5.4,
    };
  }

  @override
  Future<Map<String, double>> getGenreDistribution() async {
    return {'Systems & AI': 14.5, 'Deep Focus': 12.0, 'Lossless Master': 8.5};
  }

  @override
  Future<void> recordListeningSession(
    String trackId,
    int seconds,
    String genre,
  ) async {}
}

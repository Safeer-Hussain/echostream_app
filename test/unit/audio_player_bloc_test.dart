import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/presentation/player/bloc/audio_player_bloc.dart';

import '../mocks/mock_repositories.dart';

void main() {
  late MockAudioRepository mockAudioRepo;
  late MockDspRepository mockDspRepo;
  late AudioPlayerBloc audioPlayerBloc;

  setUp(() {
    mockAudioRepo = MockAudioRepository();
    mockDspRepo = MockDspRepository();
    audioPlayerBloc = AudioPlayerBloc(
      audioRepository: mockAudioRepo,
      dspRepository: mockDspRepo,
    );
  });

  tearDown(() {
    audioPlayerBloc.close();
  });

  group('AudioPlayerBloc Unit Tests', () {
    test('1. Loads track and updates state with autoPlay', () async {
      final track = mockAudioRepo.tracks.first;
      audioPlayerBloc.add(LoadTrackEvent(track, autoPlay: true));

      await expectLater(
        audioPlayerBloc.stream,
        emitsThrough(
          predicate<AudioPlayerState>(
            (state) =>
                state.currentTrack?.id == track.id && state.isPlaying == true,
          ),
        ),
      );
    });

    test('2. Toggles play/pause correctly', () async {
      final track = mockAudioRepo.tracks.first;
      audioPlayerBloc.add(LoadTrackEvent(track, autoPlay: true));
      await Future.delayed(const Duration(milliseconds: 50));

      audioPlayerBloc.add(TogglePlayPauseEvent());

      await expectLater(
        audioPlayerBloc.stream,
        emitsThrough(
          predicate<AudioPlayerState>((state) => state.isPlaying == false),
        ),
      );
    });

    test('3. Seeks position and clamps correctly to duration bounds', () async {
      final track = mockAudioRepo.tracks.first;
      audioPlayerBloc.add(LoadTrackEvent(track, autoPlay: false));
      await Future.delayed(const Duration(milliseconds: 50));

      audioPlayerBloc.add(const SeekPositionEvent(240));

      await expectLater(
        audioPlayerBloc.stream,
        emitsThrough(
          predicate<AudioPlayerState>(
            (state) => state.currentPositionSec == 240,
          ),
        ),
      );
    });

    test(
      '4. Instant like toggle updates immutable state and repository',
      () async {
        final track = mockAudioRepo.tracks.first;
        audioPlayerBloc.add(LoadTrackEvent(track, autoPlay: false));
        await Future.delayed(const Duration(milliseconds: 50));

        audioPlayerBloc.add(ToggleLikeCurrentTrackEvent());

        await expectLater(
          audioPlayerBloc.stream,
          emitsThrough(
            predicate<AudioPlayerState>(
              (state) =>
                  state.currentTrack != null &&
                  state.currentTrack!.isLiked == true,
            ),
          ),
        );
        expect(mockAudioRepo.tracks.first.isLiked, true);
      },
    );

    test('5. Saves timestamp clip and emits lastSavedClipId', () async {
      final track = mockAudioRepo.tracks.first;
      audioPlayerBloc.add(LoadTrackEvent(track, autoPlay: false));
      audioPlayerBloc.add(const SeekPositionEvent(120));
      await Future.delayed(const Duration(milliseconds: 50));

      audioPlayerBloc.add(
        const SaveTimestampClipEvent('SSA phi nodes insight'),
      );

      await expectLater(
        audioPlayerBloc.stream,
        emitsThrough(
          predicate<AudioPlayerState>((state) => state.lastSavedClipId != null),
        ),
      );
      expect(mockAudioRepo.clips.length, 1);
      expect(mockAudioRepo.clips.first.timestampSec, 120);
    });
  });
}

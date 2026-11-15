import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/presentation/live_rooms/bloc/live_room_bloc.dart';

import '../mocks/mock_repositories.dart';

void main() {
  late MockLiveRoomRepository mockLiveRoomRepo;
  late LiveRoomBloc liveRoomBloc;

  setUp(() {
    mockLiveRoomRepo = MockLiveRoomRepository();
    liveRoomBloc = LiveRoomBloc(liveRoomRepository: mockLiveRoomRepo);
  });

  tearDown(() {
    liveRoomBloc.close();
  });

  group('LiveRoomBloc Unit Tests', () {
    test('9. Loads live rooms into state', () async {
      liveRoomBloc.add(LoadLiveRoomsEvent());

      await expectLater(
        liveRoomBloc.stream,
        emitsThrough(
          predicate<LiveRoomState>(
            (state) => state.rooms.isNotEmpty && state.isLoading == false,
          ),
        ),
      );
    });

    test(
      '10. Raise hand dynamically promotes user to Speakers Stage',
      () async {
        liveRoomBloc.add(LoadLiveRoomsEvent());
        await Future.delayed(const Duration(milliseconds: 50));
        liveRoomBloc.add(const SelectLiveRoomEvent('room_mock_1'));
        await Future.delayed(const Duration(milliseconds: 50));

        liveRoomBloc.add(const ToggleRaiseHandEvent('room_mock_1'));

        await expectLater(
          liveRoomBloc.stream,
          emitsThrough(
            predicate<LiveRoomState>(
              (state) =>
                  state.activeRoom?.isUserSpeaking == true &&
                  state.activeRoom?.speakers.any(
                        (s) => s.name.contains('Safeer'),
                      ) ==
                      true,
            ),
          ),
        );
      },
    );

    test('11. Reaction counters increment instantly on button tap', () async {
      liveRoomBloc.add(LoadLiveRoomsEvent());
      await Future.delayed(const Duration(milliseconds: 50));
      liveRoomBloc.add(const SelectLiveRoomEvent('room_mock_1'));
      await Future.delayed(const Duration(milliseconds: 50));

      final initialApplaud = mockLiveRoomRepo.rooms.first.reactionApplaud;
      liveRoomBloc.add(const SendReactionEvent('room_mock_1', 'applaud'));

      await expectLater(
        liveRoomBloc.stream,
        emitsThrough(
          predicate<LiveRoomState>(
            (state) =>
                state.activeRoom != null &&
                state.activeRoom!.reactionApplaud == initialApplaud + 1,
          ),
        ),
      );
    });
  });
}

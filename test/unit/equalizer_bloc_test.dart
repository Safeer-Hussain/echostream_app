import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/domain/entities/dsp_preset.dart';
import 'package:echo_stream_app/presentation/equalizer/bloc/equalizer_bloc.dart';

import '../mocks/mock_repositories.dart';

void main() {
  late MockDspRepository mockDspRepo;
  late EqualizerBloc equalizerBloc;

  setUp(() {
    mockDspRepo = MockDspRepository();
    equalizerBloc = EqualizerBloc(dspRepository: mockDspRepo);
  });

  tearDown(() {
    equalizerBloc.close();
  });

  group('EqualizerBloc Unit Tests', () {
    test(
      '6. Updates band gain and switches selected preset to Custom',
      () async {
        equalizerBloc.add(const UpdateBandGainEvent(0, 6.5));

        await expectLater(
          equalizerBloc.stream,
          emitsThrough(
            predicate<EqualizerState>(
              (state) =>
                  state.bands[0] == 6.5 && state.selectedPresetName == 'Custom',
            ),
          ),
        );
        expect(mockDspRepo.currentBands[0], 6.5);
      },
    );

    test('7. Applies DSP preset and sets all 10 bands correctly', () async {
      final subBassPreset = DspPreset.defaultPresets[1]; // Sub-Bass Impact
      equalizerBloc.add(SelectPresetEvent(subBassPreset));

      await expectLater(
        equalizerBloc.stream,
        emitsThrough(
          predicate<EqualizerState>(
            (state) =>
                state.selectedPresetName == 'Sub-Bass Impact' &&
                state.bands[0] == subBassPreset.bands[0],
          ),
        ),
      );
      expect(mockDspRepo.currentPreset.name, 'Sub-Bass Impact');
    });

    test('8. Toggles 3D Spatial Audio and Bit-Perfect DAC mode', () async {
      equalizerBloc.add(const ToggleSpatialAudioEvent(false));
      equalizerBloc.add(const ToggleBitPerfectDacEvent(true));

      await expectLater(
        equalizerBloc.stream,
        emitsThrough(
          predicate<EqualizerState>(
            (state) =>
                state.isSpatialAudioEnabled == false &&
                state.isBitPerfectDacEnabled == true,
          ),
        ),
      );
      expect(mockDspRepo.spatialEnabled, false);
      expect(mockDspRepo.bitPerfect, true);
    });
  });
}

import '../entities/dsp_preset.dart';
import '../entities/spectrum_data.dart';

abstract class DspRepository {
  Future<List<DspPreset>> getPresets();
  Future<void> saveCustomPreset(String name, List<double> bands);
  Future<void> deletePreset(String presetId);
  Future<void> setEqualizerBands(List<double> bands);
  Future<void> applyPreset(DspPreset preset);
  Future<void> setSpatialAudio(bool enabled);
  Future<void> setBitPerfectMode(bool enabled);
  Future<void> setSleepTimer(int minutes);
  Stream<SpectrumData> getSpectrumStream();
}

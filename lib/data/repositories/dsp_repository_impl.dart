import 'package:sqflite/sqflite.dart';

import '../../core/services/audio_dsp_bridge.dart';
import '../../domain/entities/dsp_preset.dart';
import '../../domain/entities/spectrum_data.dart';
import '../../domain/repositories/dsp_repository.dart';
import '../datasources/database/app_database.dart';

class DspRepositoryImpl implements DspRepository {
  final AppDatabase _appDatabase;
  final AudioDspBridge _dspBridge;

  DspRepositoryImpl(this._appDatabase, this._dspBridge);

  @override
  Future<List<DspPreset>> getPresets() async {
    final db = await _appDatabase.database;
    final maps = await db.query('custom_eq_presets');
    if (maps.isEmpty) {
      return DspPreset.defaultPresets;
    }
    return maps.map((m) => DspPreset.fromMap(m)).toList();
  }

  @override
  Future<void> saveCustomPreset(String name, List<double> bands) async {
    final db = await _appDatabase.database;
    final preset = DspPreset(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      bands: bands,
      isSystemPreset: false,
    );
    await db.insert(
      'custom_eq_presets',
      preset.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deletePreset(String presetId) async {
    final db = await _appDatabase.database;
    await db.delete(
      'custom_eq_presets',
      where: 'id = ? AND isSystemPreset = 0',
      whereArgs: [presetId],
    );
  }

  @override
  Future<void> setEqualizerBands(List<double> bands) async {
    await _dspBridge.setEqualizerBands(bands);
  }

  @override
  Future<void> applyPreset(DspPreset preset) async {
    await _dspBridge.applyDspPreset(preset.name);
    await _dspBridge.setEqualizerBands(preset.bands);
  }

  @override
  Future<void> setSpatialAudio(bool enabled) async {
    await _dspBridge.toggleSpatialAudio(enabled);
  }

  @override
  Future<void> setBitPerfectMode(bool enabled) async {
    await _dspBridge.setBitPerfectDacMode(enabled);
  }

  @override
  Future<void> setSleepTimer(int minutes) async {
    await _dspBridge.configureSleepTimer(minutes);
  }

  @override
  Stream<SpectrumData> getSpectrumStream() {
    return _dspBridge.spectrumStream;
  }
}

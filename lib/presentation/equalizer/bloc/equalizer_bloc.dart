import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/dsp_preset.dart';
import '../../../domain/repositories/dsp_repository.dart';

// Events
abstract class EqualizerEvent extends Equatable {
  const EqualizerEvent();
  @override
  List<Object?> get props => [];
}

class LoadEqualizerSettingsEvent extends EqualizerEvent {}

class UpdateBandGainEvent extends EqualizerEvent {
  final int index;
  final double gain;
  const UpdateBandGainEvent(this.index, this.gain);
  @override
  List<Object?> get props => [index, gain];
}

class SelectPresetEvent extends EqualizerEvent {
  final DspPreset preset;
  const SelectPresetEvent(this.preset);
  @override
  List<Object?> get props => [preset];
}

class SaveCustomPresetEvent extends EqualizerEvent {
  final String name;
  const SaveCustomPresetEvent(this.name);
  @override
  List<Object?> get props => [name];
}

class DeleteCustomPresetEvent extends EqualizerEvent {
  final String presetId;
  const DeleteCustomPresetEvent(this.presetId);
  @override
  List<Object?> get props => [presetId];
}

class ToggleSpatialAudioEvent extends EqualizerEvent {
  final bool enabled;
  const ToggleSpatialAudioEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleBitPerfectDacEvent extends EqualizerEvent {
  final bool enabled;
  const ToggleBitPerfectDacEvent(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateCrossfadeEvent extends EqualizerEvent {
  final double seconds;
  const UpdateCrossfadeEvent(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class SetSleepTimerEvent extends EqualizerEvent {
  final int minutes;
  const SetSleepTimerEvent(this.minutes);
  @override
  List<Object?> get props => [minutes];
}

// State
class EqualizerState extends Equatable {
  final List<double> bands;
  final List<DspPreset> presets;
  final String selectedPresetName;
  final bool isSpatialAudioEnabled;
  final bool isBitPerfectDacEnabled;
  final double crossfadeDurationSec;
  final int sleepTimerMinutes;

  const EqualizerState({
    required this.bands,
    required this.presets,
    required this.selectedPresetName,
    this.isSpatialAudioEnabled = true,
    this.isBitPerfectDacEnabled = false,
    this.crossfadeDurationSec = 3.0,
    this.sleepTimerMinutes = 0,
  });

  factory EqualizerState.initial() {
    return EqualizerState(
      bands: List.filled(10, 0.0),
      presets: DspPreset.defaultPresets,
      selectedPresetName: 'Studio Reference Flat',
      isSpatialAudioEnabled: true,
      isBitPerfectDacEnabled: false,
      crossfadeDurationSec: 3.0,
      sleepTimerMinutes: 0,
    );
  }

  EqualizerState copyWith({
    List<double>? bands,
    List<DspPreset>? presets,
    String? selectedPresetName,
    bool? isSpatialAudioEnabled,
    bool? isBitPerfectDacEnabled,
    double? crossfadeDurationSec,
    int? sleepTimerMinutes,
  }) {
    return EqualizerState(
      bands: bands ?? this.bands,
      presets: presets ?? this.presets,
      selectedPresetName: selectedPresetName ?? this.selectedPresetName,
      isSpatialAudioEnabled:
          isSpatialAudioEnabled ?? this.isSpatialAudioEnabled,
      isBitPerfectDacEnabled:
          isBitPerfectDacEnabled ?? this.isBitPerfectDacEnabled,
      crossfadeDurationSec: crossfadeDurationSec ?? this.crossfadeDurationSec,
      sleepTimerMinutes: sleepTimerMinutes ?? this.sleepTimerMinutes,
    );
  }

  @override
  List<Object?> get props => [
    bands,
    presets,
    selectedPresetName,
    isSpatialAudioEnabled,
    isBitPerfectDacEnabled,
    crossfadeDurationSec,
    sleepTimerMinutes,
  ];
}

// BLoC
class EqualizerBloc extends Bloc<EqualizerEvent, EqualizerState> {
  final DspRepository _dspRepository;

  EqualizerBloc({required DspRepository dspRepository})
    : _dspRepository = dspRepository,
      super(EqualizerState.initial()) {
    on<LoadEqualizerSettingsEvent>(_onLoadSettings);
    on<UpdateBandGainEvent>(_onUpdateBandGain);
    on<SelectPresetEvent>(_onSelectPreset);
    on<SaveCustomPresetEvent>(_onSaveCustomPreset);
    on<DeleteCustomPresetEvent>(_onDeleteCustomPreset);
    on<ToggleSpatialAudioEvent>(_onToggleSpatialAudio);
    on<ToggleBitPerfectDacEvent>(_onToggleBitPerfectDac);
    on<UpdateCrossfadeEvent>(_onUpdateCrossfade);
    on<SetSleepTimerEvent>(_onSetSleepTimer);
  }

  Future<void> _onLoadSettings(
    LoadEqualizerSettingsEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    final presets = await _dspRepository.getPresets();
    emit(state.copyWith(presets: presets));
  }

  Future<void> _onUpdateBandGain(
    UpdateBandGainEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    final newBands = List<double>.from(state.bands);
    if (event.index >= 0 && event.index < newBands.length) {
      newBands[event.index] = event.gain.clamp(-12.0, 12.0);
      emit(state.copyWith(bands: newBands, selectedPresetName: 'Custom'));
      await _dspRepository.setEqualizerBands(newBands);
    }
  }

  Future<void> _onSelectPreset(
    SelectPresetEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    emit(
      state.copyWith(
        bands: List<double>.from(event.preset.bands),
        selectedPresetName: event.preset.name,
      ),
    );
    await _dspRepository.applyPreset(event.preset);
  }

  Future<void> _onSaveCustomPreset(
    SaveCustomPresetEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    await _dspRepository.saveCustomPreset(event.name, state.bands);
    final presets = await _dspRepository.getPresets();
    emit(state.copyWith(presets: presets, selectedPresetName: event.name));
  }

  Future<void> _onDeleteCustomPreset(
    DeleteCustomPresetEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    await _dspRepository.deletePreset(event.presetId);
    final presets = await _dspRepository.getPresets();
    emit(state.copyWith(presets: presets));
  }

  Future<void> _onToggleSpatialAudio(
    ToggleSpatialAudioEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    emit(state.copyWith(isSpatialAudioEnabled: event.enabled));
    await _dspRepository.setSpatialAudio(event.enabled);
  }

  Future<void> _onToggleBitPerfectDac(
    ToggleBitPerfectDacEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    emit(state.copyWith(isBitPerfectDacEnabled: event.enabled));
    await _dspRepository.setBitPerfectMode(event.enabled);
  }

  void _onUpdateCrossfade(
    UpdateCrossfadeEvent event,
    Emitter<EqualizerState> emit,
  ) {
    emit(state.copyWith(crossfadeDurationSec: event.seconds));
  }

  Future<void> _onSetSleepTimer(
    SetSleepTimerEvent event,
    Emitter<EqualizerState> emit,
  ) async {
    emit(state.copyWith(sleepTimerMinutes: event.minutes));
    await _dspRepository.setSleepTimer(event.minutes);
  }
}

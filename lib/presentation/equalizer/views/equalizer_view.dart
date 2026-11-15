import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_feedback.dart';
import '../bloc/equalizer_bloc.dart';
import 'widgets/band_slider.dart';
import 'widgets/frequency_curve_painter.dart';

class EqualizerView extends StatefulWidget {
  const EqualizerView({super.key});

  @override
  State<EqualizerView> createState() => _EqualizerViewState();
}

class _EqualizerViewState extends State<EqualizerView> {
  final ScrollController _leftScrollController = ScrollController();
  final ScrollController _rightScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<EqualizerBloc>().add(LoadEqualizerSettingsEvent());
  }

  @override
  void dispose() {
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    super.dispose();
  }

  void _showSavePresetDialog(BuildContext context, EqualizerBloc bloc) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colorScheme = Theme.of(context).colorScheme;

          return AlertDialog(
            backgroundColor: colorScheme.surfaceContainer,
            title: Text(
              'Save Custom DSP Preset',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Preset Name',
                hintText: 'e.g., Electrostatic Headphone Curve',
                errorText: errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.length < 3) {
                    setDialogState(() {
                      errorText = 'Name must be at least 3 characters';
                    });
                    return;
                  }
                  bloc.add(SaveCustomPresetEvent(name));
                  Navigator.of(dialogCtx).pop();
                  AppFeedback.showSuccess(
                    context,
                    'Saved custom DSP preset "$name" to SQLite.',
                  );
                },
                child: const Text('Save Preset'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<EqualizerBloc, EqualizerState>(
      builder: (context, state) {
        if (isLandscape) {
          // 360dp Landscape Two-Pane Safe
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'fab_eq_save_preset',
              onPressed: () =>
                  _showSavePresetDialog(context, context.read<EqualizerBloc>()),
              icon: const Icon(Icons.bookmark_add_rounded, size: 18.0),
              label: const Text('Save Preset'),
            ),
            body: SafeArea(
              child: Row(
                children: [
                  // Left Pane: Frequency Curve & 10 Band Sliders
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      controller: _leftScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCurveOverlay(context, state.bands),
                          const SizedBox(height: 8.0),
                          _buildBandsRow(context, state),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1.0,
                    color: colorScheme.outlineVariant,
                  ),
                  // Right Pane: Presets & Hardware Audio Switches
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      controller: _rightScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPresetsSection(context, state),
                          const SizedBox(height: 12.0),
                          _buildHardwareSwitches(context, state),
                          const SizedBox(height: 60.0), // Padding for FAB
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Portrait Layout
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_eq_save_preset',
            onPressed: () =>
                _showSavePresetDialog(context, context.read<EqualizerBloc>()),
            icon: const Icon(Icons.bookmark_add_rounded, size: 18.0),
            label: const Text('Save Preset'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCurveOverlay(context, state.bands),
                  const SizedBox(height: 16.0),
                  _buildBandsRow(context, state),
                  const SizedBox(height: 20.0),
                  _buildPresetsSection(context, state),
                  const SizedBox(height: 20.0),
                  _buildHardwareSwitches(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurveOverlay(BuildContext context, List<double> bands) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 90.0,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: CustomPaint(
          painter: FrequencyCurvePainter(
            bands: bands,
            curveColor: colorScheme.primary,
            fillColor: colorScheme.primary,
            gridColor: colorScheme.outlineVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildBandsRow(BuildContext context, EqualizerState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<EqualizerBloc>();

    return Container(
      height: 185.0,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 480.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(10, (index) {
              final gain = index < state.bands.length
                  ? state.bands[index]
                  : 0.0;
              final label = AppConstants.defaultEqLabels[index];
              return Expanded(
                child: BandSlider(
                  label: label,
                  gain: gain,
                  onChanged: (val) {
                    bloc.add(UpdateBandGainEvent(index, val));
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetsSection(BuildContext context, EqualizerState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<EqualizerBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DSP Equalizer Presets',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          'Active: ${state.selectedPresetName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: state.presets.map((preset) {
            final isSelected = state.selectedPresetName == preset.name;
            return ChoiceChip(
              label: Text(
                preset.name,
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainer,
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              onSelected: (_) {
                bloc.add(SelectPresetEvent(preset));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHardwareSwitches(BuildContext context, EqualizerState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<EqualizerBloc>();

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hardware Audio Engine Configuration',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10.0),
          // 3D Spatial Binaural Engine
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '3D Spatial Binaural Engine',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'HRTF elevation & acoustic room convolution filter',
                style: TextStyle(
                  fontSize: 11.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: state.isSpatialAudioEnabled,
              activeColor: colorScheme.primary,
              onChanged: (val) {
                bloc.add(ToggleSpatialAudioEvent(val));
                AppFeedback.showInfo(
                  context,
                  val
                      ? '3D Spatial Binaural Engine Enabled'
                      : 'Spatial Engine Bypassed (Stereo Master)',
                );
              },
            ),
          ),
          const Divider(),
          // Bit-Perfect DAC Bypass
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Bit-Perfect DAC Bypass',
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '192kHz / 24-bit direct hardware sample stream',
                style: TextStyle(
                  fontSize: 11.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: state.isBitPerfectDacEnabled,
              activeColor: colorScheme.primary,
              onChanged: (val) {
                bloc.add(ToggleBitPerfectDacEvent(val));
                AppFeedback.showInfo(
                  context,
                  val
                      ? 'Bit-Perfect DAC Bypass: Direct 192kHz hardware stream'
                      : 'System Resampler Active',
                );
              },
            ),
          ),
          const Divider(),
          // Crossfade Duration Slider (0s to 12s)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Track Crossfade Duration',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    '${state.crossfadeDurationSec.toStringAsFixed(1)}s',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.crossfadeDurationSec,
                min: 0.0,
                max: 12.0,
                divisions: 24,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.surfaceContainerHighest,
                onChanged: (val) {
                  bloc.add(UpdateCrossfadeEvent(val));
                },
              ),
            ],
          ),
          const Divider(),
          // Sleep Timer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep Timer',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6.0),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: [0, 15, 30, 60].map((mins) {
                  final isSel = state.sleepTimerMinutes == mins;
                  return ChoiceChip(
                    label: Text(
                      mins == 0 ? 'Off' : '${mins}m',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isSel
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    onSelected: (_) {
                      bloc.add(SetSleepTimerEvent(mins));
                      if (mins > 0) {
                        AppFeedback.showSuccess(
                          context,
                          'Sleep timer set to $mins minutes.',
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

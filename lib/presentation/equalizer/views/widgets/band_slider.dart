import 'package:flutter/material.dart';

class BandSlider extends StatelessWidget {
  final String label;
  final double gain; // -12.0 to +12.0
  final ValueChanged<double> onChanged;

  const BandSlider({
    super.key,
    required this.label,
    required this.gain,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            color: gain != 0.0
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4.0),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3.5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12.0,
                ),
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.surfaceContainerHighest,
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withOpacity(0.15),
              ),
              child: Slider(
                value: gain,
                min: -12.0,
                max: 12.0,
                divisions: 48,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

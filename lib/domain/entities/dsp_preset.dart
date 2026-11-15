import 'dart:convert';

class DspPreset {
  final String id;
  final String name;
  final List<double> bands;
  final bool isSystemPreset;

  const DspPreset({
    required this.id,
    required this.name,
    required this.bands,
    this.isSystemPreset = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bandsJson': jsonEncode(bands),
      'isSystemPreset': isSystemPreset ? 1 : 0,
    };
  }

  factory DspPreset.fromMap(Map<String, dynamic> map) {
    List<double> parsedBands = List.filled(10, 0.0);
    final rawBands = map['bandsJson'];
    if (rawBands is String && rawBands.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawBands) as List<dynamic>;
        parsedBands = decoded.map((e) => (e as num).toDouble()).toList();
      } catch (_) {}
    }
    return DspPreset(
      id: map['id'] as String,
      name: map['name'] as String,
      bands: parsedBands,
      isSystemPreset: (map['isSystemPreset'] as num?) == 1,
    );
  }

  static List<DspPreset> get defaultPresets => const [
    DspPreset(
      id: 'preset_studio_flat',
      name: 'Studio Reference Flat',
      bands: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      isSystemPreset: true,
    ),
    DspPreset(
      id: 'preset_sub_bass',
      name: 'Sub-Bass Impact',
      bands: [7.0, 6.0, 4.0, 2.0, 0.0, -1.0, 0.0, 1.5, 2.0, 3.0],
      isSystemPreset: true,
    ),
    DspPreset(
      id: 'preset_vocal_clarity',
      name: 'Vocal & Podcast Clarity',
      bands: [-2.0, -1.0, 0.0, 2.5, 4.0, 4.5, 3.0, 1.5, 0.5, -1.0],
      isSystemPreset: true,
    ),
    DspPreset(
      id: 'preset_acoustic_warmth',
      name: 'Acoustic Warmth',
      bands: [3.5, 3.0, 2.0, 1.0, 1.5, 0.5, 0.0, 1.0, 2.0, 1.5],
      isSystemPreset: true,
    ),
    DspPreset(
      id: 'preset_late_night',
      name: 'Late Night Compressor',
      bands: [-3.0, -2.0, 0.0, 1.0, 1.5, 1.0, 0.0, -1.5, -3.0, -4.0],
      isSystemPreset: true,
    ),
  ];
}

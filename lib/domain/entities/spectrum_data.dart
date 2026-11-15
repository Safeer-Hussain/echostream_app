class SpectrumData {
  final List<double> bands;
  final double peakDbfs;
  final String sampleRate;
  final double dynamicRangeScore;
  final double bufferLatencyMs;
  final bool spatialActive;

  const SpectrumData({
    required this.bands,
    required this.peakDbfs,
    required this.sampleRate,
    required this.dynamicRangeScore,
    required this.bufferLatencyMs,
    required this.spatialActive,
  });

  factory SpectrumData.fromMap(Map<dynamic, dynamic> map) {
    final rawBands = map['bands'] as List<dynamic>? ?? [];
    final parsedBands = rawBands.map((e) => (e as num).toDouble()).toList();
    return SpectrumData(
      bands: parsedBands.isEmpty
          ? List.generate(32, (i) => 0.1 + (i % 5) * 0.1)
          : parsedBands,
      peakDbfs: (map['peakDbfs'] as num?)?.toDouble() ?? -6.0,
      sampleRate: map['sampleRate'] as String? ?? '192kHz / 24-bit FLAC',
      dynamicRangeScore: (map['dynamicRangeScore'] as num?)?.toDouble() ?? 14.2,
      bufferLatencyMs: (map['bufferLatencyMs'] as num?)?.toDouble() ?? 4.8,
      spatialActive: map['spatialActive'] as bool? ?? true,
    );
  }

  factory SpectrumData.initial() {
    return SpectrumData(
      bands: List.generate(32, (index) => 0.08),
      peakDbfs: -12.0,
      sampleRate: '192kHz / 24-bit FLAC',
      dynamicRangeScore: 14.2,
      bufferLatencyMs: 4.8,
      spatialActive: true,
    );
  }
}

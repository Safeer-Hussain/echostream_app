class AppConstants {
  static const String appName = 'EchoStream';
  static const String appVersion = '1.0.0+1';
  static const String studioEngine =
      'EchoStream Lossless 24-Bit Spatial Engine';
  static const String dacBitPerfectMode =
      '192kHz / 24-bit Bit-Perfect DAC Bypass';

  static const String dspMethodChannel = 'com.safeer.echostream/audio_dsp';
  static const String spectrumEventChannel =
      'com.safeer.echostream/pcm_spectrum';

  static const List<String> catalogGenres = [
    'All',
    'Systems & AI',
    'Deep Focus',
    'Lossless Master',
    'Tech Keynotes',
    'Acoustic',
  ];

  static const List<double> defaultEqFrequencies = [
    32.0,
    64.0,
    125.0,
    250.0,
    500.0,
    1000.0,
    2000.0,
    4000.0,
    8000.0,
    16000.0,
  ];

  static const List<String> defaultEqLabels = [
    '32Hz',
    '64Hz',
    '125Hz',
    '250Hz',
    '500Hz',
    '1kHz',
    '2kHz',
    '4kHz',
    '8kHz',
    '16kHz',
  ];
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../domain/entities/spectrum_data.dart';
import '../constants/app_constants.dart';

class AudioDspBridge {
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  StreamController<SpectrumData>? _fallbackController;
  Timer? _fallbackTimer;
  double _fallbackTick = 0;

  bool _isNativeAvailable = true;
  Stream<SpectrumData>? _stream;

  AudioDspBridge({MethodChannel? methodChannel, EventChannel? eventChannel})
    : _methodChannel =
          methodChannel ?? const MethodChannel(AppConstants.dspMethodChannel),
      _eventChannel =
          eventChannel ?? const EventChannel(AppConstants.spectrumEventChannel);

  Future<void> setEqualizerBands(List<double> bands) async {
    try {
      if (_isNativeAvailable) {
        await _methodChannel.invokeMethod('setEqualizerBands', {
          'bands': bands,
        });
      }
    } catch (_) {
      _isNativeAvailable = false;
    }
  }

  Future<void> applyDspPreset(String preset) async {
    try {
      if (_isNativeAvailable) {
        await _methodChannel.invokeMethod('applyDspPreset', {'preset': preset});
      }
    } catch (_) {
      _isNativeAvailable = false;
    }
  }

  Future<void> toggleSpatialAudio(bool enabled) async {
    try {
      if (_isNativeAvailable) {
        await _methodChannel.invokeMethod('toggleSpatialAudio', {
          'enabled': enabled,
        });
      }
    } catch (_) {
      _isNativeAvailable = false;
    }
  }

  Future<void> setBitPerfectDacMode(bool enabled) async {
    try {
      if (_isNativeAvailable) {
        await _methodChannel.invokeMethod('setBitPerfectDacMode', {
          'enabled': enabled,
        });
      }
    } catch (_) {
      _isNativeAvailable = false;
    }
  }

  Future<void> configureSleepTimer(int minutes) async {
    try {
      if (_isNativeAvailable) {
        await _methodChannel.invokeMethod('configureSleepTimer', {
          'minutes': minutes,
        });
      }
    } catch (_) {
      _isNativeAvailable = false;
    }
  }

  Stream<SpectrumData> get spectrumStream {
    _stream ??= _buildSpectrumStream();
    return _stream!;
  }

  Stream<SpectrumData> _buildSpectrumStream() {
    try {
      return _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) {
            if (event is Map) {
              return SpectrumData.fromMap(event);
            }
            return SpectrumData.initial();
          })
          .handleError((error) {
            return _getFallbackStream();
          });
    } catch (_) {
      return _getFallbackStream();
    }
  }

  Stream<SpectrumData> _getFallbackStream() {
    if (_fallbackController != null) return _fallbackController!.stream;

    _fallbackController = StreamController<SpectrumData>.broadcast(
      onListen: () {
        _fallbackTimer?.cancel();
        _fallbackTimer = Timer.periodic(const Duration(milliseconds: 250), (
          timer,
        ) {
          _fallbackTick += 1.0;
          final bands = <double>[];
          final basePhase = _fallbackTick * 0.15;
          for (int i = 0; i < 32; i++) {
            final harmonic = (sin(basePhase + i * 0.35) * 0.35 + 0.5);
            final modulation = cos(basePhase * 0.7 + i * 0.2) * 0.15;
            final value = (harmonic + modulation).clamp(0.06, 0.96);
            bands.add(value);
          }
          final spectrum = SpectrumData(
            bands: bands,
            peakDbfs: -5.4 - (_fallbackTick.toInt() % 4) * 0.4,
            sampleRate: '192kHz / 24-bit FLAC',
            dynamicRangeScore: 14.2 + sin(basePhase) * 0.3,
            bufferLatencyMs: 4.8,
            spatialActive: true,
          );
          if (!_fallbackController!.isClosed) {
            _fallbackController!.add(spectrum);
          }
        });
      },
      onCancel: () {
        _fallbackTimer?.cancel();
        _fallbackTimer = null;
      },
    );

    return _fallbackController!.stream;
  }

  void dispose() {
    _fallbackTimer?.cancel();
    _fallbackController?.close();
  }
}

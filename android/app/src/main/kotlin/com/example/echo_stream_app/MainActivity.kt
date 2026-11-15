package com.example.echo_stream_app

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.cos
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    private val dspChannelName = "com.safeer.echostream/audio_dsp"
    private val spectrumChannelName = "com.safeer.echostream/pcm_spectrum"

    private var spatialAudioEnabled = true
    private var bitPerfectMode = false
    private var activePreset = "Studio Reference Flat"
    private var equalizerGains = DoubleArray(10) { 0.0 }
    private var sleepTimerMinutes = 0

    private val mainHandler = Handler(Looper.getMainLooper())
    private var spectrumEventSink: EventChannel.EventSink? = null
    private var spectrumRunnable: Runnable? = null
    private var tickCount = 0L

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, dspChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "setEqualizerBands" -> {
                    val bands = call.argument<List<Double>>("bands")
                    if (bands != null) {
                        for (i in bands.indices) {
                            if (i < equalizerGains.size) {
                                equalizerGains[i] = bands[i]
                            }
                        }
                        result.success(mapOf("status" to "applied", "bandsCount" to bands.size))
                    } else {
                        result.error("INVALID_ARGS", "Bands list is required", null)
                    }
                }
                "applyDspPreset" -> {
                    val preset = call.argument<String>("preset") ?: "Studio Reference Flat"
                    activePreset = preset
                    result.success(mapOf("status" to "applied", "preset" to activePreset))
                }
                "toggleSpatialAudio" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    spatialAudioEnabled = enabled
                    result.success(mapOf("status" to "updated", "spatialAudio" to spatialAudioEnabled))
                }
                "setBitPerfectDacMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    bitPerfectMode = enabled
                    result.success(mapOf("status" to "updated", "bitPerfectMode" to bitPerfectMode))
                }
                "configureSleepTimer" -> {
                    val minutes = call.argument<Int>("minutes") ?: 0
                    sleepTimerMinutes = minutes
                    result.success(mapOf("status" to "configured", "sleepMinutes" to sleepTimerMinutes))
                }
                "getDspStatus" -> {
                    result.success(
                        mapOf(
                            "spatialAudio" to spatialAudioEnabled,
                            "bitPerfectMode" to bitPerfectMode,
                            "preset" to activePreset,
                            "sleepTimerMinutes" to sleepTimerMinutes
                        )
                    )
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, spectrumChannelName).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    spectrumEventSink = events
                    startSpectrumSimulation()
                }

                override fun onCancel(arguments: Any?) {
                    stopSpectrumSimulation()
                    spectrumEventSink = null
                }
            }
        )
    }

    private fun startSpectrumSimulation() {
        stopSpectrumSimulation()
        spectrumRunnable = object : Runnable {
            override fun run() {
                tickCount++
                val sink = spectrumEventSink ?: return

                val magnitudes = ArrayList<Double>(32)
                val basePhase = tickCount * 0.15
                for (i in 0 until 32) {
                    val harmonic = (sin(basePhase + i * 0.35) * 0.35 + 0.5)
                    val modulation = cos(basePhase * 0.7 + i * 0.2) * 0.15
                    var value = (harmonic + modulation).coerceIn(0.05, 0.98)
                    if (i < 4 && activePreset.contains("Bass")) {
                        value = (value * 1.25).coerceAtMost(1.0)
                    }
                    magnitudes.add(value)
                }

                val payload = mapOf(
                    "bands" to magnitudes,
                    "peakDbfs" to -4.2 - (tickCount % 5) * 0.3,
                    "sampleRate" to if (bitPerfectMode) "192kHz / 24-bit FLAC" else "96kHz / 24-bit MQA",
                    "dynamicRangeScore" to 14.4 + (sin(basePhase) * 0.4),
                    "bufferLatencyMs" to 4.8,
                    "spatialActive" to spatialAudioEnabled
                )

                sink.success(payload)
                mainHandler.postDelayed(this, 250)
            }
        }
        mainHandler.post(spectrumRunnable!!)
    }

    private fun stopSpectrumSimulation() {
        spectrumRunnable?.let { mainHandler.removeCallbacks(it) }
        spectrumRunnable = null
    }

    override fun onDestroy() {
        stopSpectrumSimulation()
        super.onDestroy()
    }
}

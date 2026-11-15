import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private let dspChannelName = "com.safeer.echostream/audio_dsp"
  private let spectrumChannelName = "com.safeer.echostream/pcm_spectrum"

  private var spatialAudioEnabled = true
  private var bitPerfectMode = false
  private var activePreset = "Studio Reference Flat"
  private var equalizerGains: [Double] = Array(repeating: 0.0, count: 10)
  private var sleepTimerMinutes = 0

  private var spectrumEventSink: FlutterEventSink?
  private var spectrumTimer: Timer?
  private var tickCount: Double = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    let dspChannel = FlutterMethodChannel(
      name: dspChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    dspChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      switch call.method {
      case "setEqualizerBands":
        if let args = call.arguments as? [String: Any],
           let bands = args["bands"] as? [Double] {
          self.equalizerGains = bands
          result(["status": "applied", "bandsCount": bands.count])
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Bands array is required", details: nil))
        }
      case "applyDspPreset":
        if let args = call.arguments as? [String: Any],
           let preset = args["preset"] as? String {
          self.activePreset = preset
          result(["status": "applied", "preset": self.activePreset])
        } else {
          result(["status": "applied", "preset": self.activePreset])
        }
      case "toggleSpatialAudio":
        if let args = call.arguments as? [String: Any],
           let enabled = args["enabled"] as? Bool {
          self.spatialAudioEnabled = enabled
          result(["status": "updated", "spatialAudio": self.spatialAudioEnabled])
        } else {
          result(["status": "updated", "spatialAudio": self.spatialAudioEnabled])
        }
      case "setBitPerfectDacMode":
        if let args = call.arguments as? [String: Any],
           let enabled = args["enabled"] as? Bool {
          self.bitPerfectMode = enabled
          result(["status": "updated", "bitPerfectMode": self.bitPerfectMode])
        } else {
          result(["status": "updated", "bitPerfectMode": self.bitPerfectMode])
        }
      case "configureSleepTimer":
        if let args = call.arguments as? [String: Any],
           let minutes = args["minutes"] as? Int {
          self.sleepTimerMinutes = minutes
          result(["status": "configured", "sleepMinutes": self.sleepTimerMinutes])
        } else {
          result(["status": "configured", "sleepMinutes": self.sleepTimerMinutes])
        }
      case "getDspStatus":
        result([
          "spatialAudio": self.spatialAudioEnabled,
          "bitPerfectMode": self.bitPerfectMode,
          "preset": self.activePreset,
          "sleepTimerMinutes": self.sleepTimerMinutes
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let spectrumChannel = FlutterEventChannel(
      name: spectrumChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    spectrumChannel.setStreamHandler(self)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.spectrumEventSink = events
    self.spectrumTimer?.invalidate()
    self.spectrumTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
      guard let self = self, let sink = self.spectrumEventSink else { return }
      self.tickCount += 1
      var bands: [Double] = []
      let basePhase = self.tickCount * 0.15
      for i in 0..<32 {
        let harmonic = (sin(basePhase + Double(i) * 0.35) * 0.35 + 0.5)
        let modulation = cos(basePhase * 0.7 + Double(i) * 0.2) * 0.15
        var value = max(0.05, min(0.98, harmonic + modulation))
        if i < 4 && self.activePreset.contains("Bass") {
          value = min(1.0, value * 1.25)
        }
        bands.append(value)
      }

      let payload: [String: Any] = [
        "bands": bands,
        "peakDbfs": -4.2 - self.tickCount.truncatingRemainder(dividingBy: 5) * 0.3,
        "sampleRate": self.bitPerfectMode ? "192kHz / 24-bit FLAC" : "96kHz / 24-bit MQA",
        "dynamicRangeScore": 14.4 + (sin(basePhase) * 0.4),
        "bufferLatencyMs": 4.8,
        "spatialActive": self.spatialAudioEnabled
      ]
      sink(payload)
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.spectrumTimer?.invalidate()
    self.spectrumTimer = nil
    self.spectrumEventSink = nil
    return nil
  }
}

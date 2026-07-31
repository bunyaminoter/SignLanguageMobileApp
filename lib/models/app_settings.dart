import '../config/constants.dart';

/// Uygulama ayarları modeli
class AppSettings {
  final double confidenceThreshold;
  final bool ttsEnabled;
  final String ttsLanguage;
  final double ttsRate;
  final int inferenceIntervalMs;
  final bool showLandmarks;
  final bool isDarkMode;
  final bool autoSpeak;
  final double videoPlaybackSpeed;

  const AppSettings({
    this.confidenceThreshold = AppConstants.defaultConfidenceThreshold,
    this.ttsEnabled = true,
    this.ttsLanguage = AppConstants.defaultTtsLanguage,
    this.ttsRate = AppConstants.defaultTtsRate,
    this.inferenceIntervalMs = AppConstants.inferenceIntervalMs,
    this.showLandmarks = false,
    this.isDarkMode = true,
    this.autoSpeak = false,
    this.videoPlaybackSpeed = 1.0,
  });

  AppSettings copyWith({
    double? confidenceThreshold,
    bool? ttsEnabled,
    String? ttsLanguage,
    double? ttsRate,
    int? inferenceIntervalMs,
    bool? showLandmarks,
    bool? isDarkMode,
    bool? autoSpeak,
    double? videoPlaybackSpeed,
  }) {
    return AppSettings(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
      ttsRate: ttsRate ?? this.ttsRate,
      inferenceIntervalMs: inferenceIntervalMs ?? this.inferenceIntervalMs,
      showLandmarks: showLandmarks ?? this.showLandmarks,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      autoSpeak: autoSpeak ?? this.autoSpeak,
      videoPlaybackSpeed: videoPlaybackSpeed ?? this.videoPlaybackSpeed,
    );
  }
}

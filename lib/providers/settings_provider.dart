import 'package:flutter/material.dart';
import '../models/app_settings.dart';

/// Ayarlar state yönetimi
class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  // Getter'lar
  double get confidenceThreshold => _settings.confidenceThreshold;
  bool get ttsEnabled => _settings.ttsEnabled;
  String get ttsLanguage => _settings.ttsLanguage;
  double get ttsRate => _settings.ttsRate;
  int get inferenceIntervalMs => _settings.inferenceIntervalMs;
  bool get showLandmarks => _settings.showLandmarks;
  bool get isDarkMode => _settings.isDarkMode;
  bool get autoSpeak => _settings.autoSpeak;

  void updateConfidenceThreshold(double value) {
    _settings = _settings.copyWith(confidenceThreshold: value);
    notifyListeners();
  }

  void toggleTts() {
    _settings = _settings.copyWith(ttsEnabled: !_settings.ttsEnabled);
    notifyListeners();
  }

  void setTtsLanguage(String language) {
    _settings = _settings.copyWith(ttsLanguage: language);
    notifyListeners();
  }

  void setTtsRate(double rate) {
    _settings = _settings.copyWith(ttsRate: rate);
    notifyListeners();
  }

  void setInferenceInterval(int ms) {
    _settings = _settings.copyWith(inferenceIntervalMs: ms);
    notifyListeners();
  }

  void toggleLandmarks() {
    _settings = _settings.copyWith(showLandmarks: !_settings.showLandmarks);
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    notifyListeners();
  }

  void toggleAutoSpeak() {
    _settings = _settings.copyWith(autoSpeak: !_settings.autoSpeak);
    notifyListeners();
  }
}

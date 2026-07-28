import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

/// Ayarlar state yönetimi
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  late AppSettings _settings;

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  void _loadSettings() {
    _settings = AppSettings(
      confidenceThreshold: _prefs.getDouble('confidenceThreshold') ?? 0.7,
      ttsEnabled: _prefs.getBool('ttsEnabled') ?? true,
      ttsLanguage: _prefs.getString('ttsLanguage') ?? 'tr-TR',
      ttsRate: _prefs.getDouble('ttsRate') ?? 1.0,
      inferenceIntervalMs: _prefs.getInt('inferenceIntervalMs') ?? 2000,
      showLandmarks: _prefs.getBool('showLandmarks') ?? true,
      isDarkMode: _prefs.getBool('isDarkMode') ?? true,
      autoSpeak: _prefs.getBool('autoSpeak') ?? false,
    );
  }

  Future<void> _saveSettings() async {
    await _prefs.setDouble('confidenceThreshold', _settings.confidenceThreshold);
    await _prefs.setBool('ttsEnabled', _settings.ttsEnabled);
    await _prefs.setString('ttsLanguage', _settings.ttsLanguage);
    await _prefs.setDouble('ttsRate', _settings.ttsRate);
    await _prefs.setInt('inferenceIntervalMs', _settings.inferenceIntervalMs);
    await _prefs.setBool('showLandmarks', _settings.showLandmarks);
    await _prefs.setBool('isDarkMode', _settings.isDarkMode);
    await _prefs.setBool('autoSpeak', _settings.autoSpeak);
  }

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
    _saveSettings();
    notifyListeners();
  }

  void toggleTts() {
    _settings = _settings.copyWith(ttsEnabled: !_settings.ttsEnabled);
    _saveSettings();
    notifyListeners();
  }

  void setTtsLanguage(String language) {
    _settings = _settings.copyWith(ttsLanguage: language);
    _saveSettings();
    notifyListeners();
  }

  void setTtsRate(double rate) {
    _settings = _settings.copyWith(ttsRate: rate);
    _saveSettings();
    notifyListeners();
  }

  void setInferenceInterval(int ms) {
    _settings = _settings.copyWith(inferenceIntervalMs: ms);
    _saveSettings();
    notifyListeners();
  }

  void toggleLandmarks() {
    _settings = _settings.copyWith(showLandmarks: !_settings.showLandmarks);
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    _saveSettings();
    notifyListeners();
  }

  void toggleAutoSpeak() {
    _settings = _settings.copyWith(autoSpeak: !_settings.autoSpeak);
    _saveSettings();
    notifyListeners();
  }
}

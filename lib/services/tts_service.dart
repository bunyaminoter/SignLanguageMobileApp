import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech servisi
class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  bool get isSpeaking => _isSpeaking;

  /// TTS motorunu başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Metin seslendir
  Future<void> speak(String text, {
    String language = 'en-US',
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    if (!_isInitialized) await initialize();

    if (_isSpeaking) {
      await stop();
    }

    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);

    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Tek kelime seslendir
  Future<void> speakWord(String word, {String language = 'en-US'}) async {
    await speak(word, language: language, rate: 0.5);
  }

  /// Seslendirmeyi durdur
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  /// Kullanılabilir dilleri getir
  Future<List<dynamic>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }

  /// Servisi temizle
  void dispose() {
    _tts.stop();
  }
}

import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../services/stt_service.dart';

class TextToSignProvider extends ChangeNotifier {
  final STTService _sttService = STTService();

  String _inputText = '';
  List<String> _sequenceWords = [];
  int _currentWordIndex = 0;
  bool _isPlaying = false;
  bool _isListening = false;
  double _playbackSpeed = 1.0;

  String get inputText => _inputText;
  List<String> get sequenceWords => _sequenceWords;
  int get currentWordIndex => _currentWordIndex;
  bool get isPlaying => _isPlaying;
  bool get isListening => _isListening;
  double get playbackSpeed => _playbackSpeed;

  String get currentWord =>
      (_sequenceWords.isNotEmpty && _currentWordIndex < _sequenceWords.length)
          ? _sequenceWords[_currentWordIndex]
          : '';

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  /// Metni işleyip kelimelerine ayır
  void convertTextToSignSequence() {
    if (_inputText.trim().isEmpty) return;

    // Metni kelimelere böl (noktalama işaretlerini kaldır, büyük harf yap)
    final words = _inputText
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    _sequenceWords = words;
    _currentWordIndex = 0;
    _isPlaying = words.isNotEmpty;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_sequenceWords.isEmpty) return;
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void nextWord() {
    if (_currentWordIndex < _sequenceWords.length - 1) {
      _currentWordIndex++;
    } else {
      _isPlaying = false; // Dizinin sonuna ulaşıldı
    }
    notifyListeners();
  }

  void previousWord() {
    if (_currentWordIndex > 0) {
      _currentWordIndex--;
      _isPlaying = true;
    }
    notifyListeners();
  }

  void setWordIndex(int index) {
    if (index >= 0 && index < _sequenceWords.length) {
      _currentWordIndex = index;
      _isPlaying = true;
      notifyListeners();
    }
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    notifyListeners();
  }

  /// Sesle Giriş (Speech to Text)
  Future<void> startListening() async {
    _isListening = true;
    notifyListeners();

    await _sttService.startListening(
      onResult: (recognizedText) {
        _inputText = recognizedText;
        _isListening = false;
        notifyListeners();
        convertTextToSignSequence();
      },
    );
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  void clear() {
    _inputText = '';
    _sequenceWords = [];
    _currentWordIndex = 0;
    _isPlaying = false;
    notifyListeners();
  }
}

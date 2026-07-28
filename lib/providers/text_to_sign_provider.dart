import 'package:flutter/foundation.dart';
import '../models/dictionary_word.dart';
import '../services/database_service.dart';
import '../services/stt_service.dart';

class TextToSignProvider extends ChangeNotifier {
  final STTService _sttService = STTService();
  final DatabaseService _dbService = DatabaseService();

  String _inputText = '';
  List<DictionaryWord> _sequenceWords = [];
  int _currentWordIndex = 0;
  bool _isPlaying = false;
  bool _isListening = false;
  double _playbackSpeed = 1.0;

  String get inputText => _inputText;
  List<DictionaryWord> get sequenceWords => _sequenceWords;
  int get currentWordIndex => _currentWordIndex;
  bool get isPlaying => _isPlaying;
  bool get isListening => _isListening;
  double get playbackSpeed => _playbackSpeed;

  DictionaryWord? get currentWord =>
      (_sequenceWords.isNotEmpty && _currentWordIndex < _sequenceWords.length)
          ? _sequenceWords[_currentWordIndex]
          : null;

  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  /// Metni işleyip veritabanında ara (veya harf harf böl)
  Future<void> convertTextToSignSequence() async {
    if (_inputText.trim().isEmpty) return;

    // Metni kelimelere böl (noktalama işaretlerini kaldır, büyük harf yap)
    final words = _inputText
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    List<DictionaryWord> newSequence = [];

    for (var w in words) {
      final dbWord = await _dbService.searchWord(w);
      if (dbWord != null) {
        newSequence.add(dbWord);
      } else {
        // Kelime sözlükte yoksa harf harf (Finger-spelling) ekle
        for (var i = 0; i < w.length; i++) {
          final letter = w[i];
          final dbLetter = await _dbService.searchWord(letter);
          if (dbLetter != null) {
            newSequence.add(dbLetter);
          }
        }
      }
    }

    _sequenceWords = newSequence;
    _currentWordIndex = 0;
    _isPlaying = _sequenceWords.isNotEmpty;
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

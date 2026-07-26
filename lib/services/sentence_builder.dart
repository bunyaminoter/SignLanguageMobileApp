import '../config/constants.dart';

/// Cümle biriktirme servisi - debounce ve tekrar engelleme
class SentenceBuilder {
  final List<String> _words = [];
  String _lastWord = '';
  int _lastTimestamp = 0;
  final int _debounceMs;

  SentenceBuilder({int debounceMs = AppConstants.debounceDurationMs})
      : _debounceMs = debounceMs;

  List<String> get words => List.unmodifiable(_words);
  String get sentence => _words.join(' ');
  bool get isEmpty => _words.isEmpty;
  int get wordCount => _words.length;

  /// Tahmin edilen kelimeyi cümleye ekle
  /// Güven eşiği ve debounce kontrolü yapar
  /// Eklendiyse true döner
  bool addPrediction(String word, double confidence, double threshold) {
    if (confidence < threshold) return false;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Aynı kelime çok kısa sürede tekrar edilmesin
    if (word == _lastWord && (now - _lastTimestamp) < _debounceMs) {
      return false;
    }

    // Maksimum kelime sayısı kontrolü
    if (_words.length >= AppConstants.maxSentenceWords) {
      return false;
    }

    _words.add(word);
    _lastWord = word;
    _lastTimestamp = now;
    return true;
  }

  /// Cümleyi temizle
  void clear() {
    _words.clear();
    _lastWord = '';
    _lastTimestamp = 0;
  }

  /// Son kelimeyi sil
  String? removeLastWord() {
    if (_words.isEmpty) return null;
    final removed = _words.removeLast();
    _lastWord = _words.isNotEmpty ? _words.last : '';
    return removed;
  }
}

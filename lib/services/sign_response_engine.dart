import 'package:flutter/foundation.dart';
import '../models/dictionary_word.dart';
import 'database_service.dart';

/// Gemini yanıt metnini işaret dili video dizisine dönüştüren motor.
/// Her kelimeyi sözlükte arar, bulamazsa harf harf (fingerspelling) çözer.
class SignResponseEngine {
  final DatabaseService _dbService = DatabaseService();

  /// Yanıt metnini kelimelere böler ve her biri için video eşleşmesi arar.
  /// Eşleşmeyen kelimeler harf harf parmak alfabesine dönüştürülür.
  Future<List<DictionaryWord>> processResponse(String responseText) async {
    if (responseText.trim().isEmpty) return [];

    // Metni kelimelere böl (noktalama kaldır, büyük harfe çevir)
    final words = responseText
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    final List<DictionaryWord> signSequence = [];

    for (final word in words) {
      // Sözlükte tam kelime eşleşmesi ara
      final dbWord = await _dbService.searchWord(word);

      if (dbWord != null) {
        // Tam eşleşme bulundu — videosu var
        signSequence.add(dbWord);
        debugPrint('[SignEngine] ✅ Eşleşme: $word');
      } else {
        // Eşleşme yok — harf harf parmak alfabesi (fingerspelling)
        debugPrint('[SignEngine] 🔤 Fingerspelling: $word');
        for (int i = 0; i < word.length; i++) {
          final letter = word[i];
          final dbLetter = await _dbService.searchWord(letter);
          if (dbLetter != null) {
            signSequence.add(dbLetter);
          }
        }
      }
    }

    debugPrint('[SignEngine] 📦 Toplam ${signSequence.length} işaret üretildi.');
    return signSequence;
  }
}

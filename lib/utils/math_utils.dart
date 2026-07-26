import 'dart:math';

/// Matematiksel yardımcı fonksiyonlar
class MathUtils {
  MathUtils._();

  /// Softmax hesapla
  static List<double> softmax(List<double> logits) {
    final maxVal = logits.reduce(max);
    final exps = logits.map((v) => exp(v - maxVal)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((v) => v / sumExps).toList();
  }

  /// Top-K indeks ve değerleri bul
  static List<MapEntry<int, double>> topK(List<double> probs, int k) {
    final indexed = <MapEntry<int, double>>[];
    for (int i = 0; i < probs.length; i++) {
      indexed.add(MapEntry(i, probs[i]));
    }
    indexed.sort((a, b) => b.value.compareTo(a.value));
    return indexed.take(k).toList();
  }
}

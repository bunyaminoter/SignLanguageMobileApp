/// Tek bir tahmin sonucu
class Prediction {
  final String label;
  final double confidence;
  final int classIndex;
  final DateTime timestamp;

  const Prediction({
    required this.label,
    required this.confidence,
    required this.classIndex,
    required this.timestamp,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  Prediction copyWith({
    String? label,
    double? confidence,
    int? classIndex,
    DateTime? timestamp,
  }) {
    return Prediction(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      classIndex: classIndex ?? this.classIndex,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() => 'Prediction($label, $confidencePercent)';
}

/// Model inference sonucu
class PredictionResult {
  final List<Prediction> predictions;
  final int inferenceTimeMs;

  const PredictionResult({
    required this.predictions,
    required this.inferenceTimeMs,
  });

  Prediction? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;
}

/// Geçmiş kaydı
class HistoryEntry {
  final String word;
  final double confidence;
  final DateTime timestamp;

  const HistoryEntry({
    required this.word,
    required this.confidence,
    required this.timestamp,
  });
}

import 'prediction.dart';

/// Tanıma pipeline durumu
class RecognitionState {
  final bool cameraReady;
  final bool modelLoaded;
  final bool isProcessing;
  final String statusMessage;
  final Prediction? currentPrediction;
  final List<Prediction> topKPredictions;
  final List<String> sentenceBuffer;
  final List<HistoryEntry> history;
  final int fps;
  final String? errorMessage;
  final int lastInferenceTimeMs;
  final String? smoothedSentence;
  final bool isSmoothing;

  const RecognitionState({
    this.cameraReady = false,
    this.modelLoaded = false,
    this.isProcessing = false,
    this.statusMessage = 'Hazır',
    this.currentPrediction,
    this.topKPredictions = const [],
    this.sentenceBuffer = const [],
    this.history = const [],
    this.fps = 0,
    this.errorMessage,
    this.lastInferenceTimeMs = 0,
    this.smoothedSentence,
    this.isSmoothing = false,
  });

  String get sentence => sentenceBuffer.join(' ');
  bool get hasPrediction => currentPrediction != null;
  bool get hasError => errorMessage != null;

  RecognitionState copyWith({
    bool? cameraReady,
    bool? modelLoaded,
    bool? isProcessing,
    String? statusMessage,
    Prediction? currentPrediction,
    bool clearPrediction = false,
    List<Prediction>? topKPredictions,
    List<String>? sentenceBuffer,
    List<HistoryEntry>? history,
    int? fps,
    String? errorMessage,
    bool clearError = false,
    int? lastInferenceTimeMs,
    String? smoothedSentence,
    bool clearSmoothed = false,
    bool? isSmoothing,
  }) {
    return RecognitionState(
      cameraReady: cameraReady ?? this.cameraReady,
      modelLoaded: modelLoaded ?? this.modelLoaded,
      isProcessing: isProcessing ?? this.isProcessing,
      statusMessage: statusMessage ?? this.statusMessage,
      currentPrediction:
          clearPrediction ? null : (currentPrediction ?? this.currentPrediction),
      topKPredictions: topKPredictions ?? this.topKPredictions,
      sentenceBuffer: sentenceBuffer ?? this.sentenceBuffer,
      history: history ?? this.history,
      fps: fps ?? this.fps,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastInferenceTimeMs: lastInferenceTimeMs ?? this.lastInferenceTimeMs,
      smoothedSentence: clearSmoothed ? null : (smoothedSentence ?? this.smoothedSentence),
      isSmoothing: isSmoothing ?? this.isSmoothing,
    );
  }
}


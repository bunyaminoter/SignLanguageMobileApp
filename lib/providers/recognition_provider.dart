import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../models/recognition_state.dart';
import '../services/asl_model_service.dart';
import '../services/sentence_builder.dart';
import '../services/tts_service.dart';

/// Tanıma pipeline state yönetimi
class RecognitionProvider extends ChangeNotifier {
  final ASLModelService _modelService = ASLModelService();
  final SentenceBuilder _sentenceBuilder = SentenceBuilder();
  final TTSService _ttsService = TTSService();

  RecognitionState _state = const RecognitionState();
  bool _isRecognizing = false;

  /// Mevcut devam eden inference'ı iptal etmek için kullanılır
  Completer<void>? _cancelCompleter;
  dynamic _activeCameraController;

  RecognitionState get state => _state;
  TTSService get ttsService => _ttsService;
  SentenceBuilder get sentenceBuilder => _sentenceBuilder;
  bool get isRecognizing => _isRecognizing;

  /// Model ve servisleri başlat
  Future<void> initialize({
    void Function(double progress)? onProgress,
  }) async {
    try {
      // TTS başlat
      await _ttsService.initialize();

      // Model yükle
      await _modelService.loadModel(onProgress: onProgress);

      _state = _state.copyWith(modelLoaded: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Başlatma hatası: $e');
      notifyListeners();
    }
  }

  /// Kamera hazır olduğunda çağrılır
  void setCameraReady(bool ready) {
    _state = _state.copyWith(cameraReady: ready);
    notifyListeners();
  }

  /// Tanımayı tek atımlık (single-shot) olarak başlat
  Future<void> startRecognition(dynamic cameraController) async {
    if (_isRecognizing) return;

    if (cameraController == null || !(cameraController.value?.isInitialized ?? false)) {
      _state = _state.copyWith(
        errorMessage: 'Kamera henüz hazır değil! Lütfen kameranın açılmasını bekleyin.',
        statusMessage: '⚠️ Kamera Hazır Değil',
      );
      notifyListeners();
      return;
    }

    if (!_state.modelLoaded) {
      _state = _state.copyWith(
        errorMessage: 'Model henüz yüklenmedi! Lütfen bekleyin veya sunucuyu kontrol edin.',
        statusMessage: '⚠️ Model Yüklenmedi',
      );
      notifyListeners();
      return;
    }

    // Sıfırdan başla: Eski hataları ve tahminleri temizle
    _isRecognizing = true;
    _activeCameraController = cameraController;
    _state = _state.copyWith(
      statusMessage: '🔴 Tanıma Başlatıldı',
      clearError: true,
      clearPrediction: true,
      topKPredictions: [],
      isProcessing: false,
    );
    notifyListeners();

    try {
      await captureAndPredict(cameraController);
    } finally {
      // Çekim/tahmin işlemi tamamlandığında otomatik olarak Start moduna dön
      _isRecognizing = false;
      notifyListeners();
    }
  }

  /// Tanımayı **anında** durdur
  void stopRecognition() {
    _isRecognizing = false;

    // Devam eden HTTP isteğini iptal sinyali ver
    _cancelCompleter?.complete();
    _cancelCompleter = null;

    // Kamera hâlâ kaydediyorsa kaydı durdur
    _tryStopCameraRecording();

    // Devam eden HTTP isteğini iptal et
    _modelService.cancelPendingRequest();

    _state = _state.copyWith(
      isProcessing: false,
      statusMessage: '⏸️ Tanıma Durduruldu',
    );
    notifyListeners();
  }

  /// Kameranın aktif kaydını güvenli şekilde durdur
  Future<void> _tryStopCameraRecording() async {
    try {
      final ctrl = _activeCameraController;
      if (ctrl != null) {
        final bool isRecording = ctrl.value?.isRecordingVideo ?? false;
        if (isRecording) {
          await ctrl.stopVideoRecording();
        }
      }
    } catch (_) {
      // Zaten durmuşsa sorun yok
    }
  }

  /// Kamera denetleyicisi ile kısa video çekip gerçek model tahmini al
  Future<void> captureAndPredict(dynamic cameraController) async {
    if (_state.isProcessing || !_state.modelLoaded || cameraController == null) {
      return;
    }

    try {
      final bool isInitialized = cameraController.value?.isInitialized ?? false;
      if (!isInitialized) {
        _state = _state.copyWith(
          errorMessage: 'Kamera bağlantısı kesildi!',
          statusMessage: '⚠️ Kamera Başarısız',
        );
        notifyListeners();
        return;
      }

      _state = _state.copyWith(
        isProcessing: true,
        statusMessage: '⏳ Algılama başlatılıyor...',
        clearError: true,
      );
      notifyListeners();

      // Kamera kaydı başlamadan önce 2 saniye hazırlık gecikmesi
      _cancelCompleter = Completer<void>();
      try {
        await Future.any([
          Future.delayed(const Duration(seconds: 2)),
          _cancelCompleter!.future,
        ]);
      } catch (_) {}

      // İptal sinyali geldiyse dur
      if (!_isRecognizing) return;

      final bool isRecording = cameraController.value?.isRecordingVideo ?? false;
      if (!isRecording) {
        _state = _state.copyWith(
          statusMessage: '🔴 2s Video Kaydediliyor...',
        );
        notifyListeners();

        await cameraController.startVideoRecording();

        // 2.0 saniye kayıt yaparken dur sinyalini kontrol et
        _cancelCompleter = Completer<void>();
        try {
          await Future.any([
            Future.delayed(const Duration(milliseconds: 2000)),
            _cancelCompleter!.future,
          ]);
        } catch (_) {}

        // İptal sinyali geldiyse kaydı bitirip çık
        if (!_isRecognizing) {
          try {
            await cameraController.stopVideoRecording();
          } catch (_) {}
          return;
        }

        final dynamic videoFile = await cameraController.stopVideoRecording();

        if (videoFile != null && videoFile.path != null) {
          _state = _state.copyWith(
            statusMessage: '⚡ Sunucuya Gönderiliyor ve Analiz Ediliyor...',
          );
          notifyListeners();

          final result = await _modelService.predict(videoPath: videoFile.path);

          final topLabel = result.topPrediction?.label ?? '';
          _state = _state.copyWith(
            currentPrediction: result.topPrediction,
            topKPredictions: result.predictions,
            lastInferenceTimeMs: result.inferenceTimeMs,
            statusMessage: topLabel.isNotEmpty
                ? '✅ Algılandı: $topLabel'
                : '✅ Analiz Tamamlandı',
          );

          if (result.topPrediction != null) {
            addCurrentPredictionToSentence(0.30);
          }
        } else {
          _state = _state.copyWith(
            errorMessage: 'Video dosyası oluşturulamadı (Kamera kaydı boş döndü).',
            statusMessage: '⚠️ Video Kayıt Hatası',
          );
        }
      }
    } catch (e) {
      debugPrint('[ASL Provider] Video prediction exception: $e');
      final cleanMsg = e.toString()
          .replaceAll('HttpException: ', '')
          .replaceAll('StateError: ', '');
      _state = _state.copyWith(
        errorMessage: cleanMsg,
        statusMessage: '⚠️ Sunucu / Analiz Hatası',
      );
    } finally {
      _state = _state.copyWith(isProcessing: false);
      notifyListeners();
    }
  }

  /// Mevcut tahmini cümleye ekle
  bool addCurrentPredictionToSentence(double threshold) {
    final prediction = _state.currentPrediction;
    if (prediction == null) return false;

    final added = _sentenceBuilder.addPrediction(
      prediction.label,
      prediction.confidence,
      threshold,
    );

    if (added) {
      _state = _state.copyWith(
        sentenceBuffer: List.from(_sentenceBuilder.words),
        history: [
          ..._state.history,
          HistoryEntry(
            word: prediction.label,
            confidence: prediction.confidence,
            timestamp: DateTime.now(),
          ),
        ],
      );
      notifyListeners();
    }

    return added;
  }

  /// Cümleyi seslendir
  Future<void> speakSentence({
    String language = 'en-US',
    double rate = 0.5,
  }) async {
    final sentence = _sentenceBuilder.sentence;
    if (sentence.isEmpty) return;

    await _ttsService.speak(sentence, language: language, rate: rate);
  }

  /// Tek kelimeyi seslendir
  Future<void> speakWord(String word, {String language = 'en-US'}) async {
    await _ttsService.speakWord(word, language: language);
  }

  /// Cümleyi ve mevcut tahmini tamamen temizle (yeniden algılamaya hazırla)
  void clearSentence() {
    _sentenceBuilder.clear();
    _state = _state.copyWith(
      sentenceBuffer: [],
      clearPrediction: true,
      topKPredictions: [],
      isProcessing: false,
    );
    notifyListeners();
  }

  /// Son kelimeyi sil
  void undoLastWord() {
    _sentenceBuilder.removeLastWord();
    _state = _state.copyWith(
      sentenceBuffer: List.from(_sentenceBuilder.words),
    );
    notifyListeners();
  }

  /// Geçmişi temizle
  void clearHistory() {
    _state = _state.copyWith(history: []);
    notifyListeners();
  }

  /// FPS güncelle
  void updateFps(int fps) {
    _state = _state.copyWith(fps: fps);
    notifyListeners();
  }

  /// Hatayı temizle
  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  @override
  void dispose() {
    _isRecognizing = false;
    _cancelCompleter?.complete();
    _modelService.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}

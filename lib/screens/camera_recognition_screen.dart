import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/recognition_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/translation_helper.dart';
import '../widgets/action_buttons.dart';
import '../widgets/camera_preview.dart';
import '../widgets/prediction_card.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/top_predictions.dart';

/// Kamera ile İşaret Dili Tanıma Ekranı (ASL -> Metin/Ses)
class CameraRecognitionScreen extends StatefulWidget {
  final bool isActiveTab;

  const CameraRecognitionScreen({
    super.key,
    required this.isActiveTab,
  });

  @override
  State<CameraRecognitionScreen> createState() => _CameraRecognitionScreenState();
}

class _CameraRecognitionScreenState extends State<CameraRecognitionScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActiveTab) {
      _initCamera();
    }
  }

  @override
  void didUpdateWidget(covariant CameraRecognitionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActiveTab != oldWidget.isActiveTab) {
      if (widget.isActiveTab) {
        _initCamera();
      } else {
        _disposeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    if (mounted) {
      setState(() => _isCameraInitialized = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActiveTab) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _currentCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (_currentCameraIndex == -1) _currentCameraIndex = 0;

      await _setupCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    await _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.low, // Düşük çözünürlük: hızlı upload + hızlı inference
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        context.read<RecognitionProvider>().setCameraReady(true);
      }
    } catch (e) {
      debugPrint('Camera setup error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;

    setState(() => _isCameraInitialized = false);
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final recognitionProvider = context.watch<RecognitionProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final state = recognitionProvider.state;
    final isDark = settingsProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBg, const Color(0xFF12122A)]
                : [AppColors.lightBg, AppColors.lightCard],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Üst Bar ───
              _buildTopBar(context, state.fps),

              // ─── Hata Bildirimi (Varsa) ───
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            translateProviderMessage(state.errorMessage!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => recognitionProvider.clearError(),
                          child: const Icon(Icons.close, color: Colors.white54, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── Kamera Alanı ───
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CameraPreviewWidget(
                    controller: _isCameraInitialized ? _cameraController : null,
                    fps: state.fps,
                    isRecognizing: recognitionProvider.isRecognizing,
                    isProcessing: state.isProcessing,
                    statusMessage: translateProviderMessage(state.statusMessage),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── Tahmin Kartı ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PredictionCard(
                  prediction: state.currentPrediction,
                  isProcessing: state.isProcessing,
                  inferenceTimeMs: state.lastInferenceTimeMs,
                ),
              ),

              // ─── Top-K Tahminler ───
              TopPredictions(predictions: state.topKPredictions),

              // ─── Cümle Alanı ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SentenceBar(
                  words: state.sentenceBuffer,
                  onClear: () => recognitionProvider.clearSentence(),
                  onUndo: () => recognitionProvider.undoLastWord(),
                ),
              ),
              const SizedBox(height: 8),

              // ─── Aksiyon Butonları ───
              ActionButtons(
                isRecognizing: recognitionProvider.isRecognizing,
                isSpeaking: recognitionProvider.ttsService.isSpeaking,
                onSpeak: () {
                  recognitionProvider.speakSentence(
                    language: settingsProvider.ttsLanguage,
                    rate: settingsProvider.ttsRate,
                  );
                },
                onToggleRecognition: () {
                  if (recognitionProvider.isRecognizing) {
                    recognitionProvider.stopRecognition();
                  } else {
                    recognitionProvider.startRecognition(_cameraController);
                  }
                },
                onClear: () => recognitionProvider.clearSentence(),
                onToggleCamera: _toggleCamera,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int fps) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_front_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'camera.title'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _TopBarButton(
                icon: Icons.history_rounded,
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
              const SizedBox(width: 8),
              _TopBarButton(
                icon: Icons.tune_rounded,
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withAlpha(180)
              : AppColors.lightCard.withAlpha(180),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

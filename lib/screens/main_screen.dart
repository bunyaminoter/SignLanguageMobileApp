import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/recognition_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/action_buttons.dart';
import '../widgets/camera_preview.dart';
import '../widgets/prediction_card.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/top_predictions.dart';

/// Ana ekran — Kamera + Tahmin + Cümle
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Ön kamerayı tercih et (işaret dili için)
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
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBg,
              Color(0xFF12122A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Üst Bar ───
              _buildTopBar(context, state.fps),

              // ─── Kamera Alanı ───
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CameraPreviewWidget(
                    controller:
                        _isCameraInitialized ? _cameraController : null,
                    fps: state.fps,
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Başlık
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
                  Icons.sign_language_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ASL Translator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // Sağ butonlar
          Row(
            children: [
              // Geçmiş butonu
              _TopBarButton(
                icon: Icons.history_rounded,
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
              const SizedBox(width: 8),
              // Ayarlar butonu
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkCard.withAlpha(180),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}

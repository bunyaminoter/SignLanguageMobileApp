import 'package:flutter/material.dart';
import '../config/colors.dart';

/// Animasyonlu açılış ekranı — model yükleme göstergeli
class SplashScreen extends StatefulWidget {
  final Future<void> Function(void Function(double)) onLoad;
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onLoad,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  String _statusText = 'Initializing...';
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _startLoading();
  }

  Future<void> _startLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _statusText = 'Loading ASL model...');

    await widget.onLoad((progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
          if (progress < 0.3) {
            _statusText = 'Loading model weights...';
          } else if (progress < 0.6) {
            _statusText = 'Initializing inference engine...';
          } else if (progress < 0.9) {
            _statusText = 'Preparing class labels...';
          } else {
            _statusText = 'Almost ready!';
          }
        });
      }
    });

    if (mounted) {
      setState(() {
        _statusText = 'Ready! ✨';
        _progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 600));
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBg,
              Color(0xFF1A1040),
              AppColors.darkBg,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo/İkon
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPurple.withAlpha(80),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sign_language_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Başlık
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ).createShader(bounds),
                      child: const Text(
                        'ASL Translator',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time Sign Language Recognition',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkTextMuted,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const Spacer(),

                    // Yükleme çubuğu
                    Column(
                      children: [
                        // Yüzde
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _progress),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                backgroundColor:
                                    AppColors.primaryPurple.withAlpha(30),
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryPurple,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Durum metni
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _statusText,
                            key: ValueKey(_statusText),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Alt bilgi
                    Text(
                      'Powered by Hybrid ASL Model',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextMuted.withAlpha(100),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

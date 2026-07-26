import 'package:flutter/material.dart';
import '../config/colors.dart';

/// Alt aksiyon butonları satırı
class ActionButtons extends StatelessWidget {
  final VoidCallback? onSpeak;
  final VoidCallback? onClear;
  final VoidCallback? onToggleCamera;
  final VoidCallback? onToggleRecognition;
  final bool isRecognizing;
  final bool isSpeaking;

  const ActionButtons({
    super.key,
    this.onSpeak,
    this.onClear,
    this.onToggleCamera,
    this.onToggleRecognition,
    this.isRecognizing = false,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Seslendir butonu
          _ActionBtn(
            icon: isSpeaking
                ? Icons.stop_circle_rounded
                : Icons.volume_up_rounded,
            label: isSpeaking ? 'Stop' : 'Speak',
            onTap: onSpeak,
            gradient: AppColors.accentGradient,
          ),

          // Tanıma başlat/durdur
          _ActionBtn(
            icon: isRecognizing
                ? Icons.pause_circle_rounded
                : Icons.play_circle_rounded,
            label: isRecognizing ? 'Pause' : 'Start',
            onTap: onToggleRecognition,
            gradient: isRecognizing
                ? AppColors.warmGradient
                : AppColors.successGradient,
            isLarge: true,
          ),

          // Temizle butonu
          _ActionBtn(
            icon: Icons.delete_sweep_rounded,
            label: 'Clear',
            onTap: onClear,
            gradient: [
              AppColors.darkTextMuted,
              AppColors.darkTextSecondary,
            ],
          ),

          // Kamera değiştir
          _ActionBtn(
            icon: Icons.cameraswitch_rounded,
            label: 'Camera',
            onTap: onToggleCamera,
            gradient: [
              AppColors.primaryIndigo,
              AppColors.primaryBlue,
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final List<Color> gradient;
  final bool isLarge;

  const _ActionBtn({
    required this.icon,
    required this.label,
    this.onTap,
    required this.gradient,
    this.isLarge = false,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isLarge ? 60.0 : 48.0;
    final iconSize = widget.isLarge ? 28.0 : 22.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size / 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradient.first.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.darkTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

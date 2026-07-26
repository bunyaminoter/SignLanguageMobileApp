import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/text_to_sign_provider.dart';

/// ASL İşaret Dili Video/İşaret Oynatıcısı
class SignVideoPlayer extends StatefulWidget {
  const SignVideoPlayer({super.key});

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  Timer? _playbackTimer;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _startTimer(TextToSignProvider provider) {
    _playbackTimer?.cancel();
    if (!provider.isPlaying || provider.sequenceWords.isEmpty) return;

    final durationMs = (1500 / provider.playbackSpeed).round();
    _playbackTimer = Timer.periodic(Duration(milliseconds: durationMs), (_) {
      if (mounted) {
        final p = context.read<TextToSignProvider>();
        if (p.isPlaying) {
          p.nextWord();
          if (!p.isPlaying) {
            _playbackTimer?.cancel();
          }
        } else {
          _playbackTimer?.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TextToSignProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Timer durumunu güncelle
    if (provider.isPlaying && (_playbackTimer == null || !_playbackTimer!.isActive)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer(provider));
    } else if (!provider.isPlaying) {
      _playbackTimer?.cancel();
    }

    if (provider.sequenceWords.isEmpty) {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sign_language_rounded,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Metin veya Sesli Cümle Girin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'İşaret dili videoları sırayla oynatılacaktır',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final currentWord = provider.currentWord;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── Video Display Screen (Simulation Canvas) ───
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E1E38),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plan ışık efekti
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                  ),
                ),

                // İşaret Dili Animasyon Görseli/İkonu
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Container(
                        key: ValueKey(currentWord),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.back_hand_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Aktif Kelime Etiketi
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        currentWord,
                        key: ValueKey(currentWord),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // Sol Üst: Kelime Sayacı (X / Y)
                Positioned(
                  top: 14,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.currentWordIndex + 1} / ${provider.sequenceWords.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Sağ Üst: Hız Göstergesi
                Positioned(
                  top: 14,
                  right: 16,
                  child: PopupMenuButton<double>(
                    initialValue: provider.playbackSpeed,
                    onSelected: (speed) => provider.setPlaybackSpeed(speed),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${provider.playbackSpeed}x',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 0.5, child: Text('0.5x Yavaş')),
                      const PopupMenuItem(value: 1.0, child: Text('1.0x Normal')),
                      const PopupMenuItem(value: 1.5, child: Text('1.5x Hızlı')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Alt Kelime Şeridi (Word Sequence Subtitles) ───
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: isDark ? AppColors.darkCard : Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: provider.sequenceWords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final word = entry.value;
                  final isCurrent = index == provider.currentWordIndex;

                  return GestureDetector(
                    onTap: () => provider.setWordIndex(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent
                              ? Colors.white
                              : (isDark ? AppColors.darkText : AppColors.lightText),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Oynatma Kontrol Düğmeleri ───
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Önceki Kelime
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 28),
                  onPressed: provider.currentWordIndex > 0 ? () => provider.previousWord() : null,
                  color: isDark ? Colors.white : Colors.black87,
                ),

                // Oynat / Duraklat
                GestureDetector(
                  onTap: () => provider.togglePlayPause(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryGradient),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Sonraki Kelime
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 28),
                  onPressed: provider.currentWordIndex < provider.sequenceWords.length - 1
                      ? () => provider.nextWord()
                      : null,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

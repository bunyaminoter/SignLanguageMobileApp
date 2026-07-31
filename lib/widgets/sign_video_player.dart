import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/settings_provider.dart';
import '../providers/text_to_sign_provider.dart';
import 'cached_video_player.dart';

/// ASL İşaret Dili Video/İşaret Oynatıcısı (Faz 6 & 7)
class SignVideoPlayer extends StatefulWidget {
  const SignVideoPlayer({super.key});

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TextToSignProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSpeed = provider.getPlaybackSpeed(settings.videoPlaybackSpeed);

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
                color: AppColors.primary.withValues(alpha: 0.1),
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
              'sign_player.empty_title'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'sign_player.empty_desc'.tr(),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final currentWord = provider.currentWord;
    final currentWordText = currentWord?.word ?? '';
    final videoUrl = currentWord?.videoUrl ?? '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── Video Display Screen ───
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              color: isDark ? const Color(0xFF0F0F23) : Colors.black87,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (videoUrl.isNotEmpty)
                  CachedVideoPlayerWidget(
                    key: ValueKey('${videoUrl}_$currentSpeed'),
                    videoUrl: videoUrl,
                    autoPlay: provider.isPlaying,
                    loop: false, // Arka arkaya oynaması için loop false
                    borderRadius: 24,
                    playbackSpeed: currentSpeed,
                    onVideoFinished: () {
                      if (provider.isPlaying && mounted) {
                        provider.nextWord();
                      }
                    },
                  )
                else
                  Center(
                    child: Text(
                      'sign_player.no_video'.tr(),
                      style: const TextStyle(color: Colors.white54),
                    ),
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
                    initialValue: currentSpeed,
                    onSelected: (speed) {
                      provider.setTempPlaybackSpeed(speed);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${currentSpeed}x',
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
                      PopupMenuItem(value: 0.5, child: Text('sign_player.speed_slow'.tr())),
                      PopupMenuItem(value: 1.0, child: Text('sign_player.speed_normal'.tr())),
                      PopupMenuItem(value: 1.5, child: Text('sign_player.speed_fast'.tr())),
                      PopupMenuItem(value: 2.0, child: Text('2.0x')),
                    ],
                  ),
                ),
                
                // Alt Orta: Aktif Kelime Etiketi (Altyazı gibi)
                Positioned(
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      currentWordText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
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
                        word.word,
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

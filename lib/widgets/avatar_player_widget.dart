import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/settings_provider.dart';
import '../providers/sign_ai_provider.dart';
import 'cached_video_player.dart';

/// AI yanıtını işaret dili videoları halinde oynatan üst bölge widget'ı.
/// Home Screen'in üst %35'ini kaplar.
class AvatarPlayerWidget extends StatelessWidget {
  const AvatarPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignAiProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentWord = provider.currentSignWord;
    final videoUrl = currentWord?.videoUrl ?? '';
    final hasSequence = provider.activeSignSequence.isNotEmpty;
    final currentSpeed = provider.getPlaybackSpeed(settings.videoPlaybackSpeed);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D1F) : Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: hasSequence ? _buildActivePlayer(provider, videoUrl, currentSpeed, isDark) : _buildIdleState(isDark),
      ),
    );
  }

  Widget _buildIdleState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animasyonlu ikon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'sign_ai.avatar_idle_title'.tr(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'sign_ai.avatar_idle_desc'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlayer(SignAiProvider provider, String videoUrl, double speed, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Video oynatıcı
        if (videoUrl.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CachedVideoPlayerWidget(
              key: ValueKey('${videoUrl}_$speed'),
              videoUrl: videoUrl,
              autoPlay: provider.isPlayingSigns,
              loop: false,
              borderRadius: 0,
              fit: BoxFit.contain,
              playbackSpeed: speed,
              onVideoFinished: () {
                provider.nextSign();
              },
            ),
          )
        else
          const Center(
            child: Icon(
              Icons.videocam_off_rounded,
              size: 40,
              color: Colors.white38,
            ),
          ),

        // Sol üst: kelime sayacı
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${provider.currentSignIndex + 1} / ${provider.activeSignSequence.length}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Sağ üst: Hız Ayarı ve AI Rozeti
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hız Butonu
              PopupMenuButton<double>(
                initialValue: speed,
                onSelected: (newSpeed) {
                  provider.setTempPlaybackSpeed(newSpeed);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${speed}x',
                        style: const TextStyle(
                          fontSize: 10,
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
              const SizedBox(width: 6),
              // AI Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'SignAI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Alt: aktif kelime altyazısı
        if (provider.currentSignWord != null)
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                provider.currentSignWord!.word,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

        // Oynat/duraklat üst katman
        if (!provider.isPlayingSigns && provider.activeSignSequence.isNotEmpty)
          GestureDetector(
            onTap: () => provider.togglePlayPause(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

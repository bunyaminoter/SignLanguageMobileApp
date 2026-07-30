import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/colors.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'home.welcome'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'home.app_name'.tr(),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        size: 26,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Banner ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'home.banner.badge'.tr(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'home.banner.title'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'home.banner.desc'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.swap_horizontal_circle_rounded,
                      size: 48,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Hızlı Erişim Kartları ───
              Text(
                'home.modes_title'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 14),

              // Kart 1: Kamera ile İşaret Dili Tanıma
              FeatureCard(
                title: 'home.cards.camera.title'.tr(),
                subtitle: 'home.cards.camera.desc'.tr(),
                icon: Icons.camera_front_rounded,
                badgeText: 'home.cards.camera.badge'.tr(),
                gradientColors: const [
                  Color(0xFF3B82F6),
                  Color(0xFF1D4ED8),
                ],
                onTap: () => onNavigateTab(1), // Kamera sekmesine git
              ),
              const SizedBox(height: 16),

              // Kart 2: Metin/Sesten İşaret Dilinize Çeviri
              FeatureCard(
                title: 'home.cards.voice.title'.tr(),
                subtitle: 'home.cards.voice.desc'.tr(),
                icon: Icons.record_voice_over_rounded,
                badgeText: 'home.cards.voice.badge'.tr(),
                gradientColors: const [
                  Color(0xFF10B981),
                  Color(0xFF047857),
                ],
                onTap: () => onNavigateTab(2), // Çevir sekmesine git
              ),
              const SizedBox(height: 16),

              // Kart 3: ASL Sözlük
              FeatureCard(
                title: 'home.cards.dictionary.title'.tr(),
                subtitle: 'home.cards.dictionary.desc'.tr(),
                icon: Icons.menu_book_rounded,
                badgeText: 'home.cards.dictionary.badge'.tr(),
                gradientColors: const [
                  Color(0xFFF59E0B),
                  Color(0xFFD97706),
                ],
                onTap: () => onNavigateTab(3), // Sözlük sekmesine git
              ),
            ],
          ),
        ),
      ),
    );
  }
}

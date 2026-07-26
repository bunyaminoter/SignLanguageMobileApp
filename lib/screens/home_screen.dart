import 'package:flutter/material.dart';
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
                        'Hoş Geldiniz 👋',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ASL Çevirmen',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sign_language_rounded,
                      size: 26,
                      color: AppColors.primary,
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
                      color: const Color(0xFF6366F1).withOpacity(0.3),
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Çift Yönlü Çeviri',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Engelleri Kaldıran İletişim',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kameradan metne veya sesinizi işaret diline çevirin.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
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
                'Çeviri Modları',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 14),

              // Kart 1: Kamera ile İşaret Dili Tanıma
              FeatureCard(
                title: 'İşaret Dili ➔ Metin / Ses',
                subtitle: 'Kameranızı tutarak işaret dilini canlı algılayın ve sese çevirin.',
                icon: Icons.camera_front_rounded,
                badgeText: 'CANLI ALGILAMA',
                gradientColors: const [
                  Color(0xFF3B82F6),
                  Color(0xFF1D4ED8),
                ],
                onTap: () => onNavigateTab(1), // Kamera sekmesine git
              ),
              const SizedBox(height: 16),

              // Kart 2: Metin/Sesten İşaret Dilinize Çeviri
              FeatureCard(
                title: 'Metin / Ses ➔ İşaret Dili',
                subtitle: 'Konuşun veya yazın, ASL videoları sırayla oynatılsın.',
                icon: Icons.record_voice_over_rounded,
                badgeText: 'VİDEO ÇEVİRİCİ',
                gradientColors: const [
                  Color(0xFF10B981),
                  Color(0xFF047857),
                ],
                onTap: () => onNavigateTab(2), // Çevir sekmesine git
              ),
              const SizedBox(height: 16),

              // Kart 3: ASL Sözlük
              FeatureCard(
                title: 'ASL İşaret Sözlüğü',
                subtitle: '100+ işaret dili kelimesini arayın ve videolarını izleyin.',
                icon: Icons.menu_book_rounded,
                badgeText: 'KÜTÜPHANE',
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

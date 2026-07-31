import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/sign_ai_provider.dart';
import '../widgets/avatar_player_widget.dart';
import '../widgets/chat_stream_view.dart';
import '../widgets/camera_input_toolbar.dart';

/// SignAI — Ana Sayfa: İşitme Engelliler İçin Yapay Zeka Sohbet Asistanı.
/// Kullanıcı kamera, klavye veya mikrofon ile soru sorar,
/// AI kısa yanıt verir ve yanıt işaret dili videoları olarak oynatılır.
class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // SignAI servisini arka planda başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignAiProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          bottom: false,
          child: Column(
            children: [
              // ─── Üst Bar ───
              _buildTopBar(isDark),

              // ─── Avatar Player (Üst %35) ───
              const Expanded(
                flex: 35,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: AvatarPlayerWidget(),
                ),
              ),

              // ─── Kelime Şeridi (Aktif video dizisi) ───
              _buildSignSequenceStrip(isDark),

              // ─── Sohbet Alanı (Orta %45) ───
              const Expanded(
                flex: 45,
                child: ChatStreamView(),
              ),

              // ─── Öneri Chip'leri ───
              _buildSuggestionChips(isDark),

              // ─── Giriş Araç Çubuğu (Alt %20) ───
              CameraInputToolbar(
                onCameraTap: () => widget.onNavigateTab(1), // Kamera sekmesine geç
                onMicTap: _onMicrophoneTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SignAI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'sign_ai.subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Sohbeti temizle
              _buildTopBarButton(
                icon: Icons.refresh_rounded,
                onTap: () {
                  context.read<SignAiProvider>().clearChat();
                },
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              // Ayarlar
              _buildTopBarButton(
                icon: Icons.settings_rounded,
                onTap: () => Navigator.pushNamed(context, '/settings'),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withAlpha(180)
              : AppColors.lightCard.withAlpha(200),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildSignSequenceStrip(bool isDark) {
    final provider = context.watch<SignAiProvider>();
    if (provider.activeSignSequence.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.activeSignSequence.length,
        itemBuilder: (context, index) {
          final word = provider.activeSignSequence[index];
          final isCurrent = index == provider.currentSignIndex;

          return GestureDetector(
            onTap: () => provider.setSignIndex(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: isCurrent
                    ? const LinearGradient(colors: AppColors.primaryGradient)
                    : null,
                color: isCurrent
                    ? null
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: Center(
                child: Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent
                        ? Colors.white
                        : (isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionChips(bool isDark) {
    final provider = context.watch<SignAiProvider>();
    if (provider.messages.isNotEmpty) return const SizedBox.shrink();

    final suggestions = [
      'sign_ai.suggestion_1'.tr(),
      'sign_ai.suggestion_2'.tr(),
      'sign_ai.suggestion_3'.tr(),
    ];

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => provider.sendTextInput(suggestions[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                suggestions[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.primary : AppColors.primaryPurple,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onMicrophoneTap() {
    // STT servisi entegrasyonu — ileride geliştirilecek
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('sign_ai.mic_coming_soon'.tr()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

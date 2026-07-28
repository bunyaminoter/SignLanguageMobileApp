import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/settings_provider.dart';

/// Ayarlar ekranı
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBg, const Color(0xFF12122A)]
                : [AppColors.lightBg, AppColors.lightSurface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst Bar
              _buildAppBar(context, isDark),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),

                    // ─── Tanıma Ayarları ───
                    _buildSectionHeader('settings.sections.recognition'.tr(), Icons.psychology_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildSliderTile(
                          title: 'settings.items.confidence'.tr(),
                          subtitle:
                              '${(settings.confidenceThreshold * 100).toInt()}%',
                          value: settings.confidenceThreshold,
                          min: 0.3,
                          max: 0.95,
                          onChanged: settings.updateConfidenceThreshold,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSliderTile(
                          title: 'settings.items.interval'.tr(),
                          subtitle: '${settings.inferenceIntervalMs}ms',
                          value: settings.inferenceIntervalMs.toDouble(),
                          min: 1000,
                          max: 5000,
                          divisions: 8,
                          onChanged: (v) =>
                              settings.setInferenceInterval(v.toInt()),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Ses Ayarları ───
                    _buildSectionHeader(
                        'settings.sections.tts'.tr(), Icons.record_voice_over_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: 'settings.items.enable_tts'.tr(),
                          subtitle: 'settings.items.enable_tts_sub'.tr(),
                          value: settings.ttsEnabled,
                          onChanged: (_) => settings.toggleTts(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          title: 'settings.items.auto_speak'.tr(),
                          subtitle: 'settings.items.auto_speak_sub'.tr(),
                          value: settings.autoSpeak,
                          onChanged: (_) => settings.toggleAutoSpeak(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildDropdownTile(
                          title: 'settings.items.tts_lang'.tr(),
                          value: settings.ttsLanguage,
                          items: const {
                            'en-US': 'English (US)',
                            'en-GB': 'English (UK)',
                            'tr-TR': 'Türkçe',
                          },
                          onChanged: (v) => settings.setTtsLanguage(v!),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSliderTile(
                          title: 'settings.items.tts_rate'.tr(),
                          subtitle: '${settings.ttsRate.toStringAsFixed(1)}x',
                          value: settings.ttsRate,
                          min: 0.25,
                          max: 2.0,
                          onChanged: settings.setTtsRate,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Görünüm Ayarları ───
                    _buildSectionHeader('settings.sections.appearance'.tr(), Icons.palette_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: 'settings.items.dark_mode'.tr(),
                          subtitle: 'settings.items.dark_mode_sub'.tr(),
                          value: settings.isDarkMode,
                          onChanged: (_) => settings.toggleDarkMode(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          title: 'settings.items.landmarks'.tr(),
                          subtitle: 'settings.items.landmarks_sub'.tr(),
                          value: settings.showLandmarks,
                          onChanged: (_) => settings.toggleLandmarks(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildDropdownTile(
                          title: 'settings.items.app_lang'.tr(),
                          value: context.locale.languageCode,
                          items: const {
                            'en': 'English',
                            'tr': 'Türkçe',
                          },
                          onChanged: (v) {
                            if (v != null) {
                              context.setLocale(Locale(v, v == 'en' ? 'US' : 'TR'));
                            }
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Veri & Önbellek ───
                    _buildSectionHeader('settings.sections.data'.tr(), Icons.storage_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          title: Text(
                            'settings.items.clear_cache'.tr(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          subtitle: Text(
                            'settings.items.clear_cache_sub'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          trailing: Icon(Icons.delete_sweep_rounded, color: AppColors.primaryPurple, size: 24),
                          onTap: () async {
                            await DefaultCacheManager().emptyCache();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('settings.items.cache_cleared'.tr()),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Uygulama Bilgileri ───
                    _buildSectionHeader('settings.sections.about'.tr(), Icons.info_outline_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildInfoTile(
                          title: 'settings.items.version'.tr(),
                          value: '1.0.0',
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildInfoTile(
                          title: 'settings.items.model'.tr(),
                          value: 'Hybrid ASL (10-Class Baseline)',
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildInfoTile(
                          title: 'settings.items.classes'.tr(),
                          value: '10 ASL Signs',
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard.withAlpha(180)
                    : AppColors.lightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color:
                    isDark ? AppColors.darkTextSecondary : AppColors.lightText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'settings.title'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryPurple),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple.withAlpha(200),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withAlpha(180)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: isDark
          ? AppColors.darkBorder.withAlpha(80)
          : AppColors.lightBorder,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryPurple,
        activeThumbColor: Colors.white,
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required bool isDark,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor:
            isDark ? AppColors.darkCard : AppColors.lightSurface,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        items: items.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

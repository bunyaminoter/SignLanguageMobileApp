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
                    _buildSectionHeader('Recognition', Icons.psychology_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildSliderTile(
                          title: 'Confidence Threshold',
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
                          title: 'Inference Interval',
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
                        'Text-to-Speech', Icons.record_voice_over_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: 'Enable TTS',
                          subtitle: 'Read recognized signs aloud',
                          value: settings.ttsEnabled,
                          onChanged: (_) => settings.toggleTts(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          title: 'Auto-Speak',
                          subtitle: 'Speak each word automatically',
                          value: settings.autoSpeak,
                          onChanged: (_) => settings.toggleAutoSpeak(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildDropdownTile(
                          title: 'Language',
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
                          title: 'Speech Rate',
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
                    _buildSectionHeader('Appearance', Icons.palette_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildSwitchTile(
                          title: 'Dark Mode',
                          subtitle: 'Toggle dark/light theme',
                          value: settings.isDarkMode,
                          onChanged: (_) => settings.toggleDarkMode(),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          title: 'Show Landmarks',
                          subtitle: 'Display pose landmarks on camera',
                          value: settings.showLandmarks,
                          onChanged: (_) => settings.toggleLandmarks(),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Uygulama Bilgileri ───
                    _buildSectionHeader('About', Icons.info_outline_rounded),
                    _buildCard(
                      isDark: isDark,
                      children: [
                        _buildInfoTile(
                          title: 'Version',
                          value: '1.0.0',
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildInfoTile(
                          title: 'Model',
                          value: 'Hybrid ASL (10-Class Baseline)',
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildInfoTile(
                          title: 'Classes',
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
            'Settings',
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

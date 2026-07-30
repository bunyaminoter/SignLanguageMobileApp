import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/colors.dart';

/// Cümle biriktirme alanı
class SentenceBar extends StatelessWidget {
  final List<String> words;
  final VoidCallback? onClear;
  final VoidCallback? onUndo;

  const SentenceBar({
    super.key,
    required this.words,
    this.onClear,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withAlpha(150)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                    size: 14,
                    color: AppColors.primaryPurple.withAlpha(180),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'sentence.title'.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryPurple.withAlpha(180),
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (words.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${words.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple.withAlpha(200),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (words.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMiniButton(
                      icon: Icons.undo_rounded,
                      onTap: onUndo,
                      context: context,
                    ),
                    const SizedBox(width: 4),
                    _buildMiniButton(
                      icon: Icons.clear_all_rounded,
                      onTap: onClear,
                      context: context,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Cümle metni
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: words.isEmpty
                ? Text(
                    key: const ValueKey('empty'),
                    'sentence.empty'.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : SizedBox(
                    key: ValueKey(words.length),
                    width: double.infinity,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: words.asMap().entries.map((entry) {
                        final isLast = entry.key == words.length - 1;
                        return AnimatedScale(
                          scale: isLast ? 1.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AppColors.primaryPurple.withAlpha(25)
                                  : (isDark
                                      ? AppColors.darkCardLight
                                      : AppColors.lightCard),
                              borderRadius: BorderRadius.circular(8),
                              border: isLast
                                  ? Border.all(
                                      color:
                                          AppColors.primaryPurple.withAlpha(60),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isLast
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isLast
                                    ? AppColors.primaryPurple
                                    : (isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback? onTap,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardLight
              : AppColors.lightCard,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }
}

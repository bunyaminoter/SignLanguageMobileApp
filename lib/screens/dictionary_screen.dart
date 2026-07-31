import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../models/dictionary_word.dart';
import '../providers/dictionary_provider.dart';
import '../widgets/cached_video_player.dart';
/// ASL İşaret Dili Sözlüğü Ekranı
class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DictionaryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final words = provider.filteredWords;

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                        'dictionary.header'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'dictionary.title'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 24,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Arama Çubuğu ───
              TextField(
                onChanged: (q) => provider.setSearchQuery(q),
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                decoration: InputDecoration(
                  hintText: 'dictionary.search_hint'.tr(),
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ─── Kategori Filtreleri ───
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: provider.categories.map((cat) {
                    final isSelected = provider.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => provider.setCategory(cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.darkText : AppColors.lightText),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Kelime Listesi Grid ───
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : words.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'dictionary.no_results'.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        itemCount: words.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.25,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final word = words[index];
                          return _WordCard(word: word, isDark: isDark);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final DictionaryWord word;
  final bool isDark;

  const _WordCard({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showWordDetailsDialog(context, word, isDark);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.front_hand_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    word.category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  word.description.isNotEmpty 
                      ? word.description 
                      : 'dictionary.word_desc'.tr(args: [word.word]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetailsDialog(BuildContext context, DictionaryWord word, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // İşaret Kartı/Animasyonu
              SizedBox(
                height: 220,
                width: double.infinity,
                child: word.videoUrl.isNotEmpty
                    ? CachedVideoPlayerWidget(
                        videoUrl: word.videoUrl,
                        autoPlay: true,
                        loop: true,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text('dictionary.no_video'.tr()),
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              Text(
                word.description.isNotEmpty 
                    ? word.description 
                    : 'dictionary.word_desc'.tr(args: [word.word]),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'dictionary.close'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

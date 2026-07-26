import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../models/prediction.dart';
import '../providers/recognition_provider.dart';

/// Geçmiş tahminler ekranı
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recognitionProvider = context.watch<RecognitionProvider>();
    final history = recognitionProvider.state.history;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkBg, Color(0xFF12122A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst Bar
              _buildAppBar(context, history.length, recognitionProvider),

              // Liste
              Expanded(
                child: history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(history),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int count,
      RecognitionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withAlpha(180),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.darkBorder,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (count > 0)
            GestureDetector(
              onTap: () => provider.clearHistory(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.darkTextMuted.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            'No predictions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkTextMuted.withAlpha(150),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start recognizing signs to build history',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextMuted.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryEntry> history) {
    // Ters sırada göster (en yeni en üstte)
    final reversed = history.reversed.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: reversed.length,
      itemBuilder: (context, index) {
        final entry = reversed[index];
        final color = AppColors.confidenceColor(entry.confidence);
        final timeAgo = _formatTimeAgo(entry.timestamp);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkCard.withAlpha(180),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.darkBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Sıra numarası
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${history.length - index}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Kelime
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Güven skoru
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${(entry.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

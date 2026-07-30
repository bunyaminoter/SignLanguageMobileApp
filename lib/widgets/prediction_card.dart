import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config/colors.dart';
import '../models/prediction.dart';
import 'confidence_meter.dart';

/// Ana tahmin kartı — büyük font ile tahmin gösterimi
class PredictionCard extends StatelessWidget {
  final Prediction? prediction;
  final bool isProcessing;
  final int inferenceTimeMs;

  const PredictionCard({
    super.key,
    this.prediction,
    this.isProcessing = false,
    this.inferenceTimeMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(prediction?.label ?? 'empty'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCard.withAlpha(200)
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: prediction != null
                ? AppColors.confidenceColor(prediction!.confidence)
                    .withAlpha(80)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.5,
          ),
          boxShadow: prediction != null
              ? [
                  BoxShadow(
                    color: AppColors.confidenceColor(prediction!.confidence)
                        .withAlpha(30),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: prediction != null
            ? _buildPredictionContent(context)
            : _buildEmptyContent(context),
      ),
    );
  }

  Widget _buildPredictionContent(BuildContext context) {
    final pred = prediction!;
    final color = AppColors.confidenceColor(pred.confidence);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Üst bilgi: emoji + inference süresi + isProcessing durumu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'prediction.top_prediction'.tr(),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                if (isProcessing) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'prediction.analyzing'.tr(),
                          style: const TextStyle(
                            color: AppColors.accentCyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (inferenceTimeMs > 0 && !isProcessing)
              Text(
                '⚡ ${inferenceTimeMs}ms',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w600,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Ana tahmin kelimesi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              pred.label.toUpperCase(),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              pred.confidencePercent,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color.withAlpha(180),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Güven göstergesi
        ConfidenceMeter(
          confidence: pred.confidence,
          height: 6,
          showLabel: false,
        ),
      ],
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isProcessing
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                  ),
                )
              : Icon(
                  Icons.sign_language_rounded,
                  key: const ValueKey('icon'),
                  size: 40,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withAlpha(100),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          isProcessing ? 'prediction.analyzing_short'.tr() : 'prediction.show_sign'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withAlpha(150),
              ),
        ),
      ],
    );
  }
}

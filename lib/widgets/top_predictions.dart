import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/prediction.dart';

/// Top-K tahmin listesi
class TopPredictions extends StatelessWidget {
  final List<Prediction> predictions;

  const TopPredictions({super.key, required this.predictions});

  @override
  Widget build(BuildContext context) {
    if (predictions.length <= 1) return const SizedBox.shrink();

    // İlk tahmini atla (zaten PredictionCard'da gösteriliyor)
    final otherPredictions = predictions.skip(1).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: otherPredictions.asMap().entries.map((entry) {
          final idx = entry.key;
          final pred = entry.value;
          final color = AppColors.confidenceColor(pred.confidence);

          return Flexible(
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 300 + idx * 100),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withAlpha(40),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${idx + 2}.',
                      style: TextStyle(
                        color: color.withAlpha(120),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        pred.label,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pred.confidencePercent,
                      style: TextStyle(
                        color: color.withAlpha(150),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

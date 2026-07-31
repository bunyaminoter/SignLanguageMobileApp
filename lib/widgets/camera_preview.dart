import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../config/colors.dart';

/// Kamera önizleme widget'ı
class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final bool showOverlay;
  final int fps;
  final bool isRecognizing;
  final bool isProcessing;
  final String? statusMessage;

  const CameraPreviewWidget({
    super.key,
    this.controller,
    this.showOverlay = true,
    this.fps = 0,
    this.isRecognizing = false,
    this.isProcessing = false,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Kamera aspect ratio'su (ön kamera genelde 4:3 yatayda → dikeyde 3:4)
    final double cameraAspectRatio =
        (controller != null && controller!.value.isInitialized)
            ? (1 / controller!.value.aspectRatio) // Dikey moda çevir
            : (3 / 4); // Varsayılan portre oranı

    return AspectRatio(
      aspectRatio: cameraAspectRatio.clamp(0.5, 0.85), // 9:16 ile 3:4 arası sınırla
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isRecognizing
                  ? AppColors.error.withAlpha(150)
                  : AppColors.darkBorder,
              width: isRecognizing ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Kamera görüntüsü — FittedBox ile oranı koruyarak kırp
              if (controller != null && controller!.value.isInitialized)
                ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: controller!.value.previewSize!.height,
                      height: controller!.value.previewSize!.width,
                      child: CameraPreview(controller!),
                    ),
                  ),
                )
              else
                _buildPlaceholder(),

              // Overlay bilgiler
              if (showOverlay) ...[
                // FPS göstergesi
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildFpsBadge(),
                ),

                // REC göstergesi (tanıma sırasında)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildRecBadge(),
                ),

                // Canlı Durum Banner'ı (Kamera altında)
                if (statusMessage != null && statusMessage!.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(180),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isProcessing ? AppColors.accentCyan : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isProcessing) ...[
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              statusMessage!,
                              style: TextStyle(
                                color: isProcessing ? AppColors.accentCyan : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Alt gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(120),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(19),
                        bottomRight: Radius.circular(19),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkCard,
            AppColors.darkSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              size: 48,
              color: AppColors.darkTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'camera_preview.initializing'.tr(),
              style: const TextStyle(
                color: AppColors.darkTextMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFpsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withAlpha(20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.speed_rounded,
            size: 12,
            color: AppColors.accentCyan,
          ),
          const SizedBox(width: 4),
          Text(
            '$fps FPS',
            style: const TextStyle(
              color: AppColors.accentCyan,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecBadge() {
    final active = isRecognizing || isProcessing;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.error : Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? AppColors.error : Colors.white.withAlpha(20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fiber_manual_record,
            size: 10,
            color: active ? Colors.white : AppColors.darkTextMuted,
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'camera_preview.rec'.tr() : 'camera_preview.ready'.tr(),
            style: TextStyle(
              color: active ? Colors.white : AppColors.darkTextMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

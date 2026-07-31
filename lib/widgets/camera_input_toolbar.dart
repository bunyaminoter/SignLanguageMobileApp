import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/sign_ai_provider.dart';

/// Alt giriş araç çubuğu — metin girişi, kamera ve mikrofon butonları.
/// Home Screen'in alt %20'sini kaplar.
class CameraInputToolbar extends StatefulWidget {
  final VoidCallback? onCameraTap;
  final VoidCallback? onMicTap;

  const CameraInputToolbar({
    super.key,
    this.onCameraTap,
    this.onMicTap,
  });

  @override
  State<CameraInputToolbar> createState() => _CameraInputToolbarState();
}

class _CameraInputToolbarState extends State<CameraInputToolbar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(SignAiProvider provider) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    provider.sendTextInput(text);
    _textController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignAiProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Kamera butonu
            _buildCircleButton(
              icon: Icons.camera_alt_rounded,
              gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              onTap: widget.onCameraTap,
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // Metin giriş alanı
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkCard
                      : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'sign_ai.input_hint'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(provider),
                        maxLines: 1,
                      ),
                    ),
                    // Mikrofon butonu (metin alanı içinde)
                    GestureDetector(
                      onTap: widget.onMicTap,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.mic_rounded,
                          size: 22,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Gönder butonu
            _buildCircleButton(
              icon: Icons.send_rounded,
              gradient: AppColors.primaryGradient,
              onTap: provider.isProcessing
                  ? null
                  : () => _sendMessage(provider),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: onTap != null
              ? LinearGradient(colors: gradient)
              : null,
          color: onTap == null
              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
              : null,
          shape: BoxShape.circle,
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? Colors.white
              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        ),
      ),
    );
  }
}

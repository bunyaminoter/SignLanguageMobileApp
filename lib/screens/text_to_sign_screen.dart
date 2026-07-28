import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/text_to_sign_provider.dart';
import '../widgets/sign_video_player.dart';

/// Metin ve Sesten İşaret Diline Çeviri Ekranı (Text/Speech -> ASL Video Sequence)
class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final TextEditingController _textController = TextEditingController();

  final List<String> _quickPhrases = [
    'HELLO COMPUTER',
    'DRINK WATER',
    'BEFORE CHAIR',
    'NO HELP',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onConvert(TextToSignProvider provider) {
    if (_textController.text.trim().isNotEmpty) {
      provider.setInputText(_textController.text);
      provider.convertTextToSignSequence();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TextToSignProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                        'Konuş & Yaz',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Metin ➔ ASL İşareti',
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
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      size: 24,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Metin & Ses Giriş Kutusu ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Çevirmek istediğiniz cümleyi yazın veya mikrofona konuşun...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (text) => provider.setInputText(text),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Mikrofon ile Sesli Giriş Butonu
                        GestureDetector(
                          onTap: () {
                            if (provider.isListening) {
                              provider.stopListening();
                            } else {
                              provider.startListening();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: provider.isListening
                                  ? AppColors.error.withValues(alpha: 0.15)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: provider.isListening ? AppColors.error : AppColors.primary,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  provider.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                  size: 18,
                                  color: provider.isListening ? AppColors.error : AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  provider.isListening ? 'Dinleniyor...' : 'Mikrofon',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: provider.isListening ? AppColors.error : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Çevir / Oynat Butonu
                        ElevatedButton.icon(
                          onPressed: () => _onConvert(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text(
                            'İşaretleri Oynat',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── Örnek Hızlı Cümleler ───
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickPhrases.map((phrase) {
                    return GestureDetector(
                      onTap: () {
                        _textController.text = phrase;
                        provider.setInputText(phrase);
                        provider.convertTextToSignSequence();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              phrase,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Sign Video Player ───
              Text(
                'ASL İşaret Dizilimi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),

              const SignVideoPlayer(),
            ],
          ),
        ),
      ),
    );
  }
}

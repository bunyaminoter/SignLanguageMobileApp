import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/constants.dart';

/// Gemini API ile iletişim kuran servis sınıfı.
/// SignAI sohbet asistanı ve Gloss-to-Text düzeltici için kullanılır.
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _signAiModel;
  GenerativeModel? _glossModel;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Gemini modellerini başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiKey = AppConstants.geminiApiKey;
      if (apiKey == 'YOUR_API_KEY_HERE' || apiKey.isEmpty) {
        debugPrint('[GeminiService] ⚠️ API key ayarlanmamış! '
            'constants.dart dosyasında geminiApiKey değerini güncelleyin.');
        return;
      }

      // SignAI Sohbet Asistanı modeli (system prompt ile)
      _signAiModel = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: apiKey,
        systemInstruction: Content.system(AppConstants.geminiSignAiSystemPrompt),
        generationConfig: GenerationConfig(
          maxOutputTokens: 100, // Kısa yanıtlar için yeterli
          temperature: 0.7,
        ),
      );

      // Gloss-to-Text Düzeltici modeli (ayrı system prompt ile)
      _glossModel = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: apiKey,
        systemInstruction: Content.system(AppConstants.geminiGlossToTextPrompt),
        generationConfig: GenerationConfig(
          maxOutputTokens: 150,
          temperature: 0.3, // Düşük yaratıcılık, yüksek doğruluk
        ),
      );

      // Sohbet oturumu başlat (bağlamsal konuşma için)
      _chatSession = _signAiModel!.startChat();

      _isInitialized = true;
      debugPrint('[GeminiService] ✅ Gemini modelleri başarıyla başlatıldı.');
    } catch (e) {
      debugPrint('[GeminiService] ❌ Başlatma hatası: $e');
      _isInitialized = false;
    }
  }

  /// SignAI sohbet asistanı — kullanıcı mesajını gönderir, kısa yanıt alır.
  /// Chat session kullanarak bağlamsal konuşma sağlar.
  Future<String> sendMessage(String userMessage) async {
    if (!_isInitialized || _chatSession == null) {
      debugPrint('[GeminiService] Model başlatılmamış, initialize() çağrılıyor...');
      await initialize();
      if (!_isInitialized) {
        return 'AI service not available. Please set API key.';
      }
    }

    try {
      debugPrint('\n========== [DEBUG: GEMINI PIPELINE START] ==========');
      debugPrint('[DEBUG] 1. SYSTEM PROMPT:');
      debugPrint(AppConstants.geminiSignAiSystemPrompt);
      debugPrint('[DEBUG] 2. USER MESSAGE: $userMessage');
      debugPrint('[DEBUG] 3. MODEL CONFIG: model=${AppConstants.geminiModel}, temp=0.7, maxTokens=100');

      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );
      final text = response.text?.trim() ?? '';
      
      debugPrint('[DEBUG] 4. RAW GEMINI RESPONSE:');
      debugPrint(text);
      debugPrint('========== [DEBUG: GEMINI PIPELINE END] ==========\n');
      
      return text;
    } catch (e) {
      debugPrint('\n========== [DEBUG: GEMINI PIPELINE ERROR] ==========');
      debugPrint('[DEBUG] ❌ Mesaj gönderme hatası: $e');
      debugPrint('========== [DEBUG: GEMINI PIPELINE ERROR END] ==========\n');
      return 'Error: $e';
    }
  }

  /// Gloss-to-Text: Ham kök kelimeleri akıcı bir cümleye dönüştürür.
  /// Örnek: ["I", "TEA", "WANT"] → "I want tea."
  Future<String> glossToText(List<String> glossWords) async {
    if (!_isInitialized || _glossModel == null) {
      await initialize();
      if (!_isInitialized) {
        // Fallback: kelimeleri birleştir
        return glossWords.join(' ');
      }
    }

    if (glossWords.isEmpty) return '';

    try {
      final input = glossWords.join(' ');
      final response = await _glossModel!.generateContent([
        Content.text(input),
      ]);
      final smoothed = response.text?.trim() ?? input;
      debugPrint('[GeminiService] 🔄 Gloss: $input → $smoothed');
      return smoothed;
    } catch (e) {
      debugPrint('[GeminiService] ❌ Gloss-to-Text hatası: $e');
      // Hata durumunda ham kelimeleri döndür
      return glossWords.join(' ');
    }
  }

  /// Sohbet oturumunu sıfırla (yeni konuşma başlat)
  void resetChat() {
    if (_signAiModel != null) {
      _chatSession = _signAiModel!.startChat();
      debugPrint('[GeminiService] 🔄 Sohbet oturumu sıfırlandı.');
    }
  }

  void dispose() {
    _chatSession = null;
    _signAiModel = null;
    _glossModel = null;
    _isInitialized = false;
  }
}

import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/dictionary_word.dart';
import '../services/gemini_service.dart';
import '../services/sign_response_engine.dart';

/// SignAI sohbet ekranının state yönetimi.
/// Chat mesajları, Gemini API iletişimi ve video dizisi yönetimini sağlar.
class SignAiProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final SignResponseEngine _signEngine = SignResponseEngine();

  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  bool _isInitialized = false;

  // Aktif AI yanıtının video dizisi oynatma durumu
  List<DictionaryWord> _activeSignSequence = [];
  int _currentSignIndex = 0;
  bool _isPlayingSigns = false;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;
  bool get isInitialized => _isInitialized;
  List<DictionaryWord> get activeSignSequence => _activeSignSequence;
  int get currentSignIndex => _currentSignIndex;
  bool get isPlayingSigns => _isPlayingSigns;

  DictionaryWord? get currentSignWord =>
      (_activeSignSequence.isNotEmpty && _currentSignIndex < _activeSignSequence.length)
          ? _activeSignSequence[_currentSignIndex]
          : null;

  /// Gemini servisini başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    await _geminiService.initialize();
    _isInitialized = _geminiService.isInitialized;
    notifyListeners();
  }

  /// Kullanıcıdan metin girişi ile mesaj gönder
  Future<void> sendTextInput(String text) async {
    if (text.trim().isEmpty) return;
    await _processUserMessage(text.trim());
  }

  /// Kameradan gelen tanıma sonucu ile mesaj gönder
  Future<void> sendCameraInput(String recognizedText) async {
    if (recognizedText.trim().isEmpty) return;
    await _processUserMessage(recognizedText.trim());
  }

  /// Mesaj işleme pipeline
  Future<void> _processUserMessage(String text) async {
    // 1. Kullanıcı mesajını ekle
    _messages.add(ChatMessage.user(text));
    notifyListeners();

    // 2. Loading göster
    _isProcessing = true;
    _messages.add(ChatMessage.loading());
    notifyListeners();

    try {
      // 3. Gemini'ye gönder
      final aiResponse = await _geminiService.sendMessage(text);

      // 4. Yanıtı video dizisine çevir
      final signSequence = await _signEngine.processResponse(aiResponse);

      // 5. Loading mesajını kaldır ve gerçek yanıtı ekle
      _messages.removeLast(); // loading mesajını kaldır
      
      debugPrint('[DEBUG] 5. FINAL DISPLAYED RESPONSE in UI: $aiResponse');
      debugPrint('[DEBUG] 6. VIDEO MAPPED TOKENS: ${signSequence.map((e) => e.word).toList()}');
      
      _messages.add(ChatMessage.ai(aiResponse, signSequence: signSequence));

      // 6. Video dizisini aktif olarak ayarla
      if (signSequence.isNotEmpty) {
        _activeSignSequence = signSequence;
        _currentSignIndex = 0;
        _isPlayingSigns = true;
      }
    } catch (e) {
      debugPrint('[SignAiProvider] ❌ Hata: $e');
      _messages.removeLast(); // loading mesajını kaldır
      _messages.add(ChatMessage.ai('Error: $e'));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Belirli bir AI mesajının video dizisini oynat
  void playSignSequence(ChatMessage message) {
    if (!message.hasSignSequence) return;
    _activeSignSequence = message.signSequence!;
    _currentSignIndex = 0;
    _isPlayingSigns = true;
    notifyListeners();
  }

  /// Sonraki işarete geç
  void nextSign() {
    if (_currentSignIndex < _activeSignSequence.length - 1) {
      _currentSignIndex++;
    } else {
      _isPlayingSigns = false; // Dizinin sonuna ulaşıldı
    }
    notifyListeners();
  }

  /// Önceki işarete dön
  void previousSign() {
    if (_currentSignIndex > 0) {
      _currentSignIndex--;
      _isPlayingSigns = true;
    }
    notifyListeners();
  }

  /// Belirli bir indeksteki işarete atla
  void setSignIndex(int index) {
    if (index >= 0 && index < _activeSignSequence.length) {
      _currentSignIndex = index;
      _isPlayingSigns = true;
      notifyListeners();
    }
  }

  /// Oynatmayı duraklat/devam ettir
  void togglePlayPause() {
    if (_activeSignSequence.isEmpty) return;
    _isPlayingSigns = !_isPlayingSigns;
    notifyListeners();
  }

  /// Video oynatmayı durdur
  void stopSigns() {
    _isPlayingSigns = false;
    _currentSignIndex = 0;
    _activeSignSequence = [];
    notifyListeners();
  }

  /// Tüm sohbeti temizle
  void clearChat() {
    _messages.clear();
    _activeSignSequence = [];
    _currentSignIndex = 0;
    _isPlayingSigns = false;
    _geminiService.resetChat();
    notifyListeners();
  }

  @override
  void dispose() {
    _geminiService.dispose();
    super.dispose();
  }
}

import 'dictionary_word.dart';

/// Sohbet mesajı gönderici tipi
enum MessageSender {
  user,
  ai,
}

/// Bir sohbet mesajını temsil eder (kullanıcı veya AI)
class ChatMessage {
  final MessageSender sender;
  final String text;
  final List<DictionaryWord>? signSequence;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.sender,
    required this.text,
    this.signSequence,
    required this.timestamp,
    this.isLoading = false,
  });

  /// Kullanıcı mesajı oluşturma kolaylığı
  factory ChatMessage.user(String text) {
    return ChatMessage(
      sender: MessageSender.user,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  /// AI yanıtı oluşturma kolaylığı
  factory ChatMessage.ai(String text, {List<DictionaryWord>? signSequence}) {
    return ChatMessage(
      sender: MessageSender.ai,
      text: text,
      signSequence: signSequence,
      timestamp: DateTime.now(),
    );
  }

  /// Yükleniyor durumunda placeholder mesaj
  factory ChatMessage.loading() {
    return ChatMessage(
      sender: MessageSender.ai,
      text: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// Kopyalama (immutable güncellemeler için)
  ChatMessage copyWith({
    MessageSender? sender,
    String? text,
    List<DictionaryWord>? signSequence,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      sender: sender ?? this.sender,
      text: text ?? this.text,
      signSequence: signSequence ?? this.signSequence,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;
  bool get hasSignSequence =>
      signSequence != null && signSequence!.isNotEmpty;
}

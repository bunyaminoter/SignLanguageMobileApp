import 'package:easy_localization/easy_localization.dart';

/// Provider'dan gelen key-bazlı mesajları çevirir.
/// Mesajlar "key" veya "key|param" formatında gelir.
/// Eğer mesaj bir çeviri anahtarıysa çevirir, değilse olduğu gibi döner.
String translateProviderMessage(String? message) {
  if (message == null || message.isEmpty) return '';

  // Pipe ile ayrılmış parametreli mesaj kontrolü (ör: "errors.init_error|detay")
  if (message.contains('|')) {
    final parts = message.split('|');
    final key = parts[0];
    final param = parts.sublist(1).join('|');

    // Çeviri anahtarı mı kontrol et
    final translated = key.tr(args: [param]);
    if (translated != key) return translated;

    // Çeviri bulunamadıysa orijinal mesajı döndür
    return '$key: $param';
  }

  // Basit anahtar (parametre yok)
  final translated = message.tr();
  if (translated != message) return translated;

  // Çeviri bulunamadıysa orijinal mesajı döndür (ham hata metinleri için)
  return message;
}

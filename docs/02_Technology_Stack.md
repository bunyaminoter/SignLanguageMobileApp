# 02 - Teknoloji Yığını (Technology Stack)

## Amaç
Bu belge, ASL projesinde fiilen kullanılan ve gelecekte kullanılması planlanan teknolojileri, alternatiflerini ve neden tercih edildiklerini açıklamaktadır.

## İçindekiler
1. Flutter
2. Provider (State Management)
3. Makine Öğrenmesi ve Donanım (Camera, ML)
4. Sesten Metne ve Metinden Sese (STT / TTS)
5. GoRouter (Navigasyon)
6. Planlanan Teknolojiler (Cloudflare, SQLite, Cache Manager)
7. AI Implementation Notes

---

## 1. Flutter
**Nedir?** Google tarafından geliştirilen, tek bir kod tabanından iOS ve Android uygulamaları oluşturmaya yarayan açık kaynaklı UI framework'üdür.

## 2. Provider (State Management)
**Nedir?** Flutter uygulamasındaki verileri (`state`) ağaç yapısındaki widget'lara kolayca dağıtmayı sağlayan popüler durum yönetimi paketidir.
**Neden Kullanıldı?** Flutter ekibi tarafından önerilen, anlaşılması ve kurulması en kolay kütüphanedir. Karmaşık ML (Kamera) akışlarını `ChangeNotifier` ile dinlemek projeyi hızlandırmıştır.
**Kullanılan Sınıflar:** `ChangeNotifier`, `ChangeNotifierProvider`, `Consumer`.

## 3. Makine Öğrenmesi ve Donanım (Camera)
* **`camera` (Eklenti):** Cihazın kamerasına doğrudan erişip Frame'leri (kareleri) anlık yakalar.
* **Makine Öğrenmesi Modeli:** ASL el hareketlerini algılayan, eğitilmiş TFLite veya benzeri Edge AI modeli.
**Neden Kullanıldı?** ASL işaretlerini algılamak ve bunları metne ("A", "B", "Hello") dökmek bitirme projesinin çekirdek özelliğidir.

## 4. Sesten Metne ve Metinden Sese (STT / TTS)
* **`speech_to_text`:** Sağır ve dilsiz bireylerin ASL kullanamayan kişilerle iletişim kurması için, karşı tarafın konuşmasını metne çevirir.
* **`flutter_tts`:** Kullanıcının (veya ASL sisteminin) ürettiği metni yüksek sesle okuyarak engelsiz iletişim sağlar.

## 5. GoRouter (Navigasyon)
**Nedir?** Sayfalar arası geçişi yöneten, modern ve "deep-linking" destekli yönlendirme kütüphanesidir. Geleneksel `Navigator.push` yerine kullanılır.

---

## 6. Planlanan Teknolojiler (Gelecek Fazlar)
Uygulamanın "Sözlük" (Dictionary) ve "Text-to-ASL" özellikleri için aşağıdaki araçların projeye dahil edilmesi planlanmaktadır:
* **SQLite:** Binlerce kelimelik sözlüğü cihazda tutmak için.
* **Cloudflare R2:** Videoların 0$ bant genişliği maliyetiyle yayınlanması için.
* **flutter_cache_manager:** R2'dan inen videoların internetsiz çalışabilmesi için cihazda tutulması.
* **video_player:** Videoları ekranda oynatmak için. (Şu an pubspec'te eklidir).

---

## AI IMPLEMENTATION NOTES
* UI Framework: `flutter`
* State Management: `provider` (NOT Riverpod/Bloc).
* Hardware APIs: `camera`, `speech_to_text`, `flutter_tts`.
* Routing: `go_router`.
* When generating code for state, extend `ChangeNotifier`, register in `main.dart` inside a `MultiProvider`, and use `context.read<T>()` or `context.watch<T>()`.

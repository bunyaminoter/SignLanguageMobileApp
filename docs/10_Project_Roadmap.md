# 10 - Proje Yol Haritası (Project Roadmap)

## Amaç
Bu belge, bitirme projesi olarak geliştirilen ASL Mobil Uygulamasının hangi aşamalardan geçtiğini ve planlanan gelecek fazların başarı kriterlerini (Acceptance Criteria) belirler.

## İçindekiler
* Faz 1: Temel Arayüz ve Navigasyon (Tamamlandı)
* Faz 2: Kamera Tanıma (ML) ve Ses Servisleri (Tamamlandı)
* Faz 3: Temel Sözlük ve Örnek Veriler (Tamamlandı)
* Faz 4: Yerel Veritabanı (SQLite)
* Faz 5: Bulut Entegrasyonu (Cloudflare R2)
* Faz 6: Önbellekleme ve Video Oynatma (Caching)
* Faz 7: Metinden ASL Videolarına Çeviri (Text to ASL)
* AI Implementation Notes

---

### Faz 1: Temel Arayüz ve Navigasyon (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Çıktılar:** Uygulamanın temel ekranları (Splash, Home, Main Navigation), tema ayarları ve `go_router` bağlantılarının yapılması.

### Faz 2: Kamera Tanıma (ML) ve Ses Servisleri (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Çıktılar:** `asl_model_service` (Yapay Zeka kamera tanıma), `stt_service` (Sesten Metne) ve `tts_service` (Metinden Sese) modüllerinin `Provider` yapılarıyla entegre edilmesi.

### Faz 3: Temel Sözlük ve Örnek Veriler (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Çıktılar:** `dictionary_screen` ve `dictionary_provider` modüllerinin yazılması, Arama ve Filtreleme özelliklerinin eklenmesi. Bellek üzerinde (Hardcoded) sahte verilerle test edilmesi.

---
*(Aşağıdaki aşamalar, uygulamanın profesyonel ölçeklendirilmesi için planlanmıştır)*
---

### Faz 4: Yerel Veritabanı (SQLite)
* **Hedef:** Mevcut bellekteki "Sample Data" (Örnek Kelimeler) mantığını `sqflite` kullanarak kalıcı, yüzlerce kelimelik bir `.db` yapısına taşımak.
* **Çıktılar:** Uygulama başlarken asset klasöründeki SQLite veritabanının telefona kopyalanması ve `DictionaryProvider`'ın oradan beslenmesi.

### Faz 5: Bulut Entegrasyonu (Cloudflare R2)
* **Hedef:** FFmpeg ile sıkıştırılmış ASL eğitim videolarının Cloudflare R2'ya yüklenmesi ve SQLite veritabanına public URL'lerinin kaydedilmesi. (Bkz: `03_Cloudflare_R2_Guide.md`).

### Faz 6: Önbellekleme ve Video Oynatma (Caching)
* **Hedef:** `flutter_cache_manager` ve `video_player` paketlerinin entegrasyonu.
* **Kabul Kriteri:** Bir video izlendiğinde (Sözlükten açıldığında) internet harcar; aynı videoya tekrar bakıldığında cihaz hafızasından internetsiz (Offline) açılır.

### Faz 7: Metinden ASL Videolarına Çeviri (Text to ASL)
* **Hedef:** Kullanıcının yazdığı uzun cümlenin parçalanıp, sözlükte aranıp peş peşe ASL videoları oynatan (Video Playlist) sisteme dönüştürülmesi.
* **Kabul Kriteri:** Siyah ekran (takılma) olmadan sırayla oynayan kelime veya harf (Finger-spelling) videoları.

---

## AI IMPLEMENTATION NOTES
* Project is currently situated between Phase 3 and Phase 4.
* Base ML, TTS, STT, and Provider states are fully implemented and working.
* When asked to generate Video/Dictionary logic, refer to Phase 4-7 architectures (SQLite + Cloudflare R2 + Cache Manager).

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

### Faz 4: Yerel Veritabanı (SQLite) (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** Mevcut bellekteki "Sample Data" (Örnek Kelimeler) mantığını `sqflite` kullanarak kalıcı, yüzlerce kelimelik bir `.db` yapısına taşımak.
* **Çıktılar:** Uygulama başlarken asset klasöründeki SQLite veritabanının telefona kopyalanması ve `DictionaryProvider`'ın oradan beslenmesi.

### Faz 5: Bulut Entegrasyonu (Cloudflare R2) (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** FFmpeg ile sıkıştırılmış ASL eğitim videolarının Cloudflare R2'ya yüklenmesi ve SQLite veritabanına public URL'lerinin kaydedilmesi. (Bkz: `03_Cloudflare_R2_Guide.md`).

### Faz 6: Önbellekleme ve Video Oynatma (Caching) (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** `flutter_cache_manager` ve `video_player` paketlerinin entegrasyonu.
* **Kabul Kriteri:** Bir video izlendiğinde (Sözlükten açıldığında) internet harcar; aynı videoya tekrar bakıldığında cihaz hafızasından internetsiz (Offline) açılır.

### Faz 7: Metinden ASL Videolarına Çeviri (Text to ASL) (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** Kullanıcının yazdığı uzun cümlenin parçalanıp, sözlükte aranıp peş peşe ASL videoları oynatan (Video Playlist) sisteme dönüştürülmesi.
* **Kabul Kriteri:** Siyah ekran (takılma) olmadan sırayla oynayan kelime veya harf (Finger-spelling) videoları.

### Faz 8: Genel Cila ve İkon (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** Uygulamanın bir ürüne dönüşmesi için yapay zeka ile `app_icon` üretilmesi, `flutter_launcher_icons` ve `flutter_native_splash` paketleri ile tüm ikonların ayarlanması, projedeki bütün "linter" uyarılarının ve deprecation durumlarının temizlenmesi.
* **Kabul Kriteri:** `flutter analyze`'ın 0 uyarı vermesi, telefon menüsünde ASL ikonunun ve açılış ekranının görünmesi.

### Faz 9: Kullanıcı Deneyimi (Onboarding ve Ayarlar) (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** İlk kez giren kullanıcılar için rehber (Tutorial) ekranı eklenmesi, Ayarlar sayfasında önbellek (Cache) temizleme imkanı sunulması ve etkileşimlerde Haptic Feedback (titreşim) kullanılması.
* **Kabul Kriteri:** Uygulama ilk açıldığında Onboarding çıkması, önbelleğin başarıyla temizlenebilmesi.

### Faz 10: Akademik Altyapı ve Çoklu Dil Desteği (Tamamlandı)
* **Durum:** TAMAMLANDI.
* **Hedef:** Uygulamanın akademik standartlara ulaşması için Unit ve Widget testlerinin yazılması. Tüm statik metinlerin `easy_localization` ile Türkçe ve İngilizce destekleyecek şekilde dinamik hale getirilmesi. Ayarların cihaz hafızasına (`SharedPreferences`) kalıcı olarak kaydedilmesi.
* **Kabul Kriteri:** Terminalde `flutter test` komutunun başarıyla çalışması, gece modunun uygulama kapatılsa dahi silinmemesi ve dilin istenildiği an değiştirilebilmesi.

---

## AI IMPLEMENTATION NOTES
* Project is currently situated between Phase 3 and Phase 4.
* Base ML, TTS, STT, and Provider states are fully implemented and working.
* When asked to generate Video/Dictionary logic, refer to Phase 4-7 architectures (SQLite + Cloudflare R2 + Cache Manager).

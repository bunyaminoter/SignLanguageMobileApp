# ASL İşaret Dili Tanıma ve Eğitim Projesi Dokümantasyonu

## Amaç
Bu belgenin amacı, ASL (Amerikan İşaret Dili) mobil uygulamasının genel yapısını, temel felsefesini ve belgelerin organizasyonunu tanıtmaktır. Bu proje, gerçek zamanlı kamera ile ASL tanıma (ML), Sesten Metne (STT) ve Metinden ASL'ye (Video) dönüştürme özelliklerini içeren kapsamlı bir bitirme projesidir.

## İçindekiler
1. Dokümantasyona Genel Bakış
2. Okuma Sırası
3. Mimari Özet
4. Proje Sözlüğü (Glossary)
5. En İyi Uygulamalar
6. Özet
7. AI Implementation Notes

---

## Dokümantasyona Genel Bakış
Dokümantasyon seti, temel kavramlardan (kavramsal mimari) uygulama detaylarına (kodlama ve yapılandırma) doğru ilerleyen 13 modüler belgeden oluşur. Şu anki projenin yapısına (Provider, Kamera, ML, STT/TTS) ve gelecekteki bulut/video hedeflerine (Cloudflare R2, SQLite) göre uyarlanmıştır.

## Okuma Sırası
1. **`README.md`** (Şu an buradasınız - Genel Bakış)
2. **`01_Project_Architecture.md`** (Mimarinin temelleri, ML ve Kamera entegrasyonu, offline-first)
3. **`02_Technology_Stack.md`** (Provider, STT, TTS, ML ve gelecek video altyapısı)
4. **`03_Cloudflare_R2_Guide.md`** (Planlanan bulut depolama eğitimi)
5. **`04_GitHub_Guide.md`** (Versiyon kontrolü ve Asset yönetimi)
6. **`05_Video_Preparation.md`** (Videoların boyutlarının optimize edilmesi)
7. **`06_SQLite_Database.md`** (Planlanan sözlük veritabanı tasarımı)
8. **`07_Flutter_Architecture.md`** (Flutter Provider klasör yapısı ve kod organizasyonu)
9. **`08_Cache_System.md`** (Videoların cihazda nasıl tutulacağı)
10. **`09_Text_To_ASL.md`** (Metinlerin videolara dönüştürülme mantığı)
11. **`10_Project_Roadmap.md`** (Tamamlanan ve planlanan geliştirme fazları)
12. **`11_Architecture_Decisions.md`** (Mimari karar kayıtları - ADR)
13. **`12_Best_Practices.md`** (Proje geneli standartlar ve kod kalitesi)
14. **`13_Hardware_and_ML_Integration.md`** (YENİ - Kamera, Ses ve TFLite ML modeli entegrasyonu detayları)

---

## Mimari Özet
Bu proje, **Çevrimdışı Öncelikli (Offline-First)** bir Flutter mobil uygulamasıdır. Üç ana modülden oluşur:
1. **Kamera Tanıma (ML):** Cihaz kamerası kullanılarak gerçek zamanlı olarak işaret dilini (ASL) algılayıp metne döker.
2. **Ses ve Metin (STT/TTS):** Konuşulan sesi metne (`speech_to_text`) ve metni sese (`flutter_tts`) çevirir.
3. **ASL Sözlük & Çevirmen (Planlanan Video Altyapısı):** Girilen veya algılanan metinleri, yerel `SQLite` üzerinden eşleştirip `Cloudflare R2` ve `flutter_cache_manager` yardımıyla ASL videoları oynatarak gösterir.
* **Durum Yönetimi:** Projede State Management olarak **Provider** kullanılmaktadır.

---

## Proje Sözlüğü (Glossary)
* **ASL:** Amerikan İşaret Dili.
* **STT (Speech-to-Text):** Sesi metne dönüştüren sistem.
* **TTS (Text-to-Speech):** Metni sese dönüştüren sistem.
* **ML (Machine Learning):** Kameradan alınan görüntüleri ASL harflerine/kelimelerine çeviren yapay zeka modeli.
* **Offline-First:** Uygulamanın ML tahminleri ve önbelleğe alınmış videolarla internet olmadan çalışabilmesi.
* **Provider:** Flutter uygulamasındaki verileri ekranlar arasında güvenle taşımaya yarayan State Management aracı.

---

## AI IMPLEMENTATION NOTES
* Project uses `provider` package, NOT `riverpod` or `bloc`. Do not generate code for other state managers.
* The project has completed ML camera recognition, STT, and TTS.
* The Dictionary and Text-to-ASL video features are upcoming phases.
* Always refer to `01_Project_Architecture.md` for understanding the data flow between Providers and Services.

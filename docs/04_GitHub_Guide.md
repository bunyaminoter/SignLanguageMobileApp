# 04 - GitHub Kullanım ve Yönetim Rehberi

## Amaç
Bu belge; projeyi yönetirken GitHub'ın sadece kod barındırmak için değil, gerektiğinde statik medya dosyalarını (Asset/Release) dağıtmak için nasıl kullanılabileceğini açıklar. Ayrıca GitHub ile Cloudflare R2 arasındaki farkları inceler. Profesyonel olarak GitHub kullanmamış kişiler için tasarlanmıştır.

## İçindekiler
1. Temel Kavramlar (Repository, Branch, Tag)
2. GitHub Releases ve Assets Nedir?
3. Raw URL ve Git LFS
4. GitHub Releases Ne Zaman Kullanılmalı, Ne Zaman Kullanılmamalı?
5. GitHub vs Cloudflare R2 Karşılaştırması
6. Sürüm (Release) Asset'leri Nasıl Yüklenir?
7. Flutter'ın Dosyaları İndirme Yöntemi
8. Avantajlar ve Dezavantajlar
9. Özet
10. AI Implementation Notes

---

## 1. Temel Kavramlar
* **Repository (Repo):** Projenin tüm kodlarının, geçmişinin ve dokümantasyonunun saklandığı ana klasör (Depo).
* **Branch (Dal):** Kodun paralel versiyonlarıdır. Ana koda (main/master) dokunmadan yeni özellikler geliştirmek için kullanılır.
* **Tag (Etiket):** Projenin belirli bir andaki durumuna konulan isimdir. Genellikle versiyonlama (v1.0.0) için kullanılır.

---

## 2. GitHub Releases ve Assets Nedir?
GitHub'da sadece kaynak kodu paylaşılmaz. Bir uygulamanın derlenmiş hali (APK dosyası) veya uygulamanın ihtiyaç duyduğu başlangıç veritabanı (örneğin içi ASL kelimeleriyle dolu `dictionary_v1.db` dosyası) "Release" (Sürüm) altında **Asset** olarak yayınlanabilir.
Asset'ler, GitHub sunucularında duran ve doğrudan bir indirme linki ile erişilebilen statik dosyalardır.

---

## 3. Raw URL ve Git LFS
* **Raw URL:** GitHub'daki bir metin veya kod dosyasının (örneğin bir JSON dosyasının) etrafındaki GitHub arayüzü olmadan sadece saf içeriğinin göründüğü linktir (`raw.githubusercontent.com/...`). 
* **Git LFS (Large File Storage):** GitHub normalde büyük dosyaları (örneğin MP4 videoları) git geçmişinde tutmayı sevmez (Repoyu yavaşlatır). LFS, büyük medya dosyalarını özel bir sunucuda tutarken, repoda sadece onların bir işaretçisini tutan eklentidir. (Büyük videolar için repoya direkt `git push` yapmak yanlıştır).

---

## 4. GitHub Releases Ne Zaman Kullanılmalı, Ne Zaman Kullanılmamalı?

### Kullanılması Gereken Yerler:
1. İçi veri dolu `sqlite.db` dosyasını ilk kurulum için indirtirken.
2. Derlenmiş Android APK'sını test kullanıcılarına dağıtırken.
3. Uygulamanın versiyonlarına ait Changelog (değişiklik notları) yayınlarken.

### Kullanılmaması Gereken Yerler:
1. Yüzlerce veya binlerce ASL MP4 videosunu barındırmak için (GitHub bir CDN veya Video Sunucusu değildir, çok fazla video trafiği abuse/istismar olarak görülebilir).

---

## 5. GitHub vs Cloudflare R2 Karşılaştırması

| Kriter | GitHub (Releases/Raw) | Cloudflare R2 |
| :--- | :--- | :--- |
| **Ana Kullanım Amacı** | Kod versiyonlama ve sürüm dağıtımı | Statik Medya (Video/Resim) Depolama |
| **Video Oynatma Hızı** | Düşük (Streaming desteği zayıf) | Çok Yüksek (Edge CDN) |
| **Kota / Limit** | Release asset başı 2 GB, hız kısıtlamalı | 10 GB (Sınırsız trafik ve CDN hızı) |
| **Dosya Sayısı** | Binlerce video atmak GitHub'da zordur | Yüz binlerce Object rahatça barındırılır |

---

## 6. Sürüm (Release) Asset'leri Nasıl Yüklenir?
1. GitHub projenizde sağ kısımdaki **Releases** sekmesine tıklayın.
2. **Draft a new release** (Yeni sürüm taslağı oluştur) butonuna basın.
3. Yeni bir Tag oluşturun (örneğin `v1.0.0`).
4. Sürüm notlarınızı (neler eklendi, hatalar düzeltildi) yazın.
5. Alt kısımdaki sürükle bırak alanına (Attach binaries by dropping them here) dağıtmak istediğiniz `asl_database_v1.db` veya `app-release.apk` dosyasını bırakın.
6. **Publish Release** butonuna tıklayın.

---

## 7. Flutter'ın Dosyaları İndirme Yöntemi
Flutter, GitHub Releases üzerinden dağıtılan bir veritabanı dosyasını güncellemek için şu yolu izler:
1. Flutter içindeki `http` kütüphanesi kullanılarak GitHub'ın API'sine (en son release versiyonunu soran istek) bir çağrı atılır.
2. Eğer sürüm (v1.1.0) cihazdakinden (v1.0.0) yeniyse Asset URL'si alınır.
3. Cihaz, `https://github.com/.../releases/download/v1.1.0/database.db` URL'sinden dosyayı cihazın Application Documents klasörüne kaydeder.

---

## 8. Avantajlar ve Dezavantajlar
**Avantajlar:** Tamamen ücretsizdir, uygulamanın kodlarıyla uygulamanın sürümlerini (ve veritabanı güncellemelerini) tek bir yerde tutmanızı sağlar.
**Dezavantajlar:** GitHub bir CDN değildir. Özellikle videolarda ileri sarma, sarmalama (buffering) ve HTTP Range-Requests özelliklerini tam desteklemez.

---

## Özet
Projenizdeki ASL (İşaret Dili) videoları için **Cloudflare R2** kullanılmalıdır. Ancak, uygulamanın çalışması için gereken temel SQLite dosyasını (.db formatında) kullanıcılara çevrimdışı öncelikli olarak dağıtmak (güncellemek) için **GitHub Releases** en profesyonel seçenektir.

---

## AI IMPLEMENTATION NOTES
* Do NOT use GitHub Raw or Git LFS to host MP4 video files intended for streaming in the Flutter app. 
* GitHub Releases CAN be used to host the initial prepopulated `sqlite.db` file or machine learning models (tflite).
* When writing an updater script in Flutter, use GitHub REST API `GET /repos/{owner}/{repo}/releases/latest` to parse `assets[0].browser_download_url` for database updates.
* Ensure downloaded DB files are stored in `getApplicationDocumentsDirectory()`.

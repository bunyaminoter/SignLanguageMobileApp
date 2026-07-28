# 05 - Video Hazırlık ve Optimizasyon Rehberi

## Amaç
ASL (Amerikan İşaret Dili) sözlük uygulamasının başarısı, videoların hızlı yüklenmesine ve bulut depolamanın verimli kullanılmasına bağlıdır. Bu belge, videoların Flutter uygulamasına uygun olacak şekilde nasıl küçültüleceğini, hangi ayarlarla kaydedileceğini ve klasörleneceğini açıklamaktadır.

## İçindekiler
1. Video Optimizasyonu Neden Önemlidir?
2. Önerilen Video Ayarları (Codec, Çözünürlük, FPS)
3. FFmpeg ile Toplu Dönüştürme (Batch Conversion)
4. İsimlendirme ve Klasör Düzeni
5. Depolama Hesaplamaları ve Proje Boyutu
6. Performans Karşılaştırmaları
7. Özet
8. AI Implementation Notes

---

## 1. Video Optimizasyonu Neden Önemlidir?
* **Maliyet:** Optimize edilmemiş bir video 15-20 MB olabilir. 1.000 kelimelik bir sözlük 20 GB tutar, bu da Cloudflare R2'nun ücretsiz limitini (10 GB) aşar.
* **Hız:** 20 MB'lık bir videonun mobilde (özellikle 3G/4G olan bir metroda) indirilmesi saniyeler sürer, kullanıcıyı bekletir ve donar.
* **Depolama:** Önbellek (Cache) sistemi kullanıldığı için devasa videolar kısa sürede kullanıcının telefonunun hafızasını (Storage) doldurur.

---

## 2. Önerilen Video Ayarları
İşaret dili videoları çok fazla renk veya ince manzara detayı içermez, sadece el ve yüz hareketlerine odaklanır. Bu yüzden agresif sıkıştırma yapılabilir.

* **Format:** `.mp4` (Android ve iOS tarafından donanımsal desteklenir).
* **Video Codec:** `H.264` (En uyumlu, en az pil tüketen ve en stabil codec'tir. H.265 bazen eski Android'lerde sorun çıkarır).
* **Çözünürlük:** `480p` veya `720p`. (Kullanıcı zaten telefon ekranında küçük bir video izlediği için 1080p veya 4K tamamen gereksizdir).
* **FPS (Kare Hızı):** `30 FPS`. İşaret dili hızlı hareketler içerse de 60 FPS gereksiz dosya boyutu yaratır, 30 FPS akıcılık için yeterlidir.
* **Ses (Audio):** ASL videolarının doğası gereği ses kanalına ihtiyaç yoktur. Sesi kaldırmak (Mute / No Audio Track) dosya boyutunu ciddi oranda düşürür.
* **Bitrate:** `500 kbps - 800 kbps` arası.

---

## 3. FFmpeg ile Toplu Dönüştürme (Batch Conversion)
Elbette videoları tek tek küçültmek zordur. Geliştirici bilgisayarına `ffmpeg` indirilir (Mac için `brew install ffmpeg`, Windows için `choco install ffmpeg`).

### Tek Video İçin FFmpeg Komutu:
```bash
ffmpeg -i input.mp4 -c:v libx264 -crf 28 -preset fast -vf scale=-2:480 -an output.mp4
```
**Komutun Açıklaması:**
* `-c:v libx264`: H.264 kullanarak kodla.
* `-crf 28`: Sıkıştırma kalitesi (Sayı büyüdükçe dosya küçülür, 28 mobil için idealdir).
* `-preset fast`: İşlemi hızlı yap.
* `-vf scale=-2:480`: Yüksekliği 480 piksel yap (En-Boy oranını otomatik koru).
* `-an`: Ses kanalını tamamen sil (Audio No).

### Klasördeki Tüm Videoları Toplu Dönüştürmek İçin (Windows - PowerShell):
Tüm ham videoların bulunduğu klasörde terminali açın:
```powershell
Get-ChildItem -Filter *.mp4 | ForEach-Object {
    ffmpeg -i $_.FullName -c:v libx264 -crf 28 -preset fast -vf scale=-2:480 -an "optimized_$($_.Name)"
}
```

---

## 4. İsimlendirme ve Klasör Düzeni
Videoların veritabanındaki kelimelerle eşleşmesi için çok katı kurallara uyulmalıdır.

* **Best Practices (En İyi Uygulamalar):**
  * Sadece İngilizce (ASCII) karakterler kullanın.
  * Sadece küçük harf kullanın.
  * Kelimeler arasındaki boşlukları alt tire (`_`) veya tire (`-`) ile değiştirin. (Alt tire tercih edilir).

* **Örnekler:**
  * İyi: `thank_you.mp4` , `apple.mp4`, `new_york.mp4`
  * Kötü: `Thank You.mp4` (Boşluk ve Büyük harf var), `teşekkür.mp4` (Türkçe karakter var).

Klasörleme yaparken Cloudflare R2'da her şeyi root (ana dizin) içerisine atabilirsiniz çünkü binlerce dosyayı klasörlemek yerine veritabanı ile sorgulamak en modern yöntemdir.

---

## 5. Depolama Hesaplamaları ve Proje Boyutu
Yukarıdaki FFmpeg komutu ile ortalama 3 saniyelik bir ASL işareti şu boyuta iner: **~200 KB ile 400 KB.**

Eğer uygulamanızda **1.000 kelime** varsa:
`1000 kelime * 300 KB = 300.000 KB = ~300 MB`
* **R2 Ücretsiz Sınırı:** 10.000 MB (Yani 1.000 kelime, R2 limitinin sadece %3'ünü kullanır!)
* **Cihaz Hafızası:** 300 MB bir telefonda hiçbir şeydir. Kullanıcı sözlükteki her kelimeye baksa bile telefonu dolmaz.

---

## 6. Performans Karşılaştırmaları

| Özellik | Ham Video (iPhone/Kamera) | Optimize Edilmiş FFmpeg Videosu |
| :--- | :--- | :--- |
| **Çözünürlük** | 1080p veya 4K | 480p (Scale korumalı) |
| **Kare Hızı** | 60 FPS | 30 FPS |
| **Ses** | Var (Gereksiz ortam sesi) | Yok (Sıfır bit) |
| **Boyut (3 sn)** | 12 MB - 20 MB | 250 KB - 400 KB |
| **İndirme Hızı (Mobil)**| 4 - 6 Saniye | 0.1 Saniye (Anında açılır) |

---

## Özet
Projenin ölçeklenebilmesi ve sorunsuz çalışması, videoların FFmpeg ile H.264 (sessiz 480p/720p) formatına sokulmasına bağlıdır. Büyük harf, Türkçe karakter ve boşluk içermeyen isimlendirme, veritabanının videoları hatasız çağırmasını sağlar.

---

## AI IMPLEMENTATION NOTES
* Assume all video files on Cloudflare R2 have NO audio track (`-an`). 
* In Flutter `video_player`, there is no need to implement volume controls or mute toggles since the videos themselves are physically stripped of audio.
* Video URLs in SQLite must map exactly to the normalized file names (lowercase, underscores instead of spaces).
* Do not attempt to process FFmpeg compression within the Flutter app itself. Video processing is an offline, pre-deployment task for the developers.

# 12 - En İyi Uygulamalar (Best Practices)

## Amaç
Bu belge, proje genelinde kod yazarken, dosya yönetirken, test yaparken veya mimariyi genişletirken uyulması gereken genel kalite standartlarını, kuralları ve tavsiyeleri bir araya getirir.

## İçindekiler
1. İsimlendirme ve Klasör Kuralları
2. Temiz Kod (Clean Code)
3. Hata Yönetimi (Error Handling)
4. Güvenlik ve Gizlilik (Security)
5. Performans
6. Dokümantasyon Kuralları
7. Sürüm Kontrol (Versioning) ve Dağıtım (Deployment)
8. Özet
9. AI Implementation Notes

---

## 1. İsimlendirme ve Klasör Kuralları
* **Flutter/Dart İsimlendirmeleri:**
  * Dosya İsimleri: Sadece küçük harf ve alt tire (`snake_case.dart`). Örn: `dictionary_screen.dart`
  * Sınıf İsimleri (Classes): İlk harfleri büyük (`CamelCase`). Örn: `class DictionaryScreen extends StatelessWidget`
  * Değişkenler: İlk harf küçük (`camelCase`). Örn: `String videoUrl;`
* **Video İsimlendirmeleri (R2 ve SQLite):**
  * Sadece küçük harf ve İngilizce alfabe. Boşluklar alt tire olmalıdır. (Örn: `thank_you.mp4`).

---

## 2. Temiz Kod (Clean Code)
* **Single Responsibility Principle (Tek Sorumluluk Prensibi):** Bir sınıf (Class) sadece tek bir iş yapmalıdır. Bir Widget'ın içine hem tasarım, hem SQLite sorgusu, hem de video oynatma mantığı konulamaz. (Repository Pattern kullanılmalı).
* **Magic Numbers Yok (Büyülü Sayılar):** Uygulamadaki renk kodları (`#FF0000`) veya sabit kelimeler arayüz dosyalarına dağınık yazılmaz. Bunlar `AppColors` veya `AppConstants` gibi bir merkezi dosyada tutulur.

---

## 3. Hata Yönetimi (Error Handling)
* Uygulama hiçbir senaryoda çökmemelidir (Crash olmamalı).
* `try-catch` blokları içinde fırlatılan bir hatayı yutmayın (Silmeyin). Hatayı ya UI'da zarif bir mesaj (Graceful Error Message) olarak (Örn: "Bir şeyler ters gitti, internet bağlantınızı kontrol edin") gösterin ya da loglayın.
* Siyah ekran çıkmasını önleyin; veri yoksa yedek bir ekran veya ikon (Placeholder) gösterin.

---

## 4. Güvenlik ve Gizlilik (Security)
* **API Anahtarları (Secrets):** Veritabanı şifreleri veya Gizli anahtarlar asla Git'e (GitHub'a) `commit` edilmemelidir (Açık kaynak projelerde bile). Bunlar yerel `.env` dosyalarında tutulmalı ve `.gitignore` dosyasına eklenmelidir.
* *(Bu projede public R2 kullanıldığı için özel bir şifre sorunu yoktur, ancak genel best practice budur).*

---

## 5. Performans
* **Memory Leaks (Hafıza Sızıntıları):** Flutter'da ekrandan çıkıldığında bellekte kalan veriler sorun yaratır. Bir video oynatıcı (VideoPlayerController) veya ScrollController başlatıldıysa, ekran kapandığında `dispose()` metodu içinde mutlaka yokedilmelidir.
* **Yavaş Döngüler:** SQLite veritabanı arama işlemleri ana thread (UI) üzerinde kasmalar yaratmaması için, Dart'ın asenkron özellikleri (`Future`, `async/await`) ile çağrılmalıdır.

---

## 6. Dokümantasyon Kuralları
* Kod bloklarına yazılacak yorum satırları, kodun "Ne" yaptığını değil "Neden" yaptığını açıklamalıdır. (Kodun ne yaptığı zaten temiz kod ile anlaşılmalıdır).
* Dokümantasyon (.md dosyaları) güncel tutulmalıdır. Yeni bir teknoloji eklenirse `02_Technology_Stack.md` dosyası güncellenmelidir.

---

## 7. Sürüm Kontrol (Versioning) ve Dağıtım (Deployment)
* GitHub'a `commit` mesajları atarken açıklayıcı olun:
  * `git commit -m "update"` -> **Kötü**
  * `git commit -m "feat(dictionary): add text-to-asl search bar"` -> **İyi**
* Semantik Sürümleme kullanın: `v1.0.0` (Major.Minor.Patch). Veritabanını güncellediğinizde sadece Patch veya Minor numarasını artırın.

---

## Özet
En İyi Uygulamalar, "Çalışıyorsa dokunma" mantığının reddedilmesidir. Projenin sürdürülebilir, ekip çalışmasına uygun ve profesyonel (üretim ortamına / prod'a hazır) kalmasını sağlamak için bu kurallar vazgeçilmezdir.

---

## AI IMPLEMENTATION NOTES
* Naming Conventions: Enforce `snake_case` for files and `camelCase` for variables.
* Magic Values: Move all literal strings and colors to a centralized `constants.dart` file.
* Memory Management: Automatically generate `dispose()` overrides for any stateful widget containing `VideoPlayerController` or other active controllers.
* Error Handling: Wrap repository data access with `try/catch` and return explicit error states (using `Either` or Riverpod `AsyncError`) rather than throwing bare exceptions to the UI.

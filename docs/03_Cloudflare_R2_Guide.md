# 03 - Cloudflare R2 Başlangıç ve Kullanım Rehberi

## Amaç
Bu belgenin amacı, daha önce hiçbir bulut depolama (Cloud Storage) servisi kullanmamış birine; sunucu mantığını, Cloudflare R2'nun ne olduğunu, nasıl kurulacağını ve Flutter projesiyle nasıl entegre edileceğini sıfırdan öğretmektir.

## İçindekiler
1. Temel Kavramlar (Sıfırdan Başlayanlar İçin)
2. Neden Başka Bir Servis Değil de Cloudflare R2?
3. Fiyatlandırma ve Ücretsiz Katman
4. Adım Adım Cloudflare R2 Kurulumu
5. Videoları Yükleme ve Klasör Düzeni
6. Videoları İnternete Açma (Public Access)
7. Flutter'ın R2'ya Erişimi
8. Güvenlik ve Yetkilendirme
9. Sık Yapılan Acemi Hataları ve Çözümler
10. AI Implementation Notes

---

## 1. Temel Kavramlar (Sıfırdan Başlayanlar İçin)

### Object Storage (Nesne Depolama) Nedir?
Bilgisayarınızdaki klasör hiyerarşisi (C: > Kullanıcılar > Videolar > video.mp4) "Dosya Depolama" (File Storage) olarak adlandırılır. 
**Object Storage** ise devasa verilerin internet üzerinde saklanma şeklidir. Dosyalar bir hiyerarşi içinde değil, düz bir havuzda (Bucket) saklanır. Her dosya (Object) kendisine ait benzersiz bir kimlik (Key / URL) ile anılır. 
*Örneğin:* `https://benim-sunucum.com/asl-videolari/merhaba.mp4`

### AWS S3 Nedir?
Amazon (AWS) firmasının icat ettiği dünyanın en ünlü Object Storage servisidir (Simple Storage Service). Sektör standardıdır. O kadar meşhurdur ki, Cloudflare R2 dahil çoğu sistem "S3 Uyumlu" (S3 Compatible) çalışır. Yani S3 için yazılan kod, R2'da da çalışır.

### R2 Neden Var? (Cloudflare R2 Nedir?)
Amazon S3 harikadır ancak gizli bir tuzağı vardır: **Egress Fee (Çıkış Ücreti)**.
AWS S3'e dosya yüklemek bedavadır. Ancak kullanıcılarınız uygulamanızdan bu videoları indirdiğinde (izlediğinde), Amazon sizden GB başına para (bant genişliği ücreti) alır. Uygulamanız popüler olursa binlerce dolar fatura gelir.
Cloudflare, "Egress Fee soygundur" diyerek **R2**'yu kurmuştur. R2'da veri çıkışı (indirme/bant genişliği) **tamamen ücretsizdir.**

### Terimler Sözlüğü
* **CDN (Content Delivery Network):** Dünyanın dört bir yanındaki sunuculardan oluşan ağ. Videonuzu Türkiye'deki birisi açarsa ABD'den değil, Türkiye'deki (en yakın) Cloudflare sunucusundan izler. Hız kazandırır.
* **Bucket (Kova):** Projeye ait dosyaları attığınız ana çuval/klasör (Örn: `sign-language-videos`).
* **Object (Nesne):** Bucket içindeki her bir dosya (Örn: `merhaba.mp4`).
* **Endpoint:** Sistemlerin (kodların) Cloudflare ile haberleştiği adres.
* **Public URL:** Herkesin dosyayı tarayıcıdan izleyebileceği açık internet linki.

---

## 2. Neden Başka Bir Servis Değil de Cloudflare R2?

| Özellik | Google Drive | Vercel (Hobby) | GitHub Releases | Cloudflare R2 |
| :--- | :--- | :--- | :--- | :--- |
| **Video Oynatma Hızı** | Çok Yavaş | Hızlı | Orta | **Çok Hızlı (CDN)** |
| **Bant Genişliği Sınırı** | Çabuk Bloklanır | 100 GB / Ay | Soft Limit var | **SINIRSIZ** |
| **API ve Kod Uyumu** | Zor (Linkler Değişir) | Kolay | Kolay | **Çok Kolay (S3 Uyumlu)** |
| **Gerçek Kullanım Amacı** | Kişisel Dosyalar | Web Siteleri | Kod ve Uygulama | **Medya / Depolama** |

**Sonuç:** Bir mobil uygulamada video stream edilecekse tek mantıklı ve sürdürülebilir (ücretsiz) seçenek Cloudflare R2'dur.

---

## 3. Fiyatlandırma ve Ücretsiz Katman (Free Tier)
Bir öğrenci veya girişimci için en can alıcı nokta: Nasıl fatura gelir?
* **Depolama Alanı:** Ayda **10 GB** tamamen ÜCRETSİZ. (Videoları optimize edersek 500 kelime = 0.2 GB yapar. Çok fazlasıyla yeter).
* **Bant Genişliği (Video İzleme):** ÜCRETSİZ (Sınırsız).
* **Class A İşlemleri (Yazma/Dosya Yükleme):** Ayda 1 Milyon işlem ücretsiz.
* **Class B İşlemleri (Okuma/İzleme):** Ayda 10 Milyon okuma ücretsiz.

*Kısacası, devasa bir küresel uygulama olmadığı sürece bu proje için Cloudflare R2 sonsuza kadar 0$ tutacaktır.* Yalnızca R2'yu aktif etmek için Cloudflare bir kredi kartı girmenizi isteyecektir (Bot hesapları engellemek için), ancak sınırı aşmadıkça para çekmez.

---

## 4. Adım Adım Cloudflare R2 Kurulumu

### Adım 1: Hesap Oluşturma
1. `dash.cloudflare.com/sign-up` adresine gidin.
2. E-posta ve şifrenizle kayıt olun.

### Adım 2: R2'yu Aktif Etme
1. Sol menüden **R2** seçeneğine tıklayın.
2. "Enable R2" (R2'yu Etkinleştir) butonuna basın.
3. Sistemi doğrulamak için ödeme bilgilerinizi girin (Ücretsiz limitler dahilinde kalacağız).

### Adım 3: Bucket Oluşturma
1. R2 paneline girin, **Create Bucket** butonuna tıklayın.
2. İsim verin (Örn: `asl-dictionary`). **Önemli:** İsimler İngilizce karakter, küçük harf ve tire içermelidir.
3. Konum olarak **Automatic** seçili kalsın (Cloudflare en uygun yerleri otomatik dağıtır).
4. Create Bucket diyerek işlemi bitirin.

---

## 5. Videoları Yükleme ve Klasör Düzeni
Bucket'ın içine girdikten sonra dosyaları sürükle-bırak ile yükleyebilirsiniz.
* **Best Practice (En İyi Yöntem):** Videoları kelime isimleriyle aynı olacak şekilde İngilizce ve küçük harflerle isimlendirin.
  * Doğru: `hello.mp4`, `thank_you.mp4`
  * Yanlış: `Hello.mp4`, `teşekkürler.mp4` (Büyük harf ve Türkçe karakter yazılımda sorun çıkarır).
* Dilerseniz `A/`, `B/` gibi klasörler açabilirsiniz ancak veritabanı olacağı için tüm videoları ana dizine (root) atmanız daha pratiktir.

---

## 6. Videoları İnternete Açma (Public Access)
Varsayılan olarak Cloudflare R2 bucket'ları "Private" (Gizli) olarak gelir. Yani uygulamanız videoları çekemez. Onları dışarı açmalıyız:
1. Oluşturduğunuz Bucket'a (`asl-dictionary`) tıklayın.
2. Üst sekmelerden **Settings (Ayarlar)** kısmına gidin.
3. Aşağı inerek **Public Access (Genel Erişim)** bölümünü bulun.
4. **R2.dev Subdomain** yanındaki "Allow Access" (Erişime İzin Ver) seçeneğine tıklayın.
5. Ekranda bir onay kutusu çıkar, onaylayın.
6. Artık size ait benzersiz bir public link üretilir. Örneğin: `https://pub-a1b2c3d4.r2.dev`

Bir videoyu test etmek için tarayıcıya şunu yazın:
`https://pub-a1b2c3d4.r2.dev/hello.mp4` -> Video tarayıcıda doğrudan oynamaya başlamalıdır!

---

## 7. Flutter'ın R2'ya Erişimi
Mobil uygulamanız Cloudflare SDK'sı, şifreler veya tokenlar kullanmak **ZORUNDA DEĞİLDİR.**
Public Access'i açtığımız için, videolar artık internette sıradan bir web sitesindeki videolar gibidir.

Flutter tarafında yapmanız gereken tek şey, veritabanına statik linkleri yazmaktır:
```json
{
  "id": 1,
  "word": "Hello",
  "videoUrl": "https://pub-a1b2c3d4.r2.dev/hello.mp4"
}
```
Uygulama (video_player), bu URL'ye normal bir HTTP GET isteği atarak videoyu oynatır.

---

## 8. Güvenlik ve Yetkilendirme (İleri Seviye)
Eğer "Benim videolarım özel, linki kopyalayan herkes sitesinde kullanamasın" derseniz Private Bucket mantığına geçmeniz gerekir.
* Public linki kapatırsınız.
* Uygulama içine (Flutter), Cloudflare R2'nun **Access Key** ve **Secret Key** şifrelerini gömersiniz (S3 uyumlu kütüphaneler ile).
* Uygulama her istekte bir anahtar (Token) üretir.
* **Not:** Bir üniversite projesi veya sözlük uygulaması için videoların gizli kalmasına gerek yoktur. Public Access (Genel Erişim) kullanmak hem performansı artırır hem kod karmaşıklığını sıfıra indirir.

---

## 9. Sık Yapılan Acemi Hataları ve Çözümler

* **Hata:** Tarayıcıya linki yapıştırıyorum ama "XML AccessDenied" veya 403 hatası alıyorum.
* **Çözüm:** Bucket ayarlarından "R2.dev Subdomain" için "Allow Access" (Public) özelliğini açmayı unuttunuz.

* **Hata:** Mobilde video oynatıcı siyah ekranda kalıyor.
* **Çözüm:** Video ismindeki büyük/küçük harf veya boşluklara dikkat edin. `merhaba.mp4` yerine `Merhaba.mp4` aratıyor olabilirsiniz. Linkler Case-Sensitive'dir (Büyük küçük harfe duyarlıdır).

* **Hata:** Videolar çok geç açılıyor veya donuyor.
* **Çözüm:** Sorun Cloudflare R2 değil, videolarınızın boyutudur. Eğer 1 saniyelik ASL videosu iPhone'dan direkt aktarıldıysa 20 MB olabilir. FFmpeg ile o videoyu 500 KB'a düşürmelisiniz (Bknz: `05_Video_Preparation.md`).

---

## AI IMPLEMENTATION NOTES
* Treat Cloudflare R2 exactly like a standard HTTP static file server in Flutter (when using Public bucket mode).
* Do not implement AWS S3 SDKs / sigV4 authentication for Flutter video fetching unless explicitly asked by the user to implement Private Bucket functionality.
* R2 URLs follow the pattern: `<public-r2-subdomain>/<object-key>`.
* Ensure `<object-key>` handling URL encodes spaces and special characters. For example, "hello world.mp4" should be requested as `hello%20world.mp4`.
* Recommend `.mp4` formats natively supported by `video_player`.

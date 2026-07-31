# SignLanguageMobileApp
**Amerikan İşaret Dili (ASL) Canlı Tanıma ve Öğrenim Uygulaması**

Bu proje, eğitilmiş bir Amerikan İşaret Dili (ASL) tanıma modelini masaüstü laboratuvar ortamından çıkarıp, doğrudan son kullanıcıyla buluşturmak amacıyla geliştirilmiş Flutter tabanlı bir mobil uygulamadır.

## 🚀 Proje Tanımı ve Vizyonu
Bu projedeki asıl vizyon, yalnızca bir makine öğrenmesi modeli geliştirmek değil; daha önce eşine az rastlanır bir şekilde, işitme ve konuşma engelli bireyleri en son yapay zeka teknolojileriyle buluşturmak ve onların iletişim engellerini ortadan kaldıran bir köprü inşa etmektir. 

Kullanıcıların hareket halindeyken işaret dilini öğrenebilmesini ve pratik yapabilmesini hedefleyen bu uygulama, çıkarım hızını (inference speed) en üst düzeye çıkararak mobil cihazlarda akıcı bir deneyim sunmaktadır. Performanslı, erişilebilir, modern ve kullanıcı dostu arayüzü sayesinde işaret dili öğrenimi ve yapay zeka destekli çevirisi herkes için her an ulaşılabilir kılınmıştır.

## ✨ Temel Özellikler

### 📷 Canlı Tanıma (Kamera Modülü)
Uygulamanın kalbini oluşturan **ASL Canlı Tanıma** modülü, engelli bireylerin gerçek dünyada yapay zeka ile doğrudan etkileşime girmesini sağlayan en yenilikçi sayfalardan biridir.
* **Gerçek Zamanlı ve Düşük Gecikmeli Tespit:** Her kare MediaPipe ile işlenip anlık olarak analiz edilir. FPS ve "HAZIR" durumu ekranda gösterilir.
* **Tahmin ve Güven Oranı (Confidence Score):** Yapılan işaretin yapay zeka tarafından ne kadar yüksek bir güvenle algılandığı (% cinsinden) ilerleme çubuğuyla ve alternatif olasılıklarla birlikte şeffafça gösterilir (Explainable AI yaklaşımı).
* **Bağlamsal Cümle Kurma ve Seslendirme:** Tespit edilen kelimeler peş peşe birleştirilerek anlamlı cümleler oluşturulur. Bu metin, Text-to-Speech (TTS) motoru sayesinde anında sesli konuşmaya dönüştürülerek engelli bireyin dış dünyayla doğrudan "konuşabilmesine" olanak tanır.

![ASL Canlı Tanıma](docs/Mobil%20ekranlar%C4%B1/05_ASL_Live_Recognition.jpeg)

---

### 🤖 Yapay Zeka Destekli Sohbet (SignAI)
İşaret dilini geleneksel, statik sözlüklerden öğrenmek yerine dinamik bir deneyime dönüştürmek için tasarlanan yapay zeka destekli sohbet asistanıdır.
* **Dinamik Görsel Eşleşme:** Kullanıcı AI'a bir kelime veya soru yönelttiğinde (Örn: "What is water?"), sistem sadece metin tabanlı açıklama yapmakla kalmaz; aynı zamanda o kelimenin nasıl işaret edildiğini gösteren özel videoları doğrudan sohbet akışı (chat UI) içerisinde oynatır.
* **Kapsayıcı Çoklu Dil Desteği:** Erişilebilirliği evrenselleştirmek adına hem İngilizce hem de Türkçe dil desteği ile tasarlanmıştır.

| SignAI (İngilizce) | SignAI (Türkçe) |
|:---:|:---:|
| ![SignAI EN](docs/Mobil%20ekranlar%C4%B1/04_SignAI_Chat_EN.jpeg) | ![SignAI TR](docs/Mobil%20ekranlar%C4%B1/06_SignAI_Chat_TR.jpeg) |

---

### 📝 Metinden ASL İşaretine Çeviri (Text-to-ASL)
İşitme engelli bireylerle iletişime geçmek isteyen ancak işaret dili bilmeyen kişiler için köprü görevi gören, iletişimi çift yönlü hale getiren modül.
* **Gelişmiş Girdi Seçenekleri:** Klavye ile yazarak veya mikrofon/sesli komut üzerinden girilen bir metin anında algılanır.
* **Sıralı ve Akıcı İşaret Dizilimi:** NLP mantığıyla kelimelere bölünen metin, her bir kelimenin ASL işaret videosu ile kesintisiz olarak peş peşe oynatılır. "HELLO COMPUTER", "DRINK WATER" gibi hızlı seçim butonları ile acil iletişime destek olur.

![Metin -> ASL İşareti](docs/Mobil%20ekranlar%C4%B1/07_Text_To_ASL.jpeg)

---

### 📚 ASL Sözlüğü (Kütüphane)
Arka planda çalışan yapay zeka modelinin kapasitesini yansıtan, kapsamlı ve pedagojik olarak düzenli referans kaynağıdır.
* **Modüler Kategorilendirme:** İşaretler "Genel", "Nesneler", "Eylemler" gibi mantıksal kategorilere ayrılmıştır. Gelişmiş filtreleme ile detaylı eğitim videolarına kolayca ulaşılır.

![ASL Sözlüğü](docs/Mobil%20ekranlar%C4%B1/03_ASL_Dictionary.jpeg)

---

### ⚙️ Gelişmiş Ayarlar ve Özelleştirmeler
Her engelli bireyin veya öğrenicinin ihtiyacının farklı olabileceği bilinciyle, kullanıcıya mutlak kontrol sağlayan kapsamlı bir ayarlar mimarisi.
* **Kişiselleştirilebilir Görünüm:** Karanlık Mod, Uygulama Dili (Türkçe/İngilizce) seçenekleri. Ayrıca, yapay zekanın kişiyi nasıl "gördüğünü" görselleştiren kamerada vücut iskelet noktalarını (Landmark) gösterme opsiyonu.
* **Esnek Tanıma Dinamikleri:** Modelin tespit esnekliğini belirleyen "Güven Eşiği" (Confidence Threshold) kaydırıcısı ve eski cihazlarda bile uygulamanın yorulmadan çalışmasını garanti altına alan "Çıkarım Aralığı" (Inference Interval) ayarı.
* **Erişilebilirlik ve Ses:** Tanınan kelimenin anında okunması, ses hızının (konuşma temposunun) ayarlanması ve seslendirme dilinin değiştirilmesi gibi hayat kolaylaştıran özellikler.

| Görünüm Ayarları | Tanıma ve Ses Ayarları |
|:---:|:---:|
| ![Ayarlar Görünüm](docs/Mobil%20ekranlar%C4%B1/01_Settings_Appearance_TR.jpeg) | ![Ayarlar Tanıma](docs/Mobil%20ekranlar%C4%B1/02_Settings_Recognition_TR.jpeg) |

---

## 🛠 Teknik Altyapı ve "Sıfır Gecikme" Mimarisi
Böylesine veri yoğun, video odaklı ve yapay zekayı anlık çalıştıran bir projeyi mobil ortamda optimize etmek için geliştirilen "Sıfır Gecikme" (Zero-Latency) felsefesine dayalı çözümler:
* **Cloudflare R2 Entegrasyonu:** Mobil uygulamanın boyutunu (APK/AAB) hafif tutmak adına, yüzlerce yüksek kaliteli video Cloudflare R2 bulut sistemine taşınmıştır. R2'nin global CDN altyapısı sayesinde dünyanın her yerinden anında ve takılmadan (low latency) stream edilebilmektedir.
* **Akıllı Önbellek (Cache) Sistemi:** Bant genişliğinden tasarruf etmek ve internetsiz durumlarda öğrenimin kesintiye uğramamasını sağlamak için gelişmiş bir Cache mekanizması geliştirilmiştir. Bir video ilk izlendiğinde yerel diske kaydedilir, sonraki izlemelerde doğrudan yerel hafızadan ışık hızında oynatılır. Kullanıcılar gerektiğinde bu önbelleği tek tuşla temizleyebilir.
* **Yerel Güç (SQLite Veritabanı):** Uygulama içi arama geçmişi, kelime bilgileri ve sözlük verilerini tamamen çevrimdışı ve güvenli bir şekilde yönetmek için yerel SQLite veritabanı entegrasyonu kullanılmıştır.

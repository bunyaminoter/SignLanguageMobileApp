# 11 - Mimari Karar Kayıtları (ADR - Architecture Decision Records)

## Amaç
Mimari Karar Kayıtları (ADR), bir projenin yapılışı sırasında verilen kritik teknik kararları, "Neden başka bir şey değil de bunu seçtik?" (Why) sorusunu cevaplayarak kayıt altına alır. Gelecekte projeyi inceleyen kişiler veya hocalar için kararların arkasındaki mühendislik mantığını açıklar.

## İçindekiler
1. ADR 1: Durum Yönetimi (Neden Provider?)
2. ADR 2: Makine Öğrenmesi (Neden Edge AI / Kamera Mimarisi?)
3. ADR 3: Depolama Servisi (Neden Cloudflare R2 Planlandı?)
4. ADR 4: Medya Yönetimi (Neden Cache Manager ve MP4?)
5. AI Implementation Notes

---

### ADR 1: Durum Yönetimi (Neden Provider?)
* **Bağlam (Context):** Arama yapılıyor, Kamera Frame'leri (kareleri) işleniyor, ML modeli saniyede birden çok kez sonuç üretiyor. Bu veri akışları UI'a (Arayüze) nasıl yansıtılacak?
* **Seçenekler:** setState, Bloc, Riverpod, Provider.
* **Seçilen Çözüm:** **Provider (`ChangeNotifier`)**.
* **Neden (Why):** Makine öğrenmesi ve donanım entegrasyonu (Kamera, STT, TTS) zaten karmaşık bir yapı gerektiriyordu. Ekibe veya bitirme projesine Bloc veya Riverpod gibi öğrenme eğrisi yüksek yapılar dahil etmek süreci yavaşlatabilirdi. Provider, Flutter çekirdek ekibinin desteklediği, OOP (Nesne Yönelimli Programlama) mantığına çok uygun ve servisler arası veri akışını kolay kurabildiğimiz en ideal çözümdür.

---

### ADR 2: Makine Öğrenmesi (Neden Edge AI / Kamera Mimarisi?)
* **Bağlam (Context):** İşaret dilini anlama işlemi (Inference) buluttaki güçlü bir sunucuda mı yapılmalı, telefonda mı?
* **Seçilen Çözüm:** **Edge AI (Telefonda / Çevrimdışı Çalışan ML Modeli)**.
* **Neden (Why):** Video framelerini (Kamera görüntülerini) saniyede 30 kez internetteki bir API'ye göndermek korkunç bir veri (internet kotası) tüketimi ve gecikme (Latency) yaratır. Edge AI (TFLite vb.) modeli doğrudan kullanıcının donanımını kullanarak gecikmeyi sıfıra indirir ve Çevrimdışı-Öncelikli (Offline-first) hedefimizi korur.

---

### ADR 3: Depolama Servisi (Neden Cloudflare R2 Planlandı?)
* **Bağlam (Context):** (Gelecek Faz) Boyutu toplamda yüzlerce MB olan ASL sözlük eğitim videoları nerede tutulacak?
* **Seçenekler:** AWS S3, Google Drive, Firebase Storage, Cloudflare R2.
* **Seçilen Çözüm:** **Cloudflare R2 (Public Bucket)**.
* **Neden (Why):** Video akışı (streaming) büyük oranda bant genişliği (egress/bandwidth) kullanır. AWS S3 ve Firebase belirli bir indirmeden sonra ücret yazar. Cloudflare R2, Edge CDN mimarisiyle videoları inanılmaz hızlı ulaştırır ve veri çıkışı (Egress) maliyeti %100 oranında Sıfır'dır (0$).

---

### ADR 4: Medya Yönetimi (Neden Cache Manager ve MP4?)
* **Bağlam (Context):** (Gelecek Faz) İndirilen sözlük videoları telefon hafızasını ve internet kotasını sömürmeden nasıl oynatılacak?
* **Seçilen Çözüm:** **flutter_cache_manager ve Sessiz (Mute) MP4 H.264**.
* **Neden (Why):** `flutter_cache_manager` video inmişse tekrar interneti kullanmaz ve depolama dolduğunda en eskileri (LRU) otomatik siler. MP4 (H.264), Android/iOS cihazlarda donanım destekli çözüldüğü için pil dostudur. Sessiz olması, ASL videoları için 20 MB'lık videoları 300 KB'a indirir.

---

## AI IMPLEMENTATION NOTES
* Always assume `provider` over `riverpod` for State Management implementations.
* Architecture heavily favors on-device execution (Offline-First): ML inference (TFLite), local dictionary search (SQLite), and local caching (`flutter_cache_manager`) over API fetching.

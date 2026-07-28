# 07 - Flutter Uygulama Mimarisi (Provider)

## Amaç
Bu belge, projedeki klasör yapısını, servis tabanlı mimariyi ve `Provider` kullanılarak durum yönetiminin (State Management) nasıl organize edildiğini açıklar.

## İçindekiler
1. Mevcut Klasör Yapısı
2. Servisler (Services)
3. Providers (Durum Yöneticileri)
4. Modeller (Data Models)
5. Navigasyon (Routing)
6. AI Implementation Notes

---

## 1. Mevcut Klasör Yapısı
Proje, görevlerine göre mantıksal klasörlere (Layer-based) ayrılmıştır:

```text
lib/
 ├── config/           # Sabitler (AppConstants), Tema ve yapılandırma
 ├── models/           # Veri sınıfları (DictionaryWord vb.)
 ├── providers/        # State Management sınıfları (ChangeNotifier)
 ├── screens/          # Kullanıcı Arayüzü / Sayfalar (UI)
 ├── services/         # Donanım API'leri ve Dış Servisler (ML, STT, TTS)
 ├── utils/            # Yardımcı fonksiyonlar (Formatter, helper)
 ├── widgets/          # Tekrar kullanılabilir küçük arayüz parçaları
 ├── app.dart          # MultiProvider ve Router ayarlarının yapıldığı ana app
 └── main.dart         # Uygulama Giriş Noktası
```

---

## 2. Servisler (Services)
`services/` klasörü, uygulamanın donanımla veya karmaşık hesaplamalarla konuştuğu yerdir. 
* **Örnek Servisler:** `asl_model_service.dart` (Kamera/Yapay Zeka), `stt_service.dart` (Mikrofon), `tts_service.dart` (Hoparlör).
* **Kural:** Servis sınıfları genelde kendi içlerinde State (Durum) tutmazlar veya `notifyListeners()` çağırmazlar. Görevleri sadece işi yapıp sonucu Provider'lara döndürmektir.

---

## 3. Providers (Durum Yöneticileri)
`providers/` klasörü, UI (Kullanıcı Arayüzü) ile Servisler (İş Mantığı) arasındaki köprüdür. `ChangeNotifier` sınıfından ürerler.
* `recognition_provider.dart`: Kameradan gelen ML sonuçlarını UI'a yansıtır.
* `dictionary_provider.dart`: Arama çubuğundaki metni dinler ve filtrelenmiş listeyi tutar.
* `text_to_sign_provider.dart`: Cümleyi oluşturma veya Text-to-ASL mantığını yönetir.

**Örnek Provider Kullanımı (UI Tarafı):**
```dart
// Ekranda değişiklik olduğunda otomatik güncellenmesini istediğimiz yer
Consumer<DictionaryProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.filteredWords.length,
      // ...
    );
  }
)
```

---

## 4. Modeller (Data Models)
Uygulama içinde kullanılan verilerin şablonlarıdır. `models/` altında yer alırlar. (Örn: `DictionaryWord`). Bu sayede `Map<String, dynamic>` kullanmak yerine tip güvenli (Type-safe) kod yazılmış olur.

---

## 5. Navigasyon (Routing)
Uygulama içindeki sayfalar arası geçiş `go_router` paketi ile `app.dart` (veya config altındaki bir router dosyası) içerisinde tanımlanmıştır.
Örnek Geçiş: `context.go('/dictionary')` veya `context.push('/dictionary/details')`.

---

## AI IMPLEMENTATION NOTES
* State Management: `Provider`. Always use `Consumer` or `context.watch()` for reactive UI components, and `context.read()` for one-time method calls inside callbacks.
* Separation of Concerns: 
  * `Screens/Widgets` handle UI only.
  * `Providers` hold state variables and call services.
  * `Services` interact with hardware APIs (Camera, TTS, STT) or external networks.
* Do not put business logic or API calls directly inside `Screens`.

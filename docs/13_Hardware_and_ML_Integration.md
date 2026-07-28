# 13 - Donanım ve Makine Öğrenmesi (ML) Entegrasyonu

## Amaç
Bu belgenin amacı, projenin en kritik bölümlerinden olan cihaz donanımlarına (Kamera, Mikrofon, Hoparlör) erişimi ve eğitilmiş ASL modelinin (TFLite) Flutter uygulaması içerisinde nasıl çalıştırıldığını (Inference) açıklamaktır.

## İçindekiler
1. Gerekli İzinler (Permissions)
2. Sesten Metne Çeviri (Speech-to-Text - STT)
3. Metinden Sese Çeviri (Text-to-Speech - TTS)
4. Kamera Görüntüsü Alma (Camera Stream)
5. Edge AI ve ML Modeli Entegrasyonu
6. Performans ve Optimizasyon (Frame Dropping)
7. Özet
8. AI Implementation Notes

---

## 1. Gerekli İzinler (Permissions)
Cihaz donanımlarına erişmek için işletim sisteminden (iOS/Android) kullanıcı izni alınması zorunludur. `permission_handler` paketi bu işlemi yönetir.
* **Android:** `AndroidManifest.xml` içine `CAMERA` ve `RECORD_AUDIO` izinleri eklenmelidir.
* **iOS:** `Info.plist` dosyasına `NSCameraUsageDescription` ve `NSMicrophoneUsageDescription` eklenmelidir.

---

## 2. Sesten Metne Çeviri (Speech-to-Text - STT)
İşitme engelli olmayan (sağlıklı) bir bireyin uygulamanın mikrofonuna konuşmasını ve bunun metne dökülmesini sağlayan servistir (`stt_service.dart`).
* `speech_to_text` paketi kullanılır.
* İnternet bağlantısı gerektirmeyen (On-device) ses tanıma özelliği destekleyen cihazlarda çevrimdışı (offline) çalışabilir.
* **Mimarideki Yeri:** `SttService` sesi metne dönüştürür ve sonucu `RecognitionProvider`'a iletir; böylece UI tetiklenip ekranda yazıyı gösterir.

---

## 3. Metinden Sese Çeviri (Text-to-Speech - TTS)
Kameranın algıladığı ASL hareketlerinin (metnin) telefondan sesli olarak okunması işlemidir (`tts_service.dart`).
* `flutter_tts` paketi kullanılır.
* Ses hızı, tonu (pitch) ve dil seçenekleri (İngilizce/Türkçe) uygulamanın `SettingsProvider` sınıfından okunarak dinamik olarak ayarlanır.

---

## 4. Kamera Görüntüsü Alma (Camera Stream)
Flutter'ın resmi `camera` paketi kullanılarak cihazın arka veya ön kamerasından saniyede 30 kare (30 FPS) görüntü akışı (Stream) alınır.
* Akış, `CameraImage` nesneleri dizisi halinde `asl_model_service.dart` sınıfına gönderilir.
* Uygulama arka plana atıldığında (App Lifecycle: paused), batarya tüketimini önlemek için kamera bağlantısı durdurulmalıdır (dispose/pause).

---

## 5. Edge AI ve ML Modeli Entegrasyonu
Eğitilmiş Yapay Zeka modeliniz (`model.tflite`) mobil uygulamanın `assets/models/` klasörüne yerleştirilir.
* Kamera'dan gelen her bir kare (Frame), TFLite modelinin beklediği giriş (input tensor) boyutlarına (örn: 224x224 RGB) dönüştürülür (Image processing/Resizing).
* Model görüntüyü yorumlar ve bir sonuç haritası (Output Tensor / Confidence Array) üretir.
* En yüksek güvenilirlik (Confidence) oranına sahip harf/kelime seçilerek `Provider` aracılığıyla arayüze (UI) yansıtılır.

---

## 6. Performans ve Optimizasyon (Frame Dropping)
Saniyede gelen 30 kameranın karesinin tamamını ML modeline sokmak, telefonun aşırı ısınmasına (Thermal Throttling) ve çökmesine sebep olur.
* **Çözüm (Frame Dropping):** `asl_model_service` her gelen kareyi işlemek yerine, her N kareden birini (Örn: her 10 kareden 1'ini - saniyede 3 defa) işleme sokar.
* **Asenkron İşlem:** ML tahmin (Inference) işlemleri kesinlikle `Isolate` (Farklı bir thread) üzerinde veya asenkron `Future` blokları içinde yapılmalıdır. Aksi halde kamera görüntüsü takılır (Stutter).

---

## Özet
Uygulamanın çekirdek "Engelsiz İletişim" modülleri donanım üzerinde çalışır. Kamera veriyi alır, ML modeli metne çevirir (ASL->Text) ve TTS bunu seslendirir. Tam tersi durumda STT sesi alır, metne çevirir ve (gelecek aşamada) videolar ile ASL olarak ekrana yansıtır.

---

## AI IMPLEMENTATION NOTES
* Do NOT run TFLite inference synchronously on the main UI thread. Use `compute()` or Isolates if parsing heavy CameraImage bytes.
* Ensure camera streams are properly managed (`startImageStream`) and that `isDetecting` boolean flags are used to prevent overlapping ML inference calls.
* Add comprehensive `try-catch` blocks around `flutter_tts` and `speech_to_text` initializations, as some emulators or devices lack audio hardware support.

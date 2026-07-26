# 📱 ASL İşaret Dili Tanıma Mobil Uygulaması — Kapsamlı Geliştirme Planı

Bu doküman, **Hibrit Gerçek Zamanlı ASL Tanıma Sistemi** projesinde eğitilen modeli mobil cihazlarda kullanabilmek için geliştirilecek uygulamanın **tüm gereksinimlerini, mimari kararlarını ve adım adım uygulama rehberini** içermektedir.

> [!IMPORTANT]
> Bu plan, başka bir ortamda (Claude, ChatGPT vb.) yapay zeka ile tek seferde uygulamanın geliştirilebilmesi için yeterli detayda hazırlanmıştır. Tüm bölümleri AI'ye prompt olarak verebilirsiniz.

---

## 📋 İçindekiler

1. [Proje Özeti ve Hedefler](#1-proje-özeti-ve-hedefler)
2. [Mevcut Modelin Teknik Analizi](#2-mevcut-modelin-teknik-analizi)
3. [Teknoloji Stack Seçimi ve Gerekçeleri](#3-teknoloji-stack-seçimi-ve-gerekçeleri)
4. [Model Dışa Aktarma (Export) Pipeline](#4-model-dışa-aktarma-export-pipeline)
5. [Uygulama Mimarisi](#5-uygulama-mimarisi)
6. [Ekran Tasarımları ve Kullanıcı Akışı](#6-ekran-tasarımları-ve-kullanıcı-akışı)
7. [Kamera ve Gerçek Zamanlı İşleme Pipeline](#7-kamera-ve-gerçek-zamanlı-işleme-pipeline)
8. [MediaPipe Entegrasyonu (Mobil)](#8-mediapipe-entegrasyonu-mobil)
9. [Model Inference Pipeline (Mobil)](#9-model-inference-pipeline-mobil)
10. [Metin ve Ses Çıktısı Sistemi](#10-metin-ve-ses-çıktısı-sistemi)
11. [Dosya/Klasör Yapısı](#11-dosyaklasör-yapısı)
12. [Adım Adım Geliştirme Rehberi](#12-adım-adım-geliştirme-rehberi)
13. [Performans Optimizasyonları](#13-performans-optimizasyonları)
14. [Test Stratejisi](#14-test-stratejisi)
15. [Dağıtım (Deployment)](#15-dağıtım-deployment)

---

## 1. Proje Özeti ve Hedefler

### 🎯 Ana Hedef
Eğitilmiş hibrit ASL tanıma modelini kullanarak, **telefon kamerasından canlı olarak işaret dilini algılayan**, algılanan işaretleri **metne dönüştüren** ve opsiyonel olarak **sesli olarak okuyan** (Text-to-Speech) bir mobil uygulama geliştirmek.

### 📌 Temel Özellikler

| Özellik | Açıklama | Öncelik |
|:--------|:---------|:--------|
| **Canlı Kamera Algılama** | Gerçek zamanlı kamera görüntüsünden işaret dili tanıma | 🔴 Kritik |
| **Metne Dönüştürme** | Tanınan işaretin ekranda metin olarak gösterilmesi | 🔴 Kritik |
| **Sesli Okuma (TTS)** | Tanınan metnin sesli olarak okunması | 🟡 Yüksek |
| **Kelime Geçmişi** | Tanınan kelimelerin cümle olarak biriktirilmesi | 🟡 Yüksek |
| **Güven Skoru Gösterimi** | Her tahmin için olasılık yüzdesinin gösterilmesi | 🟢 Orta |
| **Çoklu Dil Desteği (TTS)** | İngilizce ve Türkçe sesli okuma | 🟢 Orta |
| **Karanlık/Aydınlık Mod** | Tema desteği | 🔵 Düşük |
| **Ayarlar Paneli** | Güven eşiği, TTS hızı, kamera seçimi | 🔵 Düşük |

### 🚫 Kapsam Dışı (v1.0)
- Video kaydı ve sonradan analiz
- Cümle düzeyinde (continuous) işaret dili tanıma
- Kullanıcıya işaret dili öğretme modülü
- Çevrimiçi model güncelleme

---

## 2. Mevcut Modelin Teknik Analizi

### Model Mimarisi (HybridASLModel)

Projedeki eğitilmiş model aşağıdaki hibrit mimariyi kullanmaktadır:

```
Kamera Karesi (RGB Frame)
         │
         ├──────────────────────────┐
         │                          │
   MediaPipe Tasks API         MediaPipe Tasks API
   (PoseLandmarker)           (HandLandmarker)
         │                          │
         │                    ┌─────┴─────┐
         │                    │           │
   Pose Landmarks (33×3)  Sol El RGB   Sağ El RGB
         │                 Kırpması     Kırpması
         │                 (224×224)    (224×224)
         │                    │           │
   LandmarkEncoder       HandCNNEncoder  HandCNNEncoder
   (MLP: 99→256→128→256)  (ResNet18→256) (ResNet18→256)
         │                    │           │
         └────────┬───────────┴───────────┘
                  │
           ConcatFusion (768→512)
                  │
        TransformerTemporal (CLS Token + 2-Layer Encoder)
                  │
           Classification Head (256→num_classes)
                  │
            Kelime Tahmini (Softmax)
```

### Model Girdileri (Kritik — Mobil Tarafta Birebir Uygulanmalı)

Modelin forward() fonksiyonuna giren `batch` dictionary'si şu yapıdadır:

```python
batch = {
    "pose_landmarks":    Tensor(B, T, 99),        # 33 pose landmark × 3 (x,y,z)
    "left_hand_images":  Tensor(B, T, 3, 224, 224), # Sol el RGB kırpmaları
    "right_hand_images": Tensor(B, T, 3, 224, 224), # Sağ el RGB kırpmaları
    "mask":              Tensor(B, T),               # Boolean mask (geçerli frame'ler)
}
```

- **B** = Batch size (mobilde 1)
- **T** = Frame sayısı (yapılandırmada `num_frames: 16`)
- **99** = 33 pose landmark × 3 koordinat (x, y, z), [0, 1] normalize
- **224×224** = El kırpma boyutu (ResNet girdi boyutu)
- Piksel değerleri `float32`, `[0, 1]` aralığına normalize edilmiş

### Model Çıktısı

```python
logits = model(batch)  # (1, num_classes) → örneğin (1, 100)
probs = torch.softmax(logits, dim=-1)  # Olasılık dağılımı
predicted_class = probs.argmax(dim=-1)  # En yüksek olasılıklı sınıf indexi
```

### Sınıf Etiketleri

`wlasl_class_list.txt` dosyasından okunur:
```
0   book
1   drink
2   computer
3   before
4   chair
...
99  wrong
```

### Eğitim Yapılandırması (wlasl100_baseline.yaml)

| Parametre | Değer | Mobil Etkisi |
|:----------|:------|:-------------|
| `num_classes` | 100 | Çıktı katmanı boyutu |
| `num_frames` | 16 | Kameradan toplanacak frame sayısı |
| `hand_encoder.backbone` | `resnet18` | ONNX/TFLite dönüşüm boyutu |
| `hand_encoder.input_size` | `[224, 224]` | El kırpma boyutu |
| `landmark_encoder.input_dim` | 99 | Pose landmark vektör boyutu |
| `fusion.method` | `concat` | Birleştirme stratejisi |
| `temporal.method` | `transformer` | 2 katmanlı transformer encoder |
| `temporal.hidden_dim` | 256 | Temporal çıktı boyutu |

---

## 3. Teknoloji Stack Seçimi ve Gerekçeleri

### Önerilen Yaklaşım: React Native + ONNX Runtime

| Katman | Teknoloji | Gerekçe |
|:-------|:----------|:--------|
| **Framework** | React Native (Expo) | Tek kod tabanından iOS + Android. Expo ile hızlı geliştirme. |
| **Kamera** | `expo-camera` / `react-native-vision-camera` | Yüksek performanslı kamera erişimi, frame processing desteği |
| **MediaPipe** | `@mediapipe/tasks-vision` (WASM/JS) veya Native modül | Pose + Hand landmark çıkarma |
| **Model Inference** | `onnxruntime-react-native` | ONNX modeli mobilde çalıştırma |
| **TTS (Sesli Okuma)** | `expo-speech` | Platform native TTS motoru |
| **State Management** | React Context + useReducer | Hafif, yeterli |
| **UI Kütüphanesi** | React Native Paper veya özel bileşenler | Material Design |
| **Navigation** | `expo-router` | Dosya tabanlı yönlendirme |

### Alternatif Yaklaşımlar Karşılaştırması

| Yaklaşım | Avantajı | Dezavantajı | Tavsiye |
|:---------|:---------|:------------|:--------|
| **React Native + ONNX** | Tek kod, hızlı geliştirme, ONNX desteği | Frame processing overhead | ✅ **Önerilen** |
| **Flutter + TFLite** | Dart ekosistemi, TFLite entegrasyonu | MediaPipe entegrasyonu zor | ⚠️ Alternatif |
| **Native Android (Kotlin)** | En yüksek performans, MediaPipe SDK | Sadece Android, uzun geliştirme | ⚠️ Sadece Android |
| **Native iOS (Swift)** | CoreML desteği, en iyi iOS performansı | Sadece iOS | ⚠️ Sadece iOS |
| **Kotlin Multiplatform** | Paylaşımlı iş mantığı | Olgunlaşmamış ekosistem | ❌ Riskli |

> [!TIP]
> Eğer sadece Android hedeflenecekse, **Native Kotlin + MediaPipe Android SDK + ONNX Runtime Android** en yüksek performansı verir. Hem iOS hem Android isteniyorsa React Native en pratik seçenektir.

---

## 4. Model Dışa Aktarma (Export) Pipeline

Model mobilde çalışabilmesi için ONNX formatına aktarılmalıdır. Bu adım bitirme projesi reposunda yapılır.

### 4.1. ONNX Export Kodunun Tamamlanması

Mevcut projede `src/export/onnx_exporter.py` dosyasındaki TODO'lar tamamlanmalıdır:

```python
# src/export/onnx_exporter.py — Tamamlanmış hali

import torch
import torch.nn as nn
from pathlib import Path

class ONNXExporter:
    def __init__(self, model: nn.Module, opset_version: int = 17):
        self.model = model
        self.opset_version = opset_version

    def export(self, output_path, sample_inputs, dynamic_axes=None):
        output_path = Path(output_path)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        self.model.eval()

        # Girdi isimlerini ve tensor'ları ayır
        input_names = list(sample_inputs.keys())
        input_tensors = tuple(sample_inputs.values())

        torch.onnx.export(
            self.model,
            (sample_inputs,),  # Model dict girdi alıyor
            str(output_path),
            opset_version=self.opset_version,
            input_names=input_names,
            output_names=["logits"],
            dynamic_axes=dynamic_axes or {
                "pose_landmarks": {0: "batch", 1: "time"},
                "left_hand_images": {0: "batch", 1: "time"},
                "right_hand_images": {0: "batch", 1: "time"},
                "mask": {0: "batch", 1: "time"},
                "logits": {0: "batch"},
            },
        )
        return output_path

    def verify(self, onnx_path):
        import onnx
        model = onnx.load(str(onnx_path))
        onnx.checker.check_model(model)
        return True
```

### 4.2. Export Betiği (scripts/export_onnx.py)

```python
# scripts/export_onnx.py — Tamamlanmış export betiği

import torch
from src.core.config import load_config
from src.models.hybrid_model import HybridASLModel
from src.export.onnx_exporter import ONNXExporter

def main():
    config = load_config("configs/experiment/wlasl100_baseline.yaml")
    
    # Model yükleme
    model = HybridASLModel(config.model)
    checkpoint = torch.load("outputs/wlasl100_baseline/checkpoints/best_model.pt",
                            map_location="cpu", weights_only=False)
    model.load_state_dict(checkpoint["model_state_dict"])
    model.eval()

    # Örnek girdi tensörleri (batch=1, T=16)
    T = config.dataset.num_frames  # 16
    sample_inputs = {
        "pose_landmarks": torch.randn(1, T, 99),
        "left_hand_images": torch.randn(1, T, 3, 224, 224),
        "right_hand_images": torch.randn(1, T, 3, 224, 224),
        "mask": torch.ones(1, T, dtype=torch.bool),
    }

    exporter = ONNXExporter(model, opset_version=17)
    output = exporter.export("exports/asl_hybrid_model.onnx", sample_inputs)
    exporter.verify(output)
    print(f"Model başarıyla export edildi: {output}")

if __name__ == "__main__":
    main()
```

### 4.3. ONNX Model Optimizasyonu (Mobil İçin)

```bash
# ONNX model boyutunu küçültme ve optimize etme
pip install onnxruntime onnx onnxoptimizer

python -c "
import onnxruntime as ort

# Quantization (INT8) — Model boyutunu ~4x küçültür
from onnxruntime.quantization import quantize_dynamic, QuantType

quantize_dynamic(
    'exports/asl_hybrid_model.onnx',
    'exports/asl_hybrid_model_quantized.onnx',
    weight_type=QuantType.QUInt8
)
print('Quantized model oluşturuldu.')
"
```

### 4.4. Export Sonrası Kontrol Listesi

- [ ] `exports/asl_hybrid_model.onnx` → Orijinal ONNX model (~50-80 MB beklenen)
- [ ] `exports/asl_hybrid_model_quantized.onnx` → Quantized model (~15-25 MB beklenen)
- [ ] `wlasl_class_list.txt` → Sınıf etiketleri dosyası (mobil uygulamaya kopyalanacak)
- [ ] ONNX model doğrulama testi geçti mi?
- [ ] Quantized model ile orijinal model arasındaki doğruluk farkı kabul edilebilir mi? (<%2 düşüş)

---

## 5. Uygulama Mimarisi

### 5.1. Üst Düzey Mimari

```
┌─────────────────────────────────────────────────────┐
│                    React Native App                  │
│                                                     │
│  ┌──────────┐   ┌──────────────┐   ┌─────────────┐ │
│  │  Kamera   │──▶│  İşleme      │──▶│  Sonuç      │ │
│  │  Katmanı  │   │  Pipeline    │   │  Gösterim   │ │
│  └──────────┘   └──────────────┘   └─────────────┘ │
│       │               │                    │        │
│       ▼               ▼                    ▼        │
│  ┌──────────┐   ┌──────────────┐   ┌─────────────┐ │
│  │  Frame    │   │  MediaPipe   │   │  Text-to-   │ │
│  │  Sampler  │   │  + ONNX      │   │  Speech     │ │
│  └──────────┘   └──────────────┘   └─────────────┘ │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │           State Management Layer             │    │
│  │  (predictions, settings, history, UI state)  │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 5.2. Veri Akış Diyagramı (Her Frame İçin)

```
1. Kamera frame yakala (30 FPS)
         │
2. Frame buffer'a ekle (son 16 frame'i tut, sıralı kuyruk)
         │
3. Buffer dolduğunda (16 frame) → İşleme tetikle
         │
   ┌─────┴──────────────────────────┐
   │                                │
4a. MediaPipe PoseLandmarker     4b. MediaPipe HandLandmarker
    (Her frame için 33×3)           (Her frame için sol/sağ el tespit)
         │                                │
         │                          4c. El Bölgesi Kırpma
         │                          (Landmark → BBox → Crop → 224×224 Resize)
         │                                │
   └─────┬────────────────────────────────┘
         │
5. Tensor Oluşturma:
   - pose_landmarks: (1, 16, 99) float32
   - left_hand_images: (1, 16, 3, 224, 224) float32 [0-1]
   - right_hand_images: (1, 16, 3, 224, 224) float32 [0-1]
   - mask: (1, 16) bool
         │
6. ONNX Runtime Inference
         │
7. Softmax → Top-K Tahminler
         │
8. Güven Eşiği Kontrolü (örn. > %60)
         │
   ┌─────┴─────┐
   │            │
9a. Ekrana     9b. Text-to-Speech
    Yazdır         ile Seslendir
```

### 5.3. State Yapısı

```typescript
interface AppState {
  // Kamera
  cameraReady: boolean;
  cameraFacing: 'front' | 'back';

  // Tahmin
  currentPrediction: {
    label: string;           // "book", "hello" vb.
    confidence: number;      // 0.0 - 1.0
    classIndex: number;      // 0-99
    timestamp: number;       // Date.now()
  } | null;

  topKPredictions: Array<{
    label: string;
    confidence: number;
  }>;

  // Cümle oluşturma
  sentenceBuffer: string[];  // ["hello", "how", "are", "you"]

  // Ayarlar
  settings: {
    confidenceThreshold: number;  // 0.5 - 0.95
    ttsEnabled: boolean;
    ttsLanguage: 'en-US' | 'tr-TR';
    ttsRate: number;              // 0.5 - 2.0
    inferenceInterval: number;    // ms cinsinden (örn. 500ms)
    showLandmarks: boolean;       // Landmark overlay göster/gizle
  };

  // Geçmiş
  history: Array<{
    word: string;
    confidence: number;
    timestamp: Date;
  }>;

  // Sistem
  isProcessing: boolean;
  modelLoaded: boolean;
  fps: number;
  errorMessage: string | null;
}
```

---

## 6. Ekran Tasarımları ve Kullanıcı Akışı

### 6.1. Ekran Listesi

```
App
├── SplashScreen          → Model yükleme (bir kerelik)
├── MainScreen            → Ana kamera + tahmin ekranı
│   ├── CameraView        → Kamera önizleme + landmark overlay
│   ├── PredictionBar     → Anlık tahmin + güven skoru
│   ├── SentenceArea      → Biriken kelimeler
│   └── ActionButtons     → TTS, Temizle, Ayarlar
├── SettingsScreen        → Uygulama ayarları
└── HistoryScreen         → Geçmiş tahminler
```

### 6.2. Ana Ekran (MainScreen) Düzeni

```
┌──────────────────────────────────────┐
│  ⚙️ Ayarlar              📊 30 FPS  │ ← Üst bar
├──────────────────────────────────────┤
│                                      │
│                                      │
│         📹 KAMERA GÖRÜNTÜSÜ         │ ← Tam ekran kamera
│     (Landmark overlay isteğe bağlı)  │
│                                      │
│                                      │
│                                      │
├──────────────────────────────────────┤
│  🏆  "HELLO"         %92.3          │ ← Tahmin kartı (büyük font)
│  2: "HI" %5.1  3: "HEY" %1.2       │ ← Alt tahminler (küçük font)
├──────────────────────────────────────┤
│                                      │
│  Hello, how are you ▌                │ ← Cümle alanı
│                                      │
├──────────────────────────────────────┤
│  🔊 Seslendir    🗑️ Temizle   📷    │ ← Aksiyon butonları
└──────────────────────────────────────┘
```

### 6.3. Kullanıcı Akışı

```
Uygulama Açılır
    │
    ▼
[Splash Screen: Model Yükleniyor... (%)]
    │
    ▼
Kamera İzni İstenir
    │
    ├── İzin Verildi → Ana Ekran
    │
    └── İzin Reddedildi → Hata Mesajı + Yeniden İste
    
Ana Ekran:
    │
    ├── Kullanıcı işaret yapar → Tahmin gösterilir
    │       │
    │       ├── Güven > Eşik → Kelime cümleye eklenir
    │       │
    │       └── Güven < Eşik → Gösterilir ama eklenmez (soluk)
    │
    ├── 🔊 Seslendir → Cümle TTS ile okunur
    │
    ├── 🗑️ Temizle → Cümle sıfırlanır
    │
    ├── ⚙️ Ayarlar → Ayarlar ekranı
    │
    └── 📷 Kamera değiştir → Ön/arka kamera
```

---

## 7. Kamera ve Gerçek Zamanlı İşleme Pipeline

### 7.1. Frame Yakalama Stratejisi

```typescript
// Kamera frame yakalama — sliding window yaklaşımı
const FRAME_BUFFER_SIZE = 16;       // Model'in beklediği frame sayısı
const CAPTURE_FPS = 5;              // Saniyede yakalanan frame (30 FPS'ten düşürülmüş)
const INFERENCE_INTERVAL_MS = 3000; // Her 3 saniyede bir inference

// ÖNEMLİ: Kameranın native FPS'i (30) ile model için gereken FPS farklıdır.
// 16 frame / 5 FPS = 3.2 saniye pencere → Bir işaret hareketini yakalamak için yeterli.
```

### 7.2. Frame Buffer Yönetimi

```typescript
class FrameBuffer {
  private buffer: Frame[] = [];
  private readonly maxSize: number = 16;

  addFrame(frame: Frame): void {
    this.buffer.push(frame);
    if (this.buffer.length > this.maxSize) {
      this.buffer.shift(); // En eski frame'i çıkar (FIFO)
    }
  }

  isReady(): boolean {
    return this.buffer.length === this.maxSize;
  }

  getFrames(): Frame[] {
    return [...this.buffer]; // Kopyasını döndür
  }

  clear(): void {
    this.buffer = [];
  }
}
```

### 7.3. Frame İşleme Akışı

Her frame için yapılacak işlemler:

```
Frame (RGB, uint8, H×W×3)
    │
    ├─ 1. Resize (performans için, isteğe bağlı)
    │
    ├─ 2. MediaPipe PoseLandmarker.detect(frame)
    │      → pose_landmarks: (33, 3) float32 veya null
    │
    ├─ 3. MediaPipe HandLandmarker.detect(frame)
    │      → handedness: "Left"/"Right"
    │      → hand_landmarks: (21, 3) float32
    │      ⚠️ MediaPipe "Left" = kameradaki sol = gerçekte SAĞ el
    │
    ├─ 4. El Kırpma (Hand Cropping):
    │      - Hand landmarks'tan bounding box hesapla
    │      - %20 padding ekle
    │      - Frame'den kırp
    │      - Kareye dönüştür (en/boy eşitle, siyah dolgu)
    │      - 224×224'e resize
    │      - El algılanmadıysa → siyah (zero) 224×224 görüntü
    │
    └─ 5. Pose landmarks'ı düzleştir: (33, 3) → (99,) float32
```

> [!WARNING]
> **MediaPipe El Etiketleri Ters Çalışır!** MediaPipe kamera görünümüne göre etiketler:
> - MediaPipe `"Left"` → Gerçekte kullanıcının **sağ eli**
> - MediaPipe `"Right"` → Gerçekte kullanıcının **sol eli**
> 
> Bu, eğitim kodunda (`mediapipe_extractor.py` satır 281-284) doğru şekilde uygulanmıştır. Mobilde de aynı mantık uygulanmalıdır.

---

## 8. MediaPipe Entegrasyonu (Mobil)

### 8.1. Kullanılacak MediaPipe Modelleri

| Model | Dosya | Boyut | Kullanım |
|:------|:------|:------|:---------|
| PoseLandmarker | `pose_landmarker_lite.task` | ~5.5 MB | Vücut iskeleti (33 nokta) |
| HandLandmarker | `hand_landmarker.task` | ~7.5 MB | El noktaları (21 nokta × 2 el) |

> [!TIP]
> Mobilde **lite** model tercih edilmelidir (daha hızlı). Eğitimde **full** model kullanılmış olsa bile, lite modelin landmark çıktıları aynı formattadır.

### 8.2. React Native'de MediaPipe Kullanım Seçenekleri

**Seçenek A — @mediapipe/tasks-vision (WebView/JS)**
```javascript
// WebView içinde çalıştırılan MediaPipe JS SDK
import { PoseLandmarker, HandLandmarker, FilesetResolver } from '@mediapipe/tasks-vision';

const vision = await FilesetResolver.forVisionTasks(
  'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision/wasm'
);

const poseLandmarker = await PoseLandmarker.createFromOptions(vision, {
  baseOptions: { modelAssetPath: 'pose_landmarker_lite.task' },
  runningMode: 'VIDEO',
  numPoses: 1,
});

const handLandmarker = await HandLandmarker.createFromOptions(vision, {
  baseOptions: { modelAssetPath: 'hand_landmarker.task' },
  runningMode: 'VIDEO',
  numHands: 2,
});
```

**Seçenek B — Native Modül (Performans için önerilir)**
```
Android: com.google.mediapipe:tasks-vision (Gradle)
iOS: MediaPipeTasksVision (CocoaPods/SPM)

React Native bridge ile native tarafta MediaPipe çalıştırılır,
sonuçlar JSON olarak JS tarafına gönderilir.
```

**Seçenek C — react-native-vision-camera + Frame Processor Plugin**
```typescript
// vision-camera-mediapipe-plugin ile doğrudan frame üzerinde çalışma
import { useFrameProcessor } from 'react-native-vision-camera';
import { detectPose, detectHands } from 'vision-camera-mediapipe';

const frameProcessor = useFrameProcessor((frame) => {
  'worklet';
  const pose = detectPose(frame);
  const hands = detectHands(frame);
  // ... işleme
}, []);
```

> [!IMPORTANT]
> **Önerilen yaklaşım:** `react-native-vision-camera` v4+ kullanarak Frame Processor plugin yazılması. Bu, en düşük gecikme süresini ve en yüksek FPS'i sağlar. MediaPipe native SDK'ları doğrudan C++/Java/Swift üzerinden çağrılır.

---

## 9. Model Inference Pipeline (Mobil)

### 9.1. ONNX Runtime Kurulumu

```bash
npm install onnxruntime-react-native
```

### 9.2. Model Yükleme

```typescript
import { InferenceSession, Tensor } from 'onnxruntime-react-native';

class ASLModelService {
  private session: InferenceSession | null = null;
  private classNames: Map<number, string> = new Map();

  async initialize(): Promise<void> {
    // 1. ONNX model yükle
    this.session = await InferenceSession.create(
      'asset:///models/asl_hybrid_model_quantized.onnx',
      {
        executionProviders: ['cpu'],  // veya 'nnapi' (Android) / 'coreml' (iOS)
        graphOptimizationLevel: 'all',
      }
    );

    // 2. Sınıf isimlerini yükle
    const classListText = await loadAsset('models/wlasl_class_list.txt');
    classListText.split('\n').forEach(line => {
      const parts = line.trim().split(/\s+/);
      if (parts.length >= 2) {
        this.classNames.set(parseInt(parts[0]), parts[1]);
      }
    });
  }

  async predict(input: ModelInput): Promise<PredictionResult> {
    if (!this.session) throw new Error('Model yüklenmedi');

    const feeds = {
      pose_landmarks: new Tensor('float32', input.poseLandmarks, [1, 16, 99]),
      left_hand_images: new Tensor('float32', input.leftHandImages, [1, 16, 3, 224, 224]),
      right_hand_images: new Tensor('float32', input.rightHandImages, [1, 16, 3, 224, 224]),
      mask: new Tensor('bool', input.mask, [1, 16]),
    };

    const results = await this.session.run(feeds);
    const logits = results.logits.data as Float32Array;

    // Softmax uygula
    const probs = softmax(logits);

    // Top-5 tahmin
    const topK = getTopK(probs, 5);

    return {
      predictions: topK.map(({ index, probability }) => ({
        label: this.classNames.get(index) || `class_${index}`,
        confidence: probability,
        classIndex: index,
      })),
      inferenceTimeMs: Date.now() - startTime,
    };
  }
}
```

### 9.3. Tensor Hazırlama (Preprocessing — Mobil Tarafta)

```typescript
function prepareModelInput(
  frames: ProcessedFrame[],
  numFrames: number = 16
): ModelInput {
  // Frame sayısını 16'ya pad/truncate et
  const paddedFrames = padFrames(frames, numFrames);

  // Pose landmarks: (16, 99) → flatten → Float32Array
  const poseLandmarks = new Float32Array(numFrames * 99);
  paddedFrames.forEach((frame, t) => {
    if (frame.poseLandmarks) {
      // (33, 3) → (99,)
      for (let i = 0; i < 33; i++) {
        poseLandmarks[t * 99 + i * 3 + 0] = frame.poseLandmarks[i].x;
        poseLandmarks[t * 99 + i * 3 + 1] = frame.poseLandmarks[i].y;
        poseLandmarks[t * 99 + i * 3 + 2] = frame.poseLandmarks[i].z;
      }
    }
    // else: zaten 0 (Float32Array default)
  });

  // Hand images: uint8 [0-255] → float32 [0-1], HWC → CHW
  const leftHandImages = new Float32Array(numFrames * 3 * 224 * 224);
  const rightHandImages = new Float32Array(numFrames * 3 * 224 * 224);

  paddedFrames.forEach((frame, t) => {
    const offset = t * 3 * 224 * 224;
    convertImageToTensor(frame.leftHandCrop, leftHandImages, offset);
    convertImageToTensor(frame.rightHandCrop, rightHandImages, offset);
  });

  // Mask: geçerli frame'ler için true
  const mask = new Uint8Array(numFrames);
  for (let i = 0; i < Math.min(frames.length, numFrames); i++) {
    mask[i] = 1;
  }

  return { poseLandmarks, leftHandImages, rightHandImages, mask };
}

// HWC uint8 → CHW float32 [0,1] dönüşümü
function convertImageToTensor(
  image: Uint8Array, // (224*224*3) RGB
  output: Float32Array,
  offset: number
): void {
  const H = 224, W = 224;
  for (let h = 0; h < H; h++) {
    for (let w = 0; w < W; w++) {
      const pixelIdx = (h * W + w) * 3;
      // CHW format: [C][H][W]
      output[offset + 0 * H * W + h * W + w] = image[pixelIdx + 0] / 255.0; // R
      output[offset + 1 * H * W + h * W + w] = image[pixelIdx + 1] / 255.0; // G
      output[offset + 2 * H * W + h * W + w] = image[pixelIdx + 2] / 255.0; // B
    }
  }
}
```

### 9.4. Softmax ve Top-K Fonksiyonları

```typescript
function softmax(logits: Float32Array): Float32Array {
  const max = Math.max(...logits);
  const exps = logits.map(v => Math.exp(v - max));
  const sum = exps.reduce((a, b) => a + b, 0);
  return exps.map(v => v / sum);
}

function getTopK(
  probs: Float32Array, 
  k: number
): Array<{ index: number; probability: number }> {
  const indexed = Array.from(probs).map((p, i) => ({ index: i, probability: p }));
  indexed.sort((a, b) => b.probability - a.probability);
  return indexed.slice(0, k);
}
```

---

## 10. Metin ve Ses Çıktısı Sistemi

### 10.1. Kelime Birikimi ve Cümle Oluşturma

```typescript
class SentenceBuilder {
  private words: string[] = [];
  private lastWord: string = '';
  private lastTimestamp: number = 0;
  private readonly DEBOUNCE_MS = 2000; // Aynı kelimeyi tekrar eklememe süresi

  addPrediction(word: string, confidence: number, threshold: number): boolean {
    if (confidence < threshold) return false;

    const now = Date.now();

    // Aynı kelime çok kısa sürede tekrar edilmesin (debounce)
    if (word === this.lastWord && (now - this.lastTimestamp) < this.DEBOUNCE_MS) {
      return false;
    }

    this.words.push(word);
    this.lastWord = word;
    this.lastTimestamp = now;
    return true;
  }

  getSentence(): string {
    return this.words.join(' ');
  }

  clear(): void {
    this.words = [];
    this.lastWord = '';
  }

  removeLastWord(): void {
    this.words.pop();
  }
}
```

### 10.2. Text-to-Speech Entegrasyonu

```typescript
import * as Speech from 'expo-speech';

class TTSService {
  private speaking: boolean = false;

  async speak(text: string, options: TTSOptions): Promise<void> {
    if (this.speaking) {
      await Speech.stop();
    }

    this.speaking = true;
    await Speech.speak(text, {
      language: options.language,   // 'en-US' veya 'tr-TR'
      rate: options.rate,           // 0.5 - 2.0
      pitch: options.pitch || 1.0,
      onDone: () => { this.speaking = false; },
      onError: () => { this.speaking = false; },
    });
  }

  async stop(): Promise<void> {
    await Speech.stop();
    this.speaking = false;
  }

  // Tek bir kelimeyi anlık seslendir
  async speakWord(word: string, language: string): Promise<void> {
    await Speech.speak(word, { language, rate: 1.0 });
  }
}
```

---

## 11. Dosya/Klasör Yapısı

```
ASLTranslatorApp/
├── app/                          # Expo Router sayfaları
│   ├── _layout.tsx              # Root layout (navigation)
│   ├── index.tsx                # Splash/loading ekranı
│   ├── main.tsx                 # Ana kamera ekranı
│   ├── settings.tsx             # Ayarlar ekranı
│   └── history.tsx              # Geçmiş ekranı
│
├── src/
│   ├── components/              # UI bileşenleri
│   │   ├── CameraView.tsx       # Kamera görünümü + overlay
│   │   ├── PredictionCard.tsx   # Tahmin gösterimi kartı
│   │   ├── SentenceBar.tsx      # Cümle biriktirme alanı
│   │   ├── LandmarkOverlay.tsx  # Landmark çizim overlay
│   │   ├── ConfidenceMeter.tsx  # Güven skoru göstergesi
│   │   ├── ActionButton.tsx     # Aksiyon butonları
│   │   └── TopKList.tsx         # Top-K tahmin listesi
│   │
│   ├── services/                # İş mantığı servisleri
│   │   ├── ASLModelService.ts   # ONNX model yükleme ve inference
│   │   ├── MediaPipeService.ts  # MediaPipe landmark çıkarma
│   │   ├── HandCropService.ts   # El kırpma ve preprocessing
│   │   ├── FrameBufferService.ts # Frame buffer yönetimi
│   │   ├── TTSService.ts        # Text-to-Speech servisi
│   │   └── SentenceBuilder.ts   # Cümle biriktirme
│   │
│   ├── hooks/                   # React hooks
│   │   ├── useASLRecognition.ts # Ana tanıma hook'u (tüm pipeline)
│   │   ├── useFrameProcessor.ts # Frame işleme hook'u
│   │   ├── useSettings.ts       # Ayarlar hook'u
│   │   └── useModelLoader.ts    # Model yükleme hook'u
│   │
│   ├── context/                 # React Context
│   │   ├── AppContext.tsx       # Global uygulama state'i
│   │   └── SettingsContext.tsx  # Ayarlar state'i
│   │
│   ├── utils/                   # Yardımcı fonksiyonlar
│   │   ├── tensorUtils.ts       # Tensor dönüşüm fonksiyonları
│   │   ├── imageUtils.ts        # Görüntü işleme fonksiyonları
│   │   ├── mathUtils.ts         # Softmax, top-k vb.
│   │   └── constants.ts         # Sabitler
│   │
│   ├── types/                   # TypeScript tip tanımları
│   │   ├── prediction.ts        # Tahmin tipleri
│   │   ├── landmarks.ts         # Landmark tipleri
│   │   └── settings.ts          # Ayar tipleri
│   │
│   └── styles/                  # Stil dosyaları
│       ├── theme.ts             # Tema tanımları
│       ├── colors.ts            # Renk paleti
│       └── typography.ts        # Font ayarları
│
├── assets/
│   ├── models/
│   │   ├── asl_hybrid_model_quantized.onnx  # Quantized ONNX model
│   │   ├── pose_landmarker_lite.task         # MediaPipe pose modeli
│   │   ├── hand_landmarker.task              # MediaPipe el modeli
│   │   └── wlasl_class_list.txt              # Sınıf etiketleri
│   │
│   ├── fonts/                   # Özel fontlar
│   └── images/                  # UI görselleri (ikon, logo vb.)
│
├── app.json                     # Expo yapılandırma
├── package.json                 # Bağımlılıklar
├── tsconfig.json                # TypeScript yapılandırma
├── babel.config.js              # Babel yapılandırma
└── README.md                    # Proje açıklaması
```

---

## 12. Adım Adım Geliştirme Rehberi

### Faz 0: Model Hazırlığı (Bitirme Projesi Reposunda)

```
[ ] 0.1. Model eğitiminin tamamlanması ve en iyi checkpoint'in kaydedilmesi
[ ] 0.2. onnx_exporter.py kodunun tamamlanması (TODO'ların doldurulması)
[ ] 0.3. export_onnx.py betiğinin çalıştırılması
[ ] 0.4. ONNX modelin doğrulanması (onnx.checker)
[ ] 0.5. ONNX modelin quantize edilmesi (INT8)
[ ] 0.6. Quantized modelin doğruluk testinin yapılması
[ ] 0.7. wlasl_class_list.txt dosyasının kopyalanması
```

### Faz 1: Proje Kurulumu

```bash
# 1.1. Expo projesi oluştur
npx -y create-expo-app@latest ASLTranslatorApp --template blank-typescript

# 1.2. Gerekli paketleri kur
cd ASLTranslatorApp
npx expo install expo-camera expo-speech expo-router
npm install onnxruntime-react-native
npm install react-native-vision-camera
npm install react-native-reanimated
npm install @react-navigation/native

# 1.3. TypeScript yapılandırması
# tsconfig.json strict mode aktif edilmeli
```

```
[ ] 1.1. Expo projesi oluştur
[ ] 1.2. Bağımlılıkları kur
[ ] 1.3. Dosya/klasör yapısını oluştur
[ ] 1.4. ONNX model ve MediaPipe task dosyalarını assets/ altına kopyala
[ ] 1.5. TypeScript ve ESLint yapılandırması
```

### Faz 2: Temel UI Bileşenleri

```
[ ] 2.1. Tema ve renk paleti tanımla (styles/theme.ts)
[ ] 2.2. SplashScreen (model yükleme göstergeli)
[ ] 2.3. MainScreen temel layout
[ ] 2.4. CameraView bileşeni (sadece kamera önizleme)
[ ] 2.5. PredictionCard bileşeni (mock veri ile)
[ ] 2.6. SentenceBar bileşeni (mock veri ile)
[ ] 2.7. ActionButton bileşenleri
[ ] 2.8. SettingsScreen
[ ] 2.9. Navigation yapılandırması (expo-router)
```

### Faz 3: Kamera ve Frame Yakalama

```
[ ] 3.1. Kamera izinleri yönetimi
[ ] 3.2. react-native-vision-camera entegrasyonu
[ ] 3.3. FrameBufferService implementasyonu
[ ] 3.4. Frame yakalama ve buffer'a ekleme (5 FPS)
[ ] 3.5. Ön/arka kamera geçişi
[ ] 3.6. Kamera hata yönetimi
```

### Faz 4: MediaPipe Entegrasyonu

```
[ ] 4.1. MediaPipe native modül kurulumu veya JS SDK entegrasyonu
[ ] 4.2. PoseLandmarker entegrasyonu (frame → 33 pose landmark)
[ ] 4.3. HandLandmarker entegrasyonu (frame → sol/sağ el landmark)
[ ] 4.4. Landmark sonuçlarını yapılandırılmış veri yapısına dönüştürme
[ ] 4.5. LandmarkOverlay bileşeni (kamera üzerine iskelet çizimi)
[ ] 4.6. MediaPipe performans optimizasyonu (lite modeller)
```

### Faz 5: El Kırpma Pipeline

```
[ ] 5.1. HandCropService implementasyonu
[ ] 5.2. Landmark → Bounding box hesaplama (%20 padding)
[ ] 5.3. RGB kırpma → Kareye dönüştürme → 224×224 resize
[ ] 5.4. El algılanmadığında siyah 224×224 fallback
[ ] 5.5. El etiketleri ters çevirme (MediaPipe Left→Sağ el)
[ ] 5.6. Kırpma sonuçlarını debug ekranında görüntüleme
```

### Faz 6: ONNX Model Inference

```
[ ] 6.1. ASLModelService — model yükleme
[ ] 6.2. Sınıf isimlerini yükleme (wlasl_class_list.txt parse)
[ ] 6.3. Tensor hazırlama (HWC→CHW, uint8→float32, normalizasyon)
[ ] 6.4. ONNX Runtime inference çağrısı
[ ] 6.5. Softmax ve Top-K hesaplama
[ ] 6.6. Inference süresi ölçümü (profiling)
[ ] 6.7. Execution provider seçimi (CPU/NNAPI/CoreML)
```

### Faz 7: Tüm Pipeline'ın Birleştirilmesi

```
[ ] 7.1. useASLRecognition hook'u — tüm pipeline'ı birleştir
[ ] 7.2. Frame yakalama → MediaPipe → El kırpma → Tensor → Inference akışı
[ ] 7.3. Inference zamanlayıcısı (her 3 saniyede veya buffer dolduğunda)
[ ] 7.4. Güven eşiği filtreleme
[ ] 7.5. UI'ye sonuç aktarımı (tahmin, güven skoru, FPS)
[ ] 7.6. Hata yönetimi ve fallback
```

### Faz 8: Text-to-Speech

```
[ ] 8.1. TTSService implementasyonu
[ ] 8.2. Anlık kelime seslendirme (her tahmin sonrası isteğe bağlı)
[ ] 8.3. Cümle seslendirme (Seslendir butonuyla)
[ ] 8.4. TTS ayarları (hız, dil)
[ ] 8.5. SentenceBuilder entegrasyonu (debounce, tekrar engelleme)
```

### Faz 9: Polish ve Optimizasyon

```
[ ] 9.1. UI animasyonları (tahmin kartı geçişleri, güven göstergesi)
[ ] 9.2. Performans optimizasyonu (gereksiz render'ları önleme)
[ ] 9.3. Bellek yönetimi (frame buffer temizleme, model instance)
[ ] 9.4. Düşük pil uyarısı ve performans modu
[ ] 9.5. Erişilebilirlik (accessibility labels)
[ ] 9.6. Karanlık mod desteği
[ ] 9.7. App icon ve splash screen tasarımı
```

---

## 13. Performans Optimizasyonları

### 13.1. Model Boyutu Küçültme

| Teknik | Boyut Azalması | Doğruluk Kaybı |
|:-------|:---------------|:---------------|
| Float32 (orijinal) | Referans | Referans |
| INT8 Dynamic Quantization | ~4x küçülme | <%2 |
| Float16 | ~2x küçülme | <%0.5 |
| Pruning + Quantization | ~6-8x küçülme | <%5 |

### 13.2. Inference Hızlandırma

```
1. ONNX Graph Optimization: ort.GraphOptimizationLevel.ORT_ENABLE_ALL
2. Android: NNAPI Execution Provider (GPU/DSP hızlandırma)
3. iOS: CoreML Execution Provider
4. Quantized model kullanma (INT8)
5. Input boyutunu küçültme (224→160 el kırpma, accuracy trade-off)
6. MediaPipe lite modelleri kullanma
7. Frame örnekleme oranını düşürme (5→3 FPS)
```

### 13.3. Bellek Yönetimi

```typescript
// Frame buffer'ı düzenli temizle
// ONNX session'ı bir kez yükle, tekrar kullanma
// Büyük tensor'ları işlem sonrası serbest bırak
// Kamera preview çözünürlüğünü düşük tut (640×480)
```

### 13.4. Hedef Performans Metrikleri

| Metrik | Hedef | Kabul Edilebilir |
|:-------|:------|:-----------------|
| Inference süresi | <500ms | <1000ms |
| Toplam pipeline (frame→tahmin) | <1s | <2s |
| Bellek kullanımı | <300MB | <500MB |
| APK/IPA boyutu | <100MB | <150MB |
| Pil tüketimi (1 saat) | <%30 | <%50 |

---

## 14. Test Stratejisi

### 14.1. Birim Testleri
```
- Softmax hesaplama doğruluğu
- Top-K sıralama doğruluğu
- HWC→CHW dönüşüm doğruluğu
- Normalize (0-255 → 0-1) doğruluğu
- El kırpma bounding box hesaplama
- SentenceBuilder debounce mantığı
- Frame buffer FIFO davranışı
```

### 14.2. Entegrasyon Testleri
```
- ONNX model yükleme ve inference (bilinen girdiyle)
- MediaPipe → Tensor dönüşüm zinciri
- Python inference.py ile aynı sonucu üretme (cross-validation)
```

### 14.3. Kabul Testleri
```
- 5 farklı işaret için doğru tahmin
- TTS'in doğru kelimeyi okuması
- Kamera izni akışının sorunsuz çalışması
- Ön/arka kamera geçişi
- Güven eşiği ayarının tahminlere etkisi
```

---

## 15. Dağıtım (Deployment)

### 15.1. Android APK Oluşturma

```bash
# EAS Build ile APK oluşturma
npx eas build --platform android --profile preview
```

### 15.2. iOS IPA Oluşturma

```bash
npx eas build --platform ios --profile preview
```

### 15.3. App Store / Play Store Yayınlama

| Platform | Gereksinimler |
|:---------|:-------------|
| Google Play | Geliştirici hesabı ($25), APK/AAB, kamera izni açıklaması |
| App Store | Apple Developer hesabı ($99/yıl), App Review süreci |

---

## Ek A: AI'ye Verilecek Prompt Şablonu

Aşağıdaki prompt'u kullanarak başka bir AI ile uygulamayı tek seferde geliştirebilirsiniz:

```
Ben bir ASL (Amerikan İşaret Dili) tanıma mobil uygulaması geliştirmek istiyorum.

PROJE DETAYLARI:
- Framework: React Native (Expo) + TypeScript
- Model: ONNX formatında hibrit ASL tanıma modeli (PyTorch'tan export edilmiş)
- Model girdileri:
  * pose_landmarks: (1, 16, 99) float32 — 33 pose landmark × 3 koordinat
  * left_hand_images: (1, 16, 3, 224, 224) float32 — Sol el RGB kırpmaları [0-1]
  * right_hand_images: (1, 16, 3, 224, 224) float32 — Sağ el RGB kırpmaları [0-1]
  * mask: (1, 16) bool — Geçerli frame mask'ı
- Model çıktısı: (1, 100) logits → softmax → sınıf olasılıkları
- 100 ASL kelimesi tanıyabilir (wlasl_class_list.txt)

YAPILACAKLAR:
1. Expo + TypeScript projesi kur
2. Kamera erişimi (react-native-vision-camera veya expo-camera)
3. MediaPipe PoseLandmarker + HandLandmarker entegrasyonu
4. El bölgesi kırpma (landmark→bbox→crop→224×224 resize)
5. 16 frame'lik sliding window buffer
6. ONNX Runtime ile model inference
7. Tahmin sonucunu ekranda gösterme
8. expo-speech ile Text-to-Speech
9. Cümle biriktirme ve güven eşiği
10. Modern, premium UI tasarımı

ÖNEMLİ TEKNİK NOTLAR:
- MediaPipe el etiketleri ters çalışır: "Left" = gerçekte sağ el
- El kırpmalarında %20 padding, kareye dönüştürme, 224×224 resize
- Pixel değerleri [0, 255] → [0, 1] float32 normalize
- HWC (Height, Width, Channel) → CHW (Channel, Height, Width) format dönüşümü
- Inference her 3 saniyede veya 16 frame buffer dolduğunda tetiklenir
```

---

## Ek B: Kritik Kontrol Listesi

Model export ve mobil entegrasyon arasındaki uyumluluk kontrolleri:

| Kontrol | Eğitim Tarafı | Mobil Tarafı | Uyumlu? |
|:--------|:-------------|:-------------|:--------|
| Pose landmark sayısı | 33 × 3 = 99 | 33 × 3 = 99 | ✅ |
| El kırpma boyutu | 224 × 224 | 224 × 224 | ✅ |
| Normalize aralığı | [0, 1] float32 | [0, 1] float32 | ✅ |
| Kanal sırası | CHW (C, H, W) | CHW (C, H, W) | ✅ |
| Frame sayısı | 16 | 16 | ✅ |
| Sınıf sayısı | 100 | 100 | ✅ |
| El etiketi çevirme | Left→Right | Left→Right | ✅ |
| MediaPipe model tipi | full | lite (öneri) | ⚠️ Kabul edilebilir |

---

> [!CAUTION]
> Bu plan, modelin eğitimi tamamlandıktan ve ONNX export yapıldıktan sonra uygulanmalıdır. Önce **Faz 0 (Model Hazırlığı)** bölümünü tamamlayın.

---

*Son güncelleme: 2026-07-24*
*Proje: Hibrit Gerçek Zamanlı ASL Tanıma Sistemi — Mobil Uygulama*

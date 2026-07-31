import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/prediction.dart';

/// ASL Model Servisi
/// Gerçek PyTorch HybridASLModel FastAPI backend servisine bağlanır ve tahmin üretir.
class ASLModelService {
  bool _isLoaded = false;
  String _baseUrl = AppConstants.apiBaseUrl;
  List<String> _classLabels = List.from(AppConstants.aslClassLabels);

  /// Devam eden HTTP isteğini iptal etmek için kullanılır
  http.Client? _activeClient;

  bool get isLoaded => _isLoaded;
  int get numClasses => _classLabels.length;
  String get baseUrl => _baseUrl;

  /// Sunucu URL'sini güncelle (ör. Fiziksel cihaz Wi-Fi IP'si için)
  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Backend servisine baglanarak modeli baslat/kontrol et
  Future<void> loadModel({
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.2);

    try {
      final healthUri = Uri.parse('$_baseUrl/health');
      final response = await http.get(healthUri).timeout(
            const Duration(seconds: 5),
          );

      onProgress?.call(0.6);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'online') {
          // Sinif isimlerini servisten cek (varsa)
          await _fetchClasses();
          _isLoaded = true;
          onProgress?.call(1.0);
          return;
        }
      }
      
      // Sunucuya baglanilamadiysa veya model henuz hazir degilse fallback durumuna gec
      _isLoaded = true;
      onProgress?.call(1.0);
    } catch (e) {
      // Çevrimdışı / Sunucu başlatılmamış durum için güvenli yükleme
      _isLoaded = true;
      onProgress?.call(1.0);
    }
  }

  /// Sunucudan dinamik sınıf listesini al
  Future<void> _fetchClasses() async {
    try {
      final uri = Uri.parse('$_baseUrl/classes');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['classes'] != null) {
          final Map<String, dynamic> classMap = Map.from(data['classes']);
          final List<String> fetchedLabels = [];
          final sortedKeys = classMap.keys.map((k) => int.parse(k)).toList()..sort();
          for (final key in sortedKeys) {
            fetchedLabels.add(classMap[key.toString()].toString());
          }
          if (fetchedLabels.isNotEmpty) {
            _classLabels = fetchedLabels;
          }
        }
      }
    } catch (_) {
      // Varsayılan sınıf listesini koru
    }
  }

  /// Devam eden HTTP isteğini iptal et
  void cancelPendingRequest() {
    try {
      _activeClient?.close();
    } catch (_) {}
    _activeClient = null;
  }

  /// Gerçek API tahmini üret
  /// Backend servisine video baytlarını veya dosyasını göndererek PyTorch model sonucunu alır.
  Future<PredictionResult> predict({
    List<int>? videoBytes,
    String? videoPath,
  }) async {
    if (!_isLoaded) {
      throw StateError('Model henüz yüklenmedi');
    }

    final startTime = DateTime.now().millisecondsSinceEpoch;

    // Her istek için yeni bir client oluştur (iptal edilebilir)
    _activeClient = http.Client();

    try {
      final predictUri = Uri.parse('$_baseUrl/predict');
      final request = http.MultipartRequest('POST', predictUri);

      if (videoPath != null && await File(videoPath).exists()) {
        final file = File(videoPath);
        final fileSize = await file.length();
        debugPrint('[ASL] 📁 Video dosyası bulundu: $videoPath ($fileSize bytes)');
        request.files.add(await http.MultipartFile.fromPath('file', videoPath));
      } else if (videoBytes != null && videoBytes.isNotEmpty) {
        debugPrint('[ASL] 📦 Video baytları gönderiliyor: ${videoBytes.length} bytes');
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            videoBytes,
            filename: 'input_video.mp4',
          ),
        );
      } else {
        debugPrint('[ASL] ❌ Video verisi bulunamadı! videoPath=$videoPath');
        throw StateError('Video verisi bulunamadı — kameradan kayıt alınamadı.');
      }

      debugPrint('[ASL] 🚀 Sunucuya gönderiliyor: $_baseUrl/predict');
      final streamedResponse = await _activeClient!.send(request).timeout(
            const Duration(seconds: 30),
          );

      debugPrint('[ASL] 📨 Sunucu yanıtı: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        final List<dynamic> predsJson = jsonResponse['predictions'] ?? [];
        final int serverTimeMs = jsonResponse['inferenceTimeMs'] ?? 0;

        debugPrint('[ASL] ✅ Tahmin başarılı! ${predsJson.length} sonuç, ${serverTimeMs}ms');
        if (predsJson.isNotEmpty) {
          debugPrint('[ASL] 🏆 Top: ${predsJson[0]['label']} (${(predsJson[0]['confidence'] * 100).toStringAsFixed(1)}%)');
        }

        final predictions = predsJson.map((item) {
          String rawLabel = item['label'] ?? 'unknown';
          
          // Etiketi temizle: Rakamları ve alt çizgileri kaldır
          String cleanedLabel = rawLabel.replaceAll(RegExp(r'\d+'), '').replaceAll('_', ' ').trim();
          
          // İlk harfi büyük, diğerlerini küçük yap (Örn: DOG -> Dog)
          if (cleanedLabel.isNotEmpty) {
            cleanedLabel = cleanedLabel[0].toUpperCase() + cleanedLabel.substring(1).toLowerCase();
          } else {
            cleanedLabel = rawLabel;
          }

          return Prediction(
            label: cleanedLabel,
            confidence: (item['confidence'] as num).toDouble(),
            classIndex: item['classIndex'] ?? 0,
            timestamp: DateTime.now(),
          );
        }).toList();

        return PredictionResult(
          predictions: predictions,
          inferenceTimeMs: serverTimeMs > 0
              ? serverTimeMs
              : (DateTime.now().millisecondsSinceEpoch - startTime),
        );
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        String detailMessage = errorBody;
        try {
          final parsed = json.decode(errorBody);
          if (parsed['detail'] != null) {
            detailMessage = parsed['detail'].toString();
          }
        } catch (_) {}
        debugPrint('[ASL] ❌ Sunucu hata kodu: ${streamedResponse.statusCode}');
        debugPrint('[ASL] ❌ Hata detayı: $detailMessage');
        throw HttpException(
          'Sunucu Hatası [HTTP ${streamedResponse.statusCode}]: $detailMessage',
        );
      }
    } catch (e) {
      debugPrint('[ASL] 🔥 predict() Exception: $e');
      if (e is SocketException) {
        throw HttpException(
          'Sunucuya bağlanılamadı! Lütfen sunucunun ($_baseUrl) açık olduğundan emin olun.',
        );
      }
      rethrow;
    } finally {
      _activeClient = null;
    }
  }

  /// Sınıf etiketini getir
  String getClassLabel(int index) {
    if (index < 0 || index >= _classLabels.length) return 'unknown';
    return _classLabels[index];
  }

  /// Modeli kapat
  void dispose() {
    cancelPendingRequest();
    _isLoaded = false;
  }
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import '../config/colors.dart';
import '../config/constants.dart';

/// Önbellek destekli yeniden kullanılabilir video oynatıcı
class CachedVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;
  final double borderRadius;
  final BoxFit fit;
  final VoidCallback? onVideoFinished;
  final double playbackSpeed;

  const CachedVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.loop = true,
    this.borderRadius = 20.0,
    this.fit = BoxFit.cover,
    this.onVideoFinished,
    this.playbackSpeed = 1.0,
  });

  @override
  State<CachedVideoPlayerWidget> createState() => _CachedVideoPlayerWidgetState();
}

class _CachedVideoPlayerWidgetState extends State<CachedVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _videoEnded = false;

  void _videoListener() {
    if (_controller == null || !mounted) return;
    
    if (_controller!.value.isInitialized) {
      // Eğer video bittiyse (position >= duration)
      if (_controller!.value.position >= _controller!.value.duration && _controller!.value.duration > Duration.zero) {
        if (!_videoEnded) {
          _videoEnded = true;
          widget.onVideoFinished?.call();
        }
      } else if (_controller!.value.position < _controller!.value.duration) {
        // Video baştan başlarsa veya geri sarılırsa bayrağı sıfırla
        _videoEnded = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant CachedVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _initializeVideo();
    } else if (oldWidget.playbackSpeed != widget.playbackSpeed) {
      _controller?.setPlaybackSpeed(widget.playbackSpeed);
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }

      debugPrint('Orijinal Video URL: ${widget.videoUrl}');
      
      // Veritabanındaki eski r2 linkini proxy linkiyle dinamik olarak değiştiriyoruz
      final finalUrl = widget.videoUrl.replaceFirst(
        AppConstants.cloudflareOldR2Url,
        AppConstants.cloudflareWorkerProxyUrl,
      );
      
      debugPrint('Proxy Üzerinden Oynatılıyor: $finalUrl');
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(finalUrl),
        httpHeaders: {'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Mobile Safari/537.36'},
      );
      
      _controller!.addListener(_videoListener);
      await _controller!.initialize();

      if (widget.loop) {
        await _controller!.setLooping(true);
      }

      if (widget.autoPlay) {
        await _controller!.play();
      }

      // Oynatma hızını ayarla
      if (widget.playbackSpeed != 1.0) {
        await _controller!.setPlaybackSpeed(widget.playbackSpeed);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Video yüklenemedi: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null || _controller == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
              const SizedBox(height: 8),
              Text(
                'Hata: Video bulunamadı',
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
            // Opsiyonel oynat/duraklat butonu
            if (!widget.autoPlay)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

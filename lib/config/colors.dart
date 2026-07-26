import 'dart:ui';

/// Premium renk paleti - ASL Translator App
class AppColors {
  AppColors._();

  // Ana renkler - Mor/Mavi gradient ağırlıklı
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color accent = Color(0xFF06B6D4);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentTeal = Color(0xFF14B8A6);

  // Gradient tanımları
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF6366F1),
    Color(0xFF3B82F6),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  // Dark tema renkleri
  static const Color darkBg = Color(0xFF0F0F23);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkCardLight = Color(0xFF1E2A4A);
  static const Color darkBorder = Color(0xFF2A2A4A);
  static const Color darkText = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light tema renkleri
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Durum renkleri
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Güven seviyesi renkleri
  static Color confidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF10B981);
    if (confidence >= 0.6) return const Color(0xFF3B82F6);
    if (confidence >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // Glassmorphism renkleri
  static Color glassWhite = const Color(0x1AFFFFFF);
  static Color glassBorder = const Color(0x33FFFFFF);
  static Color glassShadow = const Color(0x1A000000);
}

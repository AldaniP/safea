import 'package:flutter/material.dart';

/// Palet warna utama aplikasi Safea.
///
/// Gradasi biru lembut → krem hangat yang premium & calming,
/// dirancang untuk mendukung suasana tenang dan rasa aman.
class AppColors {
  AppColors._();

  // ─── Primary Blues ────────────────────────────────────────
  /// Biru langit lembut — latar glass card, aksen ringan
  static const Color softBlue = Color(0xFFA8D4F0);

  /// Biru tenang dalam — primary brand color
  static const Color deepCalmBlue = Color(0xFF5B9BD5);

  /// Biru gelap untuk teks & elemen penting
  static const Color navyCalm = Color(0xFF2C5282);

  // ─── Warm Neutrals ───────────────────────────────────────
  /// Krem hangat — scaffold background (light)
  static const Color warmCream = Color(0xFFFFF8F0);

  /// Gading lembut — card surface
  static const Color softIvory = Color(0xFFFAF3E8);

  /// Krem gelap — subtle borders
  static const Color mutedCream = Color(0xFFE8DDD0);

  // ─── Accents ─────────────────────────────────────────────
  /// Emas aksen — tombol, highlight
  static const Color accentGold = Color(0xFFD4A574);

  /// Lavender lembut — fase tahan napas
  static const Color softLavender = Color(0xFFB8A9D4);

  /// Hijau muda — sukses, ketenangan tercapai
  static const Color calmGreen = Color(0xFF8BC6A8);

  // ─── Text ────────────────────────────────────────────────
  /// Teks gelap utama
  static const Color textDark = Color(0xFF2C3E50);

  /// Teks sekunder
  static const Color textMuted = Color(0xFF7F8C9B);

  /// Teks di atas warna gelap
  static const Color textLight = Color(0xFFF5F5F5);

  // ─── Dark Mode ───────────────────────────────────────────
  /// Latar gelap utama
  static const Color darkSurface = Color(0xFF1A2332);

  /// Card gelap
  static const Color darkCard = Color(0xFF243447);

  /// Biru gelap aksen
  static const Color darkBlueAccent = Color(0xFF4A8BC2);

  // ─── Gradients ───────────────────────────────────────────
  /// Gradasi latar utama (light mode)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softBlue, Color(0xFFD4E8F7), warmCream],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gradasi latar (dark mode)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A2942), darkSurface, Color(0xFF1E2A3A)],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Breathing Phases ────────────────────────────────────
  /// Warna per fase pernapasan
  static const Color breatheInColor = deepCalmBlue;
  static const Color holdColor = accentGold;
  static const Color breatheOutColor = softIvory;
  static const Color holdAfterColor = softLavender;
}

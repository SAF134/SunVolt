import 'package:flutter/material.dart';

/// SunVolt Design System Color Tokens
/// 5 Warna Dasar: Kuning (#FFD700), Hijau (#3A7100), Putih, Hitam (#191C1D), Merah (#D32F2F)
class AppColors {
  AppColors._();

  // ── Primary (Sun Yellow - "Action Energy") ──
  static const Color primary = Color(0xFFFFD700);
  static const Color onPrimary = Color(0xFF191C1D);
  static const Color primaryContainer = Color(0xFFFFD700);
  static const Color onPrimaryContainer = Color(0xFF544600);
  static const Color primaryFixed = Color(0xFFFFE16D);
  static const Color primaryFixedDim = Color(0xFFE9C400);
  static const Color onPrimaryFixed = Color(0xFF221B00);
  static const Color onPrimaryFixedVariant = Color(0xFF544600);
  static const Color inversePrimary = Color(0xFFE9C400);

  // ── Primary Variants (derived from #FFD700) ──
  static const Color yellowSoft = Color(0xFFFFF8E1);      // bg lembut kuning
  static const Color yellowLight = Color(0xFFFFEA70);      // kuning terang
  static const Color yellowDark = Color(0xFFCCAC00);       // kuning gelap
  static const Color yellowAccent = Color(0xFFEAB308);     // aksen kuning kuat

  // ── Secondary (Nature Green - "Sustainable Flow") ──
  static const Color secondary = Color(0xFF3A7100);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB6F29C);
  static const Color onSecondaryContainer = Color(0xFF2D5900);
  static const Color secondaryFixed = Color(0xFFC2F5AA);
  static const Color secondaryFixedDim = Color(0xFF8CD676);
  static const Color onSecondaryFixed = Color(0xFF0F2000);
  static const Color onSecondaryFixedVariant = Color(0xFF2D5900);

  // ── Secondary Variants (derived from #3A7100) ──
  static const Color greenSoft = Color(0xFFF0F9EB);       // bg lembut hijau
  static const Color greenLight = Color(0xFF6BAF3D);       // hijau terang
  static const Color greenDark = Color(0xFF245200);        // hijau gelap

  // ── Error (Merah) ──
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFE0E0);
  static const Color onErrorContainer = Color(0xFF8B0000);

  // ── Error Variants ──
  static const Color redSoft = Color(0xFFFFF0F0);         // bg lembut merah
  static const Color redLight = Color(0xFFEF5350);         // merah terang
  static const Color redDark = Color(0xFFC62828);          // merah gelap

  // ── Surface & Background ──
  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color surfaceVariant = Color(0xFFE1E3E4);
  static const Color onSurfaceVariant = Color(0xFF4D4732);
  static const Color surfaceBright = Color(0xFFF8F9FA);
  static const Color surfaceDim = Color(0xFFD9DADB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color surfaceTint = Color(0xFFFFD700);

  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);

  // ── Outline ──
  static const Color outline = Color(0xFF7E775F);
  static const Color outlineVariant = Color(0xFFD0C6AB);

  // ── Inverse ──
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F2);

  // ── Text Hierarchy (derived from black #191C1D) ──
  static const Color textPrimary = Color(0xFF191C1D);
  static const Color textSecondary = Color(0xFF5A5D5E);
  static const Color textTertiary = Color(0xFF8A8D8F);
  static const Color textDisabled = Color(0xFFBDBFC0);

  // ── Semantic Aliases ──
  static const Color sunYellow = primary;
  static const Color natureGreen = secondary;
}

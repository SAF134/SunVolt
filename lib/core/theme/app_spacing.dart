import 'package:flutter/material.dart';

/// SunVolt Design System - Spacing Tokens
/// Standar jarak konsisten untuk seluruh aplikasi
class AppSpacing {
  AppSpacing._();

  // ── Base Scale ──
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ── Screen-level Padding ──
  static const double screenH = 24.0;
  static const double screenV = 16.0;

  // ── Component Padding ──
  static const double cardPadding = 20.0;
  static const double buttonH = 24.0;
  static const double buttonV = 16.0;

  // ── Border Radius ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // ── Convenience EdgeInsets ──
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenH,
    vertical: screenV,
  );

  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: screenH,
  );

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);

  static const EdgeInsets buttonInsets = EdgeInsets.symmetric(
    horizontal: buttonH,
    vertical: buttonV,
  );
}

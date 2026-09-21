import 'package:flutter/material.dart';

// Backwards compatibility for existing color integer reference
var color = 0xff1E3A8A; // Deep modern Navy / Royal Blue

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xff1E3A8A);       // Deep Royal Blue
  static const Color primaryLight = Color(0xff3B82F6);  // Electric Blue
  static const Color emergencyRed = Color(0xffEF4444);  // High-visibility Emergency Red
  static const Color emergencyDark = Color(0xffDC2626);
  static const Color emergencyRedLight = Color(0xffFEE2E2);

  // Backgrounds & Surfaces
  static const Color background = Color(0xffF8FAFC);     // Clean Slate 50
  static const Color cardSurface = Colors.white;
  static const Color textDark = Color(0xff0F172A);       // Slate 900
  static const Color textMuted = Color(0xff64748B);      // Slate 500
  static const Color borderLight = Color(0xffE2E8F0);    // Slate 200

  // Service Specific Accent Gradients
  static const LinearGradient policeGradient = LinearGradient(
    colors: [Color(0xff1D4ED8), Color(0xff1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xffF97316), Color(0xffDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ambulanceGradient = LinearGradient(
    colors: [Color(0xff059669), Color(0xff047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hospitalGradient = LinearGradient(
    colors: [Color(0xff0284C7), Color(0xff0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sosGradient = LinearGradient(
    colors: [Color(0xffEF4444), Color(0xffB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xff1E293B), Color(0xff0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Box Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> glowShadow(Color glowColor) => [
    BoxShadow(
      color: glowColor.withValues(alpha: 0.35),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
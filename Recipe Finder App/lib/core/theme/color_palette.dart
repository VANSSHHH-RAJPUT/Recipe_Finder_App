import 'package:flutter/material.dart';

class AppColors {
  static const Color accentWarm = Color(0xFFF3A712);
  static const Color accentFresh = Color(0xFF7ED957);

  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1C1C1C);
  static const Color lightTextSecondary = Color(0xFF6E6E6E);

  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0x33FFFFFF);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);

  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);
}

class AppGradients {
  static const Gradient lightBackground = LinearGradient(
    colors: [
      Color(0xFFFDFCFB),
      Color(0xFFE2EBF0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkBackground = LinearGradient(
    colors: [
      Color(0xFF1B1F2A),
      Color(0xFF0B0C10),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const Gradient accent = LinearGradient(
    colors: [
      AppColors.accentWarm,
      AppColors.accentFresh,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

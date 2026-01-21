import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _theme(brightness: Brightness.light);

  static ThemeData dark() => _theme(brightness: Brightness.dark);

  static ThemeData _theme({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    final textColor = isLight
        ? AppColors.lightTextPrimary
        : AppColors.darkTextPrimary;

    final textTheme = baseTextTheme.copyWith(
      displayLarge: _scaled(baseTextTheme.displayLarge, textColor),
      displayMedium: _scaled(baseTextTheme.displayMedium, textColor),
      displaySmall: _scaled(baseTextTheme.displaySmall, textColor),
      headlineLarge: _scaled(baseTextTheme.headlineLarge, textColor),
      headlineMedium: _scaled(baseTextTheme.headlineMedium, textColor),
      headlineSmall: _scaled(baseTextTheme.headlineSmall, textColor),
      titleLarge: _scaled(
        baseTextTheme.titleLarge,
        textColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: _scaled(
        baseTextTheme.titleMedium,
        textColor,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: _scaled(baseTextTheme.titleSmall, textColor),
      labelLarge: _scaled(baseTextTheme.labelLarge, textColor),
      labelMedium: _scaled(baseTextTheme.labelMedium, textColor),
      labelSmall: _scaled(baseTextTheme.labelSmall, textColor),
      bodyLarge: _scaled(baseTextTheme.bodyLarge, textColor, height: 1.4),
      bodyMedium: _scaled(baseTextTheme.bodyMedium, textColor, height: 1.4),
      bodySmall: _scaled(
        baseTextTheme.bodySmall,
        textColor.withValues(alpha: 0.8),
        height: 1.4,
      ),
    );

    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentWarm,
      brightness: brightness,
    );

    final colorScheme = baseScheme.copyWith(
      primary: AppColors.accentWarm,
      onPrimary: Colors.white,
      secondary: AppColors.accentFresh,
      onSecondary: Colors.white,
      error: const Color(0xFFFF5F6D),
      onError: Colors.white,
      surface: isLight ? AppColors.lightBackground : AppColors.darkBackground,
      onSurface: textColor,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: IconThemeData(color: textColor),
      dividerColor: textColor.withValues(alpha: 0.1),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  static const double _textScaleFactor = 0.92;

  static TextStyle? _scaled(
    TextStyle? style,
    Color? color, {
    FontWeight? fontWeight,
    double? height,
  }) {
    if (style == null) return null;
    final scaledFontSize = style.fontSize != null
        ? style.fontSize! * _textScaleFactor
        : null;
    return style.copyWith(
      fontSize: scaledFontSize,
      color: color ?? style.color,
      fontWeight: fontWeight ?? style.fontWeight,
      height: height ?? style.height,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodie/theme/theme.dart';

TextTheme buildTextTheme(ColorScheme cs) {
  return TextTheme(
    displayLarge: GoogleFonts.sansitaSwashed(
      fontSize: 56,
      fontWeight: FontWeight.w600,
      color: MaterialTheme.brandColor, // use [cs.primary] for dynamic color
    ),
    displayMedium: GoogleFonts.signika(
      fontSize: 45,
      fontWeight: FontWeight.w600,
      color: cs.primary,
    ),
    displaySmall: GoogleFonts.signika(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      color: cs.primary,
    ),

    // 小一點的標題／段落標題
    headlineLarge: GoogleFonts.signika(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    headlineMedium: GoogleFonts.signika(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    headlineSmall: GoogleFonts.signika(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),

    // 卡片標題、彈窗標題
    titleLarge: GoogleFonts.signika(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: cs.onSurface,
    ),
    titleMedium: GoogleFonts.signika(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: cs.onSurfaceVariant,
    ),
    titleSmall: GoogleFonts.signika(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: cs.onSurfaceVariant,
    ),

    // 正文
    bodyLarge: GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: cs.onSurface,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: cs.onSurface,
    ),
    bodySmall: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: cs.onSurfaceVariant,
    ),

    // 標籤、按鈕文字
    labelLarge: GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: cs.secondary,
    ),
    labelMedium: GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: cs.secondaryContainer,
    ),
    labelSmall: GoogleFonts.lato(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: cs.secondaryContainer,
    ),
  );
}

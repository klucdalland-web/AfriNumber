import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Styles typographiques des maquettes.
///
/// - Titres : serif (Newsreader) — logo, titres d'écran, titres de section.
/// - Corps : sans-serif (Instrument Sans).
///
/// Pour changer de police, il suffit de modifier [_serif] / [_sans].
abstract final class AppTypography {
  static TextStyle _serif({
    required double size,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.newsreader(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle _sans({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.instrumentSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // ── Serif ────────────────────────────────────────────────────────────────
  static TextStyle get logo =>
      _serif(size: 24, height: 1.1, letterSpacing: -0.3);
  static TextStyle get screenTitle =>
      _serif(size: 22, height: 1.1, letterSpacing: -0.2);
  static TextStyle get sectionTitle =>
      _serif(size: 18, height: 1.2, letterSpacing: -0.1);
  static TextStyle get groupTitle =>
      _serif(size: 15, height: 1.2, letterSpacing: -0.1);
  static TextStyle get cardCurrency =>
      _serif(size: 17, weight: FontWeight.w600, color: Colors.white, height: 1.2);

  // ── Sans ─────────────────────────────────────────────────────────────────
  static TextStyle get subtitle =>
      _sans(size: 12, color: AppColors.textSecondary, height: 1.2);
  static TextStyle get sectionCaption =>
      _sans(size: 13, color: AppColors.textSecondary, height: 1.35);
  static TextStyle get chip =>
      _sans(size: 12, weight: FontWeight.w500, height: 1.2);
  static TextStyle get badge => _sans(
      size: 12, weight: FontWeight.w600, color: AppColors.mintDark, height: 1.2);
  static TextStyle get link => _sans(
      size: 13, weight: FontWeight.w700, color: AppColors.ink, height: 1.2);
  static TextStyle get actionLabel => _sans(
      size: 14, weight: FontWeight.w600, color: AppColors.ink, height: 1.25);

  static TextStyle get inboxTitle => _sans(
      size: 14, weight: FontWeight.w600, color: AppColors.textPrimary, height: 1.25);
  static TextStyle get inboxPreview =>
      _sans(size: 13, color: AppColors.textSecondary, height: 1.25);
  static TextStyle get inboxTime =>
      _sans(size: 12, color: AppColors.textSecondary, height: 1.25);
  static TextStyle get searchHint =>
      _sans(size: 14, color: AppColors.textSecondary, height: 1.2);
  static TextStyle get searchInput =>
      _sans(size: 14, color: AppColors.textPrimary, height: 1.2);

  static TextStyle get cardLabel => _sans(
      size: 12, color: Colors.white.withValues(alpha: 0.6), height: 1.2);
  static TextStyle get cardBalance => _sans(
      size: 22,
      weight: FontWeight.w700,
      color: Colors.white,
      height: 1.15,
      letterSpacing: -0.3);
  static TextStyle get cardValue =>
      _sans(size: 14, weight: FontWeight.w700, color: Colors.white, height: 1.2);

  static TextStyle get navActiveLabel => _sans(
      size: 12, weight: FontWeight.w600, color: AppColors.ink, height: 1.2);
  static TextStyle get depositTitle => _sans(
      size: 14, weight: FontWeight.w600, color: AppColors.textPrimary, height: 1.25);
  static TextStyle get depositAmount => _sans(
      size: 14, weight: FontWeight.w700, color: AppColors.ink, height: 1.25);
}

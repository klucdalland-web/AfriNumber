import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Seed & typography ──
  static const Color _seed = Color(0xFF0D7377);
  static const String _serifFont = 'Georgia';

  // ── Couleurs extraites de la maquette ──
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF09090B);
  static const Color _onSurface = Color(0xFF030303);
  static const Color _onSurfaceDark = Color(0xFFF3F3F3);
  static const Color _surfaceVariant = Color(0xFFF0F0F0);
  static const Color _surfaceVariantDark = Color(0xFF484C52);
  static const Color _onSurfaceVariant = Color(0xFF484C52);
  static const Color _onSurfaceVariantDark = Color(0xFFACACB1);
  static const Color _outline = Color(0xFF8C9599);
  static const Color _outlineVariant = Color(0xFFACACB1);
  static const Color _secondaryText = Color(0xFF505050);
  static const Color _subtleBg = Color(0xFFF3F3F3);
  static const Color _accentGreen = Color(0xFFBEDFBF);
  static const Color _error = Color(0xFFEF4444);
  static const Color _teal = Color(0xFF0C8F8F);

  // ── Thèmes ──
  static ThemeData get light => _material(Brightness.light);
  static ThemeData get dark => _material(Brightness.dark);

  static ThemeData _material(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(
      // Primary : votre teal
      primary: _seed,
      onPrimary: Colors.white,

      // Secondary : gris foncé de la maquette
      secondary: _teal,
      onSecondary: Colors.white,

      // Tertiary : accent vert clair
      tertiary: _accentGreen,
      onTertiary: _onSurface,

      // Surface
      surface: isLight ? _surface : _surfaceDark,
      onSurface: isLight ? _onSurface : _onSurfaceDark,

      // Surface variant (fonds subtils)
      surfaceContainerHighest: isLight ? _surfaceVariant : _surfaceVariantDark,
      onSurfaceVariant: isLight ? _onSurfaceVariant : _onSurfaceVariantDark,

      // Outline / bordures
      outline: _outline,
      outlineVariant: isLight ? _outlineVariant : const Color(0xFF595961),

      // Erreur
      error: _error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: _serifFont,

      // ── Scaffold ──
      scaffoldBackgroundColor: isLight ? _surface : _surfaceDark,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isLight ? _surface : _surfaceDark,
        foregroundColor: isLight ? _onSurface : _onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        color: isLight ? _surface : const Color(0xFF1A1A1C),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight
                ? _outlineVariant.withValues(alpha: 0.5)
                : const Color(0xFF2A2A2E),
          ),
        ),
      ),

      // ── Dividers ──
      dividerTheme: DividerThemeData(
        color: isLight ? _surfaceVariant : const Color(0xFF2A2A2E),
        thickness: 1,
      ),

      // ── Input fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? _subtleBg : const Color(0xFF1A1A1C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _seed, width: 2),
        ),
        hintStyle: TextStyle(color: _outline),
      ),

      // ── Elevated Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: _seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // ── Outlined Buttons ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: isLight ? _onSurface : _onSurfaceDark,
          side: BorderSide(color: _outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // ── Text Buttons ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),

      // ── Text theme ──
      textTheme: TextTheme(
        // Titres
        displaySmall: TextStyle(
          fontFamily: _serifFont,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: isLight ? _onSurface : _onSurfaceDark,
        ),
        headlineLarge: TextStyle(
          fontFamily: _serifFont,
          color: isLight ? _onSurface : _onSurfaceDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: _serifFont,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isLight ? _onSurface : _onSurfaceDark,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontFamily: _serifFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: isLight ? _onSurface : _onSurfaceDark,
        ),
        // Corps
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isLight ? _onSurface : _onSurfaceDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isLight ? _onSurface : _onSurfaceDark,
        ),
        bodySmall: TextStyle(
          color: isLight ? _secondaryText : _outline,
        ),
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isLight ? _onSurface : _onSurfaceDark,
        ),
        labelSmall: TextStyle(
          color: _outline,
        ),
      ),

      // Permet aux widgets Cupertino d'hériter des couleurs Material.
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: colorScheme.primary,
        scaffoldBackgroundColor: isLight ? _surface : _surfaceDark,
        barBackgroundColor:
            (isLight ? _surface : _surfaceDark).withValues(alpha: 0.9),
      ),
    );
  }
}

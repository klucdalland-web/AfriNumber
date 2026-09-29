import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';


abstract class AppTextStyles {
  static TextStyle screenTitle(double size) => GoogleFonts.zillaSlab(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.15,
      );

  static TextStyle sectionTitle(double size) => GoogleFonts.zillaSlab(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textSecondary,
    double? height,
  }) =>
      GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}

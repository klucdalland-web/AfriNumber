import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  static TextStyle screenTitle(double size) => GoogleFonts.zillaSlab(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.15,
      );

  static TextStyle sectionTitle(double size) => GoogleFonts.zillaSlab(
        fontSize: size,
        fontWeight: FontWeight.w700,
      );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}

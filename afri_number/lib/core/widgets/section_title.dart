import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../responsive/responsive.dart';

/// Titre de section (« Mes services actifs », « Aujourd'hui »…).
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Padding(
      padding: EdgeInsets.only(bottom: r.space(14)),
      child: Text(text, style: AppTextStyles.sectionTitle(r.fontSize(20))),
    );
  }
}

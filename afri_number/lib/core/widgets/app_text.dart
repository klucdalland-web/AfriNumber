import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

enum AppTextVariant {
  display,
  headline,
  title,
  body,
  bodyLarge,
  caption,
  label,
}

/// Texte typographique unifié (Material TextTheme / CupertinoTextTheme).
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.variant = AppTextVariant.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  const AppText.display(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.display;

  const AppText.headline(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.headline;

  const AppText.title(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.title;

  const AppText.body(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.body;

  const AppText.bodyLarge(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.bodyLarge;

  const AppText.caption(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.caption;

  const AppText.label(
    this.data, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  }) : variant = AppTextVariant.label;

  final String data;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context).copyWith(
      color: color ?? _defaultColor(context),
      fontWeight: fontWeight,
    );

    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  Color? _defaultColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  TextStyle _resolveStyle(BuildContext context) {
    // Toujours partir du TextTheme Material (cohérent sur toutes plateformes).
    final material = Theme.of(context).textTheme;

    if (isApplePlatform) {
      final cupertino = CupertinoTheme.of(context).textTheme;
      switch (variant) {
        case AppTextVariant.display:
          return cupertino.navLargeTitleTextStyle;
        case AppTextVariant.headline:
          return material.headlineMedium ??
              cupertino.navTitleTextStyle.copyWith(fontSize: 22);
        case AppTextVariant.title:
          return material.titleLarge ??
              cupertino.textStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              );
        case AppTextVariant.bodyLarge:
          return material.bodyLarge ??
              cupertino.textStyle.copyWith(fontSize: 17);
        case AppTextVariant.body:
          return material.bodyMedium ?? cupertino.textStyle;
        case AppTextVariant.caption:
          return material.bodySmall ?? cupertino.tabLabelTextStyle;
        case AppTextVariant.label:
          return material.labelLarge ?? cupertino.actionTextStyle;
      }
    }

    switch (variant) {
      case AppTextVariant.display:
        return material.displaySmall ?? const TextStyle(fontSize: 36);
      case AppTextVariant.headline:
        return material.headlineMedium ?? const TextStyle(fontSize: 24);
      case AppTextVariant.title:
        return material.titleLarge ?? const TextStyle(fontSize: 18);
      case AppTextVariant.bodyLarge:
        return material.bodyLarge ?? const TextStyle(fontSize: 16);
      case AppTextVariant.body:
        return material.bodyMedium ?? const TextStyle(fontSize: 14);
      case AppTextVariant.caption:
        return material.bodySmall ?? const TextStyle(fontSize: 12);
      case AppTextVariant.label:
        return material.labelLarge ?? const TextStyle(fontSize: 14);
    }
  }
}

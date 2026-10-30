import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

enum AppButtonVariant { primary, outlined, text }

/// Bouton adaptatif :
/// - iOS/macOS → CupertinoButton
/// - Android / autres → Elevated / Outlined / TextButton (Material 3)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.height,
    this.underline = false,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.height,
  })  : variant = AppButtonVariant.primary,
        underline = false;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
    this.foregroundColor,
    this.radius,
    this.height,
  })  : variant = AppButtonVariant.outlined,
        backgroundColor = null,
        underline = false;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expanded = false,
    this.icon,
    this.foregroundColor,
    this.underline = false,
  })  : variant = AppButtonVariant.text,
        backgroundColor = null,
        radius = null,
        height = null;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expanded;
  final IconData? icon;

  /// Style overrides — optional. When omitted, the button falls back to the
  /// app-wide theme (see [AppTheme]), so existing call sites are unaffected.
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? radius;
  final double? height;

  /// Underlines the label — for link-style text buttons (e.g. "Mot de passe
  /// oublié"). Only applies to [AppButtonVariant.text].
  final bool underline;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading ? _loader(context) : _labelChild(context);

    final button = isApplePlatform
        ? _buildCupertino(context, child)
        : _buildMaterial(context, child);

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _loader(BuildContext context) {
    final color = foregroundColor ?? Theme.of(context).colorScheme.onPrimary;
    return SizedBox(
      height: 20,
      width: 20,
      child: isApplePlatform
          ? const CupertinoActivityIndicator()
          : CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? color
                  : (foregroundColor ?? Theme.of(context).colorScheme.primary),
            ),
    );
  }

  Widget _labelChild(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildCupertino(BuildContext context, Widget child) {
    final primary = foregroundColor ?? Theme.of(context).colorScheme.primary;

    switch (variant) {
      case AppButtonVariant.primary:
        return CupertinoButton.filled(
          onPressed: _enabled ? onPressed : null,
          color: backgroundColor,
          borderRadius: radius != null ? BorderRadius.circular(radius!) : null,
          child: child,
        );
      case AppButtonVariant.outlined:
        return CupertinoButton(
          onPressed: _enabled ? onPressed : null,
          padding: EdgeInsets.zero,
          child: Container(
            width: expanded ? double.infinity : null,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: primary),
              borderRadius: BorderRadius.circular(radius ?? 8),
            ),
            child: DefaultTextStyle(
              style: TextStyle(color: primary, fontSize: 17),
              child: IconTheme(
                data: IconThemeData(color: primary, size: 20),
                child: child,
              ),
            ),
          ),
        );
      case AppButtonVariant.text:
        return CupertinoButton(
          onPressed: _enabled ? onPressed : null,
          child: child,
        );
    }
  }

  ButtonStyle? _overrideStyle({Color? side}) {
    final hasOverride = backgroundColor != null ||
        foregroundColor != null ||
        radius != null ||
        height != null ||
        underline;
    if (!hasOverride) return null;

    return ButtonStyle(
      backgroundColor:
          backgroundColor != null ? WidgetStatePropertyAll(backgroundColor) : null,
      foregroundColor:
          foregroundColor != null ? WidgetStatePropertyAll(foregroundColor) : null,
      side: side != null ? WidgetStatePropertyAll(BorderSide(color: side)) : null,
      shape: radius != null
          ? WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius!)),
            )
          : null,
      minimumSize: height != null
          ? WidgetStatePropertyAll(Size(expanded ? double.infinity : 0, height!))
          : null,
      textStyle: underline
          ? const WidgetStatePropertyAll(TextStyle(decoration: TextDecoration.underline))
          : null,
    );
  }

  Widget _buildMaterial(BuildContext context, Widget child) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: _overrideStyle(),
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: _overrideStyle(side: foregroundColor),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: _enabled ? onPressed : null,
          style: _overrideStyle(),
          child: child,
        );
    }
  }
}

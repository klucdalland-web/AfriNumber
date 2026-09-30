import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../responsive/responsive.dart';

/// Champ de saisie réutilisable, adaptatif et thématique (pill shape avec bordure propre).
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.isPassword = false,
    this.isRequired = false,
    this.showLabel = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.autofillHints,
  });

  final String hintText;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  final bool isPassword;
  final bool isRequired;
  final bool showLabel;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fieldBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final hintColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final defaultBorderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final activeBorderColor = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding: EdgeInsets.only(left: r.space(12), bottom: r.space(6)),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.hintText.replaceAll('*', '').trim(),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(13),
                      fontWeight: FontWeight.w500,
                      color: hintColor,
                    ),
                  ),
                  if (widget.isRequired)
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                ],
              ),
            ),
          ),
        FormField<String>(
          validator: widget.validator,
          initialValue: widget.controller?.text,
          builder: (FormFieldState<String> fieldState) {
            final hasError = fieldState.hasError;
            final borderColor = hasError
                ? const Color(0xFFEF4444)
                : (_isFocused ? activeBorderColor : defaultBorderColor);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(r.radius(28)),
                    border: Border.all(
                      color: borderColor,
                      width: (_isFocused || hasError) ? 1.5 : 1.0,
                    ),
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: _obscureText,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: (val) {
                      fieldState.didChange(val);
                      if (widget.onChanged != null) widget.onChanged!(val);
                    },
                    onFieldSubmitted: widget.onSubmitted,
                    autofillHints: widget.autofillHints,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: r.fontSize(15),
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText.replaceAll('*', '').trim(),
                      hintStyle: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(15),
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                      ),
                      prefixIcon: widget.icon != null
                          ? Padding(
                              padding: EdgeInsets.only(
                                left: r.space(16),
                                right: r.space(10),
                              ),
                              child: Icon(
                                widget.icon,
                                size: r.iconSize(20),
                                color: _isFocused ? activeBorderColor : hintColor,
                              ),
                            )
                          : null,
                      suffixIcon: _buildSuffixIcon(r, textColor, hintColor),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: r.space(14),
                        horizontal: widget.icon == null ? r.space(20) : r.space(12),
                      ),
                      filled: false,
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: EdgeInsets.only(
                      left: r.space(16),
                      top: r.space(6),
                    ),
                    child: Text(
                      fieldState.errorText ?? '',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: r.fontSize(12),
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(Responsive r, Color textColor, Color hintColor) {
    if (widget.isPassword) {
      return IconButton(
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: r.iconSize(20),
          color: hintColor,
        ),
        padding: EdgeInsets.only(right: r.space(16)),
      );
    }
    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconTap,
        icon: Icon(widget.suffixIcon, size: r.iconSize(20), color: hintColor),
        padding: EdgeInsets.only(right: r.space(16)),
      );
    }
    return null;
  }
}

import 'package:flutter/material.dart';

/// Champ de saisie générique et réutilisable dans toute l'application.
///
/// Gère : masquage/démasquage du mot de passe, icônes de préfixe/suffixe,
/// validation, clavier adapté et contrôleur. Remplace tout `TextFormField`
/// codé en dur dans les vues (voir README, section "Core UI").
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.isPassword = false,
    this.isRequired = false,
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

  /// Icône de suffixe personnalisée. Ignorée si [isPassword] est `true`
  /// (le bouton œil est alors géré automatiquement).
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  final bool isPassword;
  final bool isRequired;
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
  bool _hasFocus = false;

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
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFocused = _hasFocus;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.hintText.replaceAll('*', '').trim(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (widget.isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE53E3E),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isFocused ? 0.12 : 0.06),
                blurRadius: isFocused ? 20 : 12,
                offset: const Offset(0, 4),
                spreadRadius: isFocused ? 0 : -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText.replaceAll('*', '').trim(),
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black.withValues(alpha: 0.35),
              ),
              prefixIcon: widget.icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20, right: 16),
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: isFocused ? Colors.black : Colors.black.withValues(alpha: 0.45),
                      ),
                    )
                  : const SizedBox(width: 56),
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              filled: true,
              fillColor: Colors.transparent,
              errorStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE53E3E),
                fontWeight: FontWeight.w500,
                height: 0.8,
              ),
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        onPressed: () => setState(() => _obscureText = !_obscureText),
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 22,
          color: Colors.black.withValues(alpha: 0.45),
        ),
        padding: const EdgeInsets.only(right: 20),
      );
    }
    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconTap,
        icon: Icon(
          widget.suffixIcon,
          size: 22,
          color: Colors.black.withValues(alpha: 0.45),
        ),
        padding: const EdgeInsets.only(right: 20),
      );
    }
    return null;
  }
}

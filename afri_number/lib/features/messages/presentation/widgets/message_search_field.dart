import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

/// Champ de recherche pilule blanc (44 px).
class MessageSearchField extends StatelessWidget {
  const MessageSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Rechercher un message...',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.ink,
        style: AppTypography.searchInput,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          hintText: hintText,
          hintStyle: AppTypography.searchHint,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../responsive/responsive.dart';

/// Interrupteur des maquettes (piste menthe, pouce blanc, 43 × 24).
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.inactiveColor = const Color(0xFFD9D9D9),
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final width = r.widthOf(43);
    final height = r.heightOf(24);
    final thumb = height - r.space(6);

    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: width,
          height: height,
          padding: EdgeInsets.all(r.space(3)),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? AppColors.mint : inactiveColor,
            borderRadius: BorderRadius.circular(height),
          ),
          child: Container(
            width: thumb,
            height: thumb,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

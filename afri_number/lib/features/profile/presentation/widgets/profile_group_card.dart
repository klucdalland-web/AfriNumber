import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

/// Grande carte adaptative au thème qui regroupe plusieurs [ProfileRow].
class ProfileGroupCard extends StatelessWidget {
  const ProfileGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: r.space(20),
        vertical: r.space(16),
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(r.radius(24)),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: r.space(24),
                thickness: 1,
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }
}

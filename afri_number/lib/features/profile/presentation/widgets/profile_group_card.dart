import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import 'profile_scale.dart';

/// Grande carte blanche (rayon 36) qui regroupe plusieurs [ProfileRow].
class ProfileGroupCard extends StatelessWidget {
  const ProfileGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: r.u(22), vertical: r.u(18)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(r.u(36)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) SizedBox(height: r.u(16)),
          ],
        ],
      ),
    );
  }
}

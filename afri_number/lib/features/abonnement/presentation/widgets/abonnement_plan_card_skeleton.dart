import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import 'skeleton.dart';

class AbonnementPlanCardSkeleton extends StatelessWidget {
  const AbonnementPlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: r.space(16)),
      padding: EdgeInsets.all(r.space(20)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(r.radius(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: r.space(110), height: r.space(22)),
                    SizedBox(height: r.space(8)),
                    SkeletonBox(width: r.space(170), height: r.space(14)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonBox(width: r.space(90), height: r.space(26)),
                  SizedBox(height: r.space(6)),
                  SkeletonBox(width: r.space(50), height: r.space(12)),
                ],
              ),
            ],
          ),
          SizedBox(height: r.space(20)),
          for (var i = 0; i < 4; i++) ...[
            Row(
              children: [
                SkeletonBox(
                  width: r.space(22),
                  height: r.space(22),
                  radius: 11,
                ),
                SizedBox(width: r.space(12)),
                Expanded(child: SkeletonBox(height: r.space(14))),
              ],
            ),
            SizedBox(height: r.space(14)),
          ],
          SizedBox(height: r.space(6)),
          SkeletonBox(
            width: double.infinity,
            height: r.heightOf(56),
            radius: r.radius(28),
          ),
        ],
      ),
    );
  }
}
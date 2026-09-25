import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../widgets/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.space(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 1. HEADER =====
                    WelcomeHeader(scale: r.scale),

                    SizedBox(height: r.space(40)),

                    // ===== 2. CARDS ZONE =====
                    WelcomeCards(scale: r.scale, screenWidth: r.width),

                    SizedBox(height: r.space(40)),

                    // ===== 3. SLOGAN =====
                    WelcomeSlogan(scale: r.scale),

                    SizedBox(height: r.space(40)),

                    // ===== 4. BOTTOM LOOP =====
                    BottomLoop(scale: r.scale),

                    SizedBox(height: r.space(24)),

                    // ===== 5. FOOTER =====
                    WelcomeFooter(scale: r.scale),

                    SizedBox(height: r.space(20)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
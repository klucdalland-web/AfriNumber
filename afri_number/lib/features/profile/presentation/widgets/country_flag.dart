import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';

/// Delegate to core CountryFlagBadge for vector flags across the app.
class CountryFlag extends StatelessWidget {
  const CountryFlag({super.key, required this.code, this.size = 24});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CountryFlagBadge(code: code, size: size);
  }
}

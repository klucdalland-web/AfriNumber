import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/platform_utils.dart';
import '../controllers/main_controller.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  static final _items = [
    _NavItem(icon: Icons.home_outlined, label: 'nav.home'.tr),
    _NavItem(icon: Icons.search, label: 'nav.search'.tr),
    _NavItem(icon: Icons.wifi_rounded, label: 'nav.connectivity'.tr),
    _NavItem(icon: Icons.access_time, label: 'nav.history'.tr),
    _NavItem(icon: Icons.person_outline, label: 'nav.profile'.tr),
  ];

  // Tailles de référence
  static const double _barHeight = 64;
  static const double _activeIconSize = 20;
  static const double _inactiveIconSize = 22;
  static const double _labelFontSize = 13;
  static const double _gap = 4;
  static const double _hPadding = 12;

  // Zone tactile minimale d'un item inactif
  static const double _minInactiveWidth = 48;
  // Sur tablette / paysage : la barre ne s'étire pas indéfiniment
  static const double _maxBarWidth = 640;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBgColor = isDark ? const Color(0xFF18181A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF0F0F0);
    final activeColor = isDark ? Colors.white : const Color(0xFF030303);
    final inactiveColor = isDark ? const Color(0xFF8C9599) : const Color(0xFF505050);

    final mq = MediaQuery.of(context);
    final textScaler = mq.textScaler.clamp(maxScaleFactor: 1.2);

    // Option iPhone : NavBar flottante en bas avec coins arrondis et ombre
    if (isApplePlatform) {
      return MediaQuery(
        data: mq.copyWith(textScaler: textScaler),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxBarWidth),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                height: _barHeight,
                decoration: BoxDecoration(
                  color: navBgColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: _buildBarContent(textScaler, activeColor, inactiveColor),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Option Android : NavBar ancrée en bas avec bordure supérieure
    return MediaQuery(
      data: mq.copyWith(textScaler: textScaler),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxBarWidth),
              child: SizedBox(
                height: _barHeight,
                child: _buildBarContent(textScaler, activeColor, inactiveColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarContent(
    TextScaler textScaler,
    Color activeColor,
    Color inactiveColor,
  ) {
    final controller = Get.find<MainController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final count = _items.length;

        return Obx(() {
          final selected = controller.currentIndex.value;

          final labelWidth = _measureLabel(
            _items[selected].label,
            textScaler,
          );
          final neededWidth =
              _hPadding * 2 + _activeIconSize + _gap + labelWidth;

          final maxSelectedWidth =
              totalWidth - (count - 1) * _minInactiveWidth;

          final selectedWidth = neededWidth
              .clamp(_minInactiveWidth, maxSelectedWidth)
              .toDouble();
          final inactiveWidth =
              (totalWidth - selectedWidth) / (count - 1);

          return Row(
            children: List.generate(count, (index) {
              final isSelected = selected == index;
              return _NavBarButton(
                item: _items[index],
                isSelected: isSelected,
                width: isSelected ? selectedWidth : inactiveWidth,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                activeIconSize: _activeIconSize,
                inactiveIconSize: _inactiveIconSize,
                labelFontSize: _labelFontSize,
                gap: _gap,
                onTap: () {
                  if (!isSelected) {
                    HapticFeedback.selectionClick();
                    controller.changePage(index);
                  }
                },
              );
            }),
          );
        });
      },
    );
  }

  static double _measureLabel(String label, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: _labelFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    return painter.width;
  }
}

class _NavBarButton extends StatelessWidget {
  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.width,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeIconSize,
    required this.inactiveIconSize,
    required this.labelFontSize,
    required this.gap,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final double width;
  final Color activeColor;
  final Color inactiveColor;
  final double activeIconSize;
  final double inactiveIconSize;
  final double labelFontSize;
  final double gap;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      curve: _curve,
      width: width,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: item.label,
        excludeSemantics: true,
        child: Tooltip(
          message: item.label,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              children: [
                // Indicateur en haut, adapté à la largeur disponible
                AnimatedContainer(
                  duration: _duration,
                  curve: _curve,
                  height: 3,
                  width: isSelected ? (width - 16).clamp(0.0, 50.0) : 0,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: isSelected
                          ? _SelectedContent(
                              key: ValueKey('selected_${item.label}'),
                              item: item,
                              color: activeColor,
                              iconSize: activeIconSize,
                              fontSize: labelFontSize,
                              gap: gap,
                            )
                          : Icon(
                              item.icon,
                              key: ValueKey('idle_${item.label}'),
                              size: inactiveIconSize,
                              color: inactiveColor,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedContent extends StatelessWidget {
  const _SelectedContent({
    super.key,
    required this.item,
    required this.color,
    required this.iconSize,
    required this.fontSize,
    required this.gap,
  });

  final _NavItem item;
  final Color color;
  final double iconSize;
  final double fontSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: iconSize, color: color),
          SizedBox(width: gap),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

/// Scaffold adaptatif :
/// - iOS (natif) → [CupertinoPageScaffold]
/// - Android / web / + bottom bar → [Scaffold] Material
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  bool get _hasAppBar =>
      title != null || leading != null || (actions?.isNotEmpty ?? false);

  /// BottomAppBar / FAB nécessitent un [Scaffold] Material.
  bool get _needsMaterialScaffold =>
      bottomNavigationBar != null || floatingActionButton != null;

  @override
  Widget build(BuildContext context) {
    if (isApplePlatform && !_needsMaterialScaffold) {
      return _buildCupertino(context);
    }
    return _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: _hasAppBar
          ? AppBar(
              title: title != null ? Text(title!) : null,
              leading: leading,
              actions: actions,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final theme = Theme.of(context);
    final cupertino = theme.cupertinoOverrideTheme;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: theme.brightness,
        primaryColor: cupertino?.primaryColor ?? theme.colorScheme.primary,
        scaffoldBackgroundColor: backgroundColor ??
            cupertino?.scaffoldBackgroundColor ??
            theme.scaffoldBackgroundColor,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        navigationBar: _hasAppBar
            ? CupertinoNavigationBar(
                middle: title != null ? Text(title!) : null,
                leading: leading,
                trailing: actions == null || actions!.isEmpty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
              )
            : null,
        child: SafeArea(
          child: Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: body,
          ),
        ),
      ),
    );
  }
}

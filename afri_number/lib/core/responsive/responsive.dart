import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Breakpoints for responsive design
enum Breakpoint {
  mobile('mobile', 0),
  tablet('tablet', 600),
  desktop('desktop', 900),
  largeDesktop('largeDesktop', 1200);

  const Breakpoint(this.name, this.minWidth);

  final String name;
  final double minWidth;
}

/// Responsive utility for consistent scaling across the app
class Responsive {
  Responsive._();

  /// Base design width (iPhone 13/14 Pro width)
  static const double _baseWidth = 393.0;
  static const double _baseHeight = 852.0;

  /// Maximum scale factor to prevent overscaling on large screens
  static const double _maxScale = 1.3;
  static const double _minScale = 0.85;

  /// Singleton instance
  static final Responsive _instance = Responsive._();
  static Responsive get instance => _instance;

  /// Current MediaQuery (set per build)
  MediaQueryData? _mediaQuery;

  /// Initialize with context (call once per build)
  void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
  }

  /// Get current screen width
  double get width => _mediaQuery?.size.width ?? _baseWidth;

  /// Get current screen height
  double get height => _mediaQuery?.size.height ?? _baseHeight;

  /// Get screen size
  Size get size => Size(width, height);

  /// Get device pixel ratio
  double get pixelRatio => _mediaQuery?.devicePixelRatio ?? 1.0;

  /// Get text scale factor (system font size) - deprecated, use textScaler
  @Deprecated('Use textScaler.scale() instead')
  double get textScaleFactor => _mediaQuery?.textScaler.textScaleFactor ?? 1.0;

  /// Get text scaler for nonlinear text scaling (Flutter 3.12+)
  TextScaler get textScaler => _mediaQuery?.textScaler ?? TextScaler.noScaling;

  /// Get safe area padding
  EdgeInsets get padding => _mediaQuery?.padding ?? EdgeInsets.zero;

  /// Get view padding (including system UI)
  EdgeInsets get viewPadding => _mediaQuery?.viewPadding ?? EdgeInsets.zero;

  /// Get view insets (keyboard, etc.)
  EdgeInsets get viewInsets => _mediaQuery?.viewInsets ?? EdgeInsets.zero;

  /// Current orientation
  Orientation get orientation => _mediaQuery?.orientation ?? Orientation.portrait;

  /// Whether keyboard is open
  bool get isKeyboardOpen => viewInsets.bottom > 0;

  /// Horizontal scale factor based on width
  double get scaleWidth => _clampScale(width / _baseWidth);

  /// Vertical scale factor based on height
  double get scaleHeight => _clampScale(height / _baseHeight);

  /// General scale factor (uses width for consistency)
  double get scale => scaleWidth;

  /// Scale factor for fonts (respects system text scale)
  double get fontScale => scale * textScaleFactor;

  /// Clamp scale to min/max bounds
  double _clampScale(double value) {
    return value.clamp(_minScale, _maxScale);
  }

  /// Get current breakpoint
  Breakpoint get breakpoint {
    final w = width;
    if (w >= Breakpoint.largeDesktop.minWidth) return Breakpoint.largeDesktop;
    if (w >= Breakpoint.desktop.minWidth) return Breakpoint.desktop;
    if (w >= Breakpoint.tablet.minWidth) return Breakpoint.tablet;
    return Breakpoint.mobile;
  }

  /// Check if current breakpoint is at least the given one
  bool isAtLeast(Breakpoint bp) => width >= bp.minWidth;

  /// Check if current breakpoint is at most the given one
  bool isAtMost(Breakpoint bp) => width < _nextBreakpoint(bp).minWidth;

  Breakpoint _nextBreakpoint(Breakpoint bp) {
    switch (bp) {
      case Breakpoint.mobile:
        return Breakpoint.tablet;
      case Breakpoint.tablet:
        return Breakpoint.desktop;
      case Breakpoint.desktop:
        return Breakpoint.largeDesktop;
      case Breakpoint.largeDesktop:
        return Breakpoint.largeDesktop;
    }
  }

  /// Responsive value based on breakpoint
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final bp = breakpoint;
    switch (bp) {
      case Breakpoint.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case Breakpoint.desktop:
        return desktop ?? tablet ?? mobile;
      case Breakpoint.tablet:
        return tablet ?? mobile;
      case Breakpoint.mobile:
        return mobile;
    }
  }

  /// Responsive padding
  EdgeInsets responsivePadding({
    double horizontal = 24,
    double vertical = 16,
    double? mobileHorizontal,
    double? mobileVertical,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: value<double>(
        mobile: mobileHorizontal ?? horizontal,
        tablet: tabletHorizontal ?? horizontal * 1.25,
        desktop: desktopHorizontal ?? horizontal * 1.5,
      ),
      vertical: value<double>(
        mobile: mobileVertical ?? vertical,
        tablet: tabletVertical ?? vertical * 1.25,
        desktop: desktopVertical ?? vertical * 1.5,
      ),
    );
  }

  /// Responsive font size
  double fontSize(double baseSize, {double? minSize, double? maxSize}) {
    final scaled = baseSize * fontScale;
    if (minSize != null && scaled < minSize) return minSize;
    if (maxSize != null && scaled > maxSize) return maxSize;
    return scaled;
  }

  /// Responsive width
  double widthOf(double baseWidth) => baseWidth * scaleWidth;

  /// Responsive height
  double heightOf(double baseHeight) => baseHeight * scaleHeight;

  /// Responsive size
  Size sizeOf(Size baseSize) => Size(widthOf(baseSize.width), heightOf(baseSize.height));

  /// Responsive radius
  double radius(double baseRadius) => baseRadius * scale;

  /// Responsive spacing
  double spacing(double baseSpacing) => baseSpacing * scale;

  /// Alias for spacing
  double space(double baseSpacing) => spacing(baseSpacing);

  /// Responsive icon size
  double iconSize(double baseSize) => baseSize * scale;

  /// Alias for responsivePadding
  EdgeInsets pad({double h = 24, double v = 16}) => responsivePadding(
    horizontal: h,
    vertical: v,
  );

  /// Whether device is tablet or larger
  bool get isTabletOrLarger => isAtLeast(Breakpoint.tablet);

  /// Whether device is desktop or larger
  bool get isDesktopOrLarger => isAtLeast(Breakpoint.desktop);

  /// Whether device is mobile
  bool get isMobile => breakpoint == Breakpoint.mobile;

  /// Whether device is in landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Shortcuts for common responsive values
  double get xs => spacing(4);
  double get sm => spacing(8);
  double get md => spacing(16);
  double get lg => spacing(24);
  double get xl => spacing(32);
  double get xxl => spacing(48);

  /// Screen type helpers
  bool get isCompact => width < 360;
  bool get isRegular => width >= 360 && width < 600;
  bool get isExpanded => width >= 600;

  /// Get responsive container max width for content
  double get contentMaxWidth => value<double>(
    mobile: double.infinity,
    tablet: 540,
    desktop: 720,
    largeDesktop: 960,
  );

  /// Get responsive grid columns
  int get gridColumns => value<int>(
    mobile: 1,
    tablet: 2,
    desktop: 3,
    largeDesktop: 4,
  );

  /// Get responsive item count for lists
  int listItemCount(int baseCount) {
    if (isDesktopOrLarger) return (baseCount * 1.5).round();
    if (isTabletOrLarger) return (baseCount * 1.25).round();
    return baseCount;
  }
}

/// Extension for easy responsive access in build methods
extension ResponsiveBuildContext on BuildContext {
  Responsive get responsive {
    final r = Responsive.instance;
    r.init(this);
    return r;
  }

  double get rScale => responsive.scale;
  double get rFontScale => responsive.fontScale;
  double get rWidth => responsive.width;
  double get rHeight => responsive.height;
  Breakpoint get rBreakpoint => responsive.breakpoint;
  bool get rIsMobile => responsive.isMobile;
  bool get rIsTablet => responsive.isTabletOrLarger;
  bool get rIsDesktop => responsive.isDesktopOrLarger;
  bool get rIsLandscape => responsive.isLandscape;
  EdgeInsets get rPadding => responsive.padding;
  EdgeInsets get rViewPadding => responsive.viewPadding;
  EdgeInsets get rViewInsets => responsive.viewInsets;
}

/// Widget that initializes Responsive and provides it to children
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext, Responsive) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Builder(
          builder: (context) {
            final r = Responsive.instance;
            r.init(context);
            return builder(context, r);
          },
        );
      },
    );
  }
}

/// Mixin for widgets that need responsive values
mixin ResponsiveMixin on StatelessWidget {
  Responsive get r => Responsive.instance;

  double scale(double value) => r.widthOf(value);
  double height(double value) => r.heightOf(value);
  double font(double value) => r.fontSize(value);
  double space(double value) => r.spacing(value);
  double radius(double value) => r.radius(value);
  double icon(double value) => r.iconSize(value);
  EdgeInsets pad({double h = 24, double v = 16}) => r.responsivePadding(
    horizontal: h,
    vertical: v,
  );
}
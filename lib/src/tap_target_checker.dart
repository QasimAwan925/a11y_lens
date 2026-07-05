import 'dart:ui';

/// Utility for checking whether tappable UI elements meet minimum
/// recommended touch target sizes.
class TapTargetChecker {
  const TapTargetChecker._();

  /// Minimum recommended size (in logical pixels) for a comfortably
  /// tappable target, per Material Design guidance and WCAG 2.5.5
  /// (Target Size).
  static const double minimumSize = 48.0;

  /// Whether [size] meets the minimum recommended tap target size
  /// in both width and height.
  static bool passes(Size size) {
    return size.width >= minimumSize && size.height >= minimumSize;
  }
}

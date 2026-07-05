import 'dart:math' as math;
import 'dart:ui';

/// Utility for calculating WCAG color contrast ratios.
///
/// See: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html
class ContrastChecker {
  const ContrastChecker._();

  /// Returns the WCAG relative luminance of [color], a value from 0 to 1.
  static double luminance(Color color) {
    double channel(double value) {
      return value <= 0.03928
          ? value / 12.92
          : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * channel(color.r) +
        0.7152 * channel(color.g) +
        0.0722 * channel(color.b);
  }

  /// Returns the WCAG contrast ratio between [foreground] and [background].
  ///
  /// The result ranges from 1 (no contrast, identical colors) to 21
  /// (maximum contrast, pure black on pure white).
  static double ratio(Color foreground, Color background) {
    final l1 = luminance(foreground);
    final l2 = luminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Whether [ratio] passes WCAG level AA.
  ///
  /// Normal text requires >= 4.5:1. Large text (18pt+/24px+, or 14pt+/19px+
  /// bold) requires >= 3.0:1 — set [isLargeText] to true for that case.
  static bool passesAA(double ratio, {bool isLargeText = false}) {
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Whether [ratio] passes the stricter WCAG level AAA.
  ///
  /// Normal text requires >= 7.0:1, large text requires >= 4.5:1.
  static bool passesAAA(double ratio, {bool isLargeText = false}) {
    return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
  }
}
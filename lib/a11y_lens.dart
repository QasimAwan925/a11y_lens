/// A lightweight, dependency-free accessibility toolkit for Flutter.
///
/// Catch color contrast and tap-target size issues at debug time, before
/// they ship, with zero-cost widgets in release builds.
library a11y_lens;

export 'src/a11y_issue.dart';
export 'src/a11y_lens_widget.dart';
export 'src/a11y_registry.dart';
export 'src/contrast_checker.dart';
export 'src/contrast_guard.dart';
export 'src/tap_target_checker.dart';
export 'src/tap_target_guard.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'a11y_issue.dart';
import 'a11y_registry.dart';
import 'contrast_checker.dart';

/// Wraps [child] and checks the contrast between [foreground] and
/// [background] against WCAG AA.
///
/// In debug mode, a failing pair is outlined in red and reported to
/// [A11yRegistry.instance]. In release/profile mode this widget is a
/// zero-cost passthrough to [child].
///
/// Example:
/// ```dart
/// ContrastGuard(
///   id: 'hero_title',
///   foreground: Colors.grey,
///   background: Colors.white,
///   child: Text('Welcome', style: TextStyle(color: Colors.grey)),
/// )
/// ```
class ContrastGuard extends StatefulWidget {
  /// Stable id used to track this check across rebuilds. Must be unique
  /// within your app.
  final String id;

  /// The text/foreground color being checked.
  final Color foreground;

  /// The color behind [child].
  final Color background;

  /// Whether [child] counts as "large text" under WCAG (18pt+/24px+, or
  /// 14pt+/19px+ bold), which has a lower passing threshold (3.0:1
  /// instead of 4.5:1).
  final bool isLargeText;

  /// The widget being checked. Rendered unchanged if the check passes,
  /// or in release mode.
  final Widget child;

  const ContrastGuard({
    super.key,
    required this.id,
    required this.foreground,
    required this.background,
    required this.child,
    this.isLargeText = false,
  });

  @override
  State<ContrastGuard> createState() => _ContrastGuardState();
}

class _ContrastGuardState extends State<ContrastGuard> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      // Defer to after the current build/layout phase. Reporting directly
      // to the registry here would trigger a rebuild of any listening
      // widget (e.g. A11yLens) while this widget is still being built,
      // which Flutter disallows.
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  void didUpdateWidget(covariant ContrastGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode &&
        (oldWidget.foreground != widget.foreground ||
            oldWidget.background != widget.background ||
            oldWidget.isLargeText != widget.isLargeText)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  void _check() {
    if (!mounted) return;
    final ratio = ContrastChecker.ratio(widget.foreground, widget.background);
    final passes =
        ContrastChecker.passesAA(ratio, isLargeText: widget.isLargeText);
    final failed = !passes;

    if (failed) {
      A11yRegistry.instance.report(
        A11yIssue(
          id: widget.id,
          type: A11yIssueType.contrast,
          message: 'Low contrast (${ratio.toStringAsFixed(2)}:1, needs '
              '${widget.isLargeText ? '3.0' : '4.5'}:1) — id: ${widget.id}',
        ),
      );
    } else {
      A11yRegistry.instance.clear(widget.id);
    }

    if (mounted && failed != _failed) {
      setState(() => _failed = failed);
    }
  }

  @override
  void dispose() {
    if (kDebugMode) A11yRegistry.instance.clear(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !_failed) return widget.child;
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
      child: widget.child,
    );
  }
}

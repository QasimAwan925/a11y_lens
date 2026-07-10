import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'a11y_issue.dart';
import 'a11y_registry.dart';
import 'tap_target_checker.dart';

/// Wraps a tappable [child] and checks its rendered size, after every
/// layout pass, against the minimum recommended tap target size
/// ([TapTargetChecker.minimumSize]).
///
/// In debug mode, an undersized target is outlined in orange and
/// reported to [A11yRegistry.instance]. Tapping this issue in
/// [A11yLens]'s report scrolls to and briefly flashes this exact widget.
/// In release/profile mode this widget is a zero-cost passthrough to
/// [child].
///
/// Example:
/// ```dart
/// TapTargetGuard(
///   id: 'close_button',
///   label: 'Dialog close icon',
///   child: IconButton(icon: Icon(Icons.close), onPressed: onClose),
/// )
/// ```
class TapTargetGuard extends StatefulWidget {
  /// Stable id used to track this check across rebuilds. Must be unique
  /// within your app.
  final String id;

  /// Optional human-readable description shown in the report instead of
  /// the raw [id] (e.g. "Dialog close icon" instead of "close_button").
  final String? label;

  /// The tappable widget being checked.
  final Widget child;

  const TapTargetGuard({
    super.key,
    required this.id,
    required this.child,
    this.label,
  });

  @override
  State<TapTargetGuard> createState() => _TapTargetGuardState();
}

class _TapTargetGuardState extends State<TapTargetGuard> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _failed = false;
  bool _flashing = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  String _describe(Size size) {
    final where = widget.label != null
        ? '${widget.label} (id: ${widget.id})'
        : 'id: ${widget.id}';
    final min = TapTargetChecker.minimumSize.toStringAsFixed(0);
    return 'Tap target too small '
        '(${size.width.toStringAsFixed(0)}x${size.height.toStringAsFixed(0)}, '
        'needs ${min}x$min) — $where';
  }

  void _check() {
    if (!mounted) return;
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final passes = TapTargetChecker.passes(renderObject.size);
    final failed = !passes;

    if (failed) {
      A11yRegistry.instance.report(
        A11yIssue(
          id: widget.id,
          type: A11yIssueType.tapTarget,
          message: _describe(renderObject.size),
          anchorKey: _anchorKey,
          onLocate: _flash,
        ),
      );
    } else {
      A11yRegistry.instance.clear(widget.id);
    }

    if (mounted && failed != _failed) {
      setState(() => _failed = failed);
    }
  }

  /// Briefly highlights this widget in amber. Called when the user taps
  /// this issue in the [A11yLens] report panel, after it's scrolled into
  /// view.
  void _flash() {
    if (!mounted) return;
    setState(() => _flashing = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _flashing = false);
    });
  }

  @override
  void dispose() {
    if (kDebugMode) A11yRegistry.instance.clear(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    final showOutline = _failed || _flashing;
    return Container(
      key: _anchorKey,
      decoration: showOutline
          ? BoxDecoration(
              border: Border.all(
                color: _flashing ? Colors.amber : Colors.orange,
                width: _flashing ? 4 : 2,
              ),
            )
          : null,
      child: widget.child,
    );
  }
}

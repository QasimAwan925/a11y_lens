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
/// reported to [A11yRegistry.instance]. In release/profile mode this
/// widget is a zero-cost passthrough to [child].
///
/// Example:
/// ```dart
/// TapTargetGuard(
///   id: 'close_button',
///   child: IconButton(icon: Icon(Icons.close), onPressed: onClose),
/// )
/// ```
class TapTargetGuard extends StatefulWidget {
  /// Stable id used to track this check across rebuilds. Must be unique
  /// within your app.
  final String id;

  /// The tappable widget being checked.
  final Widget child;

  const TapTargetGuard({super.key, required this.id, required this.child});

  @override
  State<TapTargetGuard> createState() => _TapTargetGuardState();
}

class _TapTargetGuardState extends State<TapTargetGuard> {
  final GlobalKey _key = GlobalKey();
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  void _check() {
    if (!mounted) return;
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final passes = TapTargetChecker.passes(renderObject.size);
    final failed = !passes;

    if (failed) {
      A11yRegistry.instance.report(
        A11yIssue(
          id: widget.id,
          type: A11yIssueType.tapTarget,
          message: 'Tap target too small '
              '(${renderObject.size.width.toStringAsFixed(0)}x'
              '${renderObject.size.height.toStringAsFixed(0)}, needs '
              '${TapTargetChecker.minimumSize.toStringAsFixed(0)}x'
              '${TapTargetChecker.minimumSize.toStringAsFixed(0)}) — id: ${widget.id}',
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
    if (!kDebugMode) return widget.child;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    return Container(
      key: _key,
      decoration: _failed
          ? BoxDecoration(border: Border.all(color: Colors.orange, width: 2))
          : null,
      child: widget.child,
    );
  }
}

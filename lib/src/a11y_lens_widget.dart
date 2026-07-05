import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'a11y_issue.dart';
import 'a11y_registry.dart';

/// Wraps your app (typically via `MaterialApp.builder`) to show a
/// floating debug button reporting live accessibility issues found by
/// [ContrastGuard] and [TapTargetGuard] widgets elsewhere in the tree.
///
/// In release/profile mode this simply returns [child] unchanged.
///
/// This widget is intentionally self-contained: it does not use
/// [Navigator]/[showModalBottomSheet], since `A11yLens` typically sits
/// *outside* your app's Navigator (it wraps `MaterialApp.builder`'s
/// output), so no Navigator is guaranteed to be in scope.
///
/// Example:
/// ```dart
/// MaterialApp(
///   builder: (context, child) => A11yLens(child: child ?? const SizedBox()),
///   home: const HomePage(),
/// )
/// ```
class A11yLens extends StatefulWidget {
  final Widget child;

  const A11yLens({super.key, required this.child});

  @override
  State<A11yLens> createState() => _A11yLensState();
}

class _A11yLensState extends State<A11yLens> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 16,
          right: 16,
          child: SafeArea(
            child: ValueListenableBuilder<Map<String, A11yIssue>>(
              valueListenable: A11yRegistry.instance.issues,
              builder: (context, issuesMap, _) {
                final issues = issuesMap.values.toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_expanded) ...[
                      _ReportPanel(issues: issues),
                      const SizedBox(height: 8),
                    ],
                    Badge(
                      isLabelVisible: issues.isNotEmpty,
                      label: Text('${issues.length}'),
                      child: FloatingActionButton.small(
                        heroTag: 'a11y_lens_fab',
                        backgroundColor:
                            issues.isNotEmpty ? Colors.red : Colors.green,
                        onPressed: () => setState(() => _expanded = !_expanded),
                        child: Icon(
                          _expanded ? Icons.close : Icons.accessibility_new,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportPanel extends StatelessWidget {
  final List<A11yIssue> issues;

  const _ReportPanel({required this.issues});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280, maxHeight: 320),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accessibility Report',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: issues.isEmpty
                    ? const Text('No issues found. \u2705')
                    : ListView(
                        shrinkWrap: true,
                        children: issues
                            .map(
                              (issue) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '\u2022 ${issue.message}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

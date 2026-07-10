import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'a11y_issue.dart';
import 'a11y_registry.dart';

/// Wraps your app (typically via `MaterialApp.builder`) to show a
/// floating debug button reporting live accessibility issues found by
/// [ContrastGuard] and [TapTargetGuard] widgets elsewhere in the tree.
///
/// Tapping an issue in the report scrolls the offending widget into
/// view and briefly flashes it in amber, so you can find exactly which
/// element is failing without hunting through the screen manually.
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

  void _locate(A11yIssue issue) {
    // Collapse the panel first so it doesn't obscure the widget once
    // it's scrolled into view.
    setState(() => _expanded = false);
    final ctx = issue.anchorKey?.currentContext;
    if (ctx == null) {
      issue.onLocate?.call();
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    ).then((_) => issue.onLocate?.call());
  }

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
                      _ReportPanel(issues: issues, onLocate: _locate),
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
  final ValueChanged<A11yIssue> onLocate;

  const _ReportPanel({required this.issues, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 340),
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
              if (issues.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Tap an issue to jump to it',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Flexible(
                child: issues.isEmpty
                    ? const Text('No issues found. \u2705')
                    : ListView(
                        shrinkWrap: true,
                        children: issues
                            .map(
                              (issue) => InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () => onLocate(issue),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.my_location,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          issue.message,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
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

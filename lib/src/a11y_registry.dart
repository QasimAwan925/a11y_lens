import 'package:flutter/foundation.dart';

import 'a11y_issue.dart';

/// Global, in-memory registry of accessibility issues found by guard
/// widgets ([ContrastGuard], [TapTargetGuard]) during a debug session.
///
/// Issues are keyed by [A11yIssue.id] so repeated checks (e.g. on
/// rebuild) update or clear an entry instead of duplicating it.
class A11yRegistry {
  A11yRegistry._();

  /// The shared singleton instance used by all guard widgets.
  static final A11yRegistry instance = A11yRegistry._();

  final ValueNotifier<Map<String, A11yIssue>> _issues =
      ValueNotifier<Map<String, A11yIssue>>(<String, A11yIssue>{});

  /// Listenable map of current issues, keyed by issue id.
  ValueListenable<Map<String, A11yIssue>> get issues => _issues;

  /// Reports (or updates) an issue under [A11yIssue.id].
  void report(A11yIssue issue) {
    final updated = Map<String, A11yIssue>.from(_issues.value);
    updated[issue.id] = issue;
    _issues.value = updated;
  }

  /// Clears a previously reported issue by [id], if present.
  void clear(String id) {
    if (!_issues.value.containsKey(id)) return;
    final updated = Map<String, A11yIssue>.from(_issues.value)..remove(id);
    _issues.value = updated;
  }

  /// Removes all reported issues.
  void reset() => _issues.value = <String, A11yIssue>{};
}

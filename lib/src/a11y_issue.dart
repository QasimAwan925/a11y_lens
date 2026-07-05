/// The category of accessibility problem an [A11yIssue] represents.
enum A11yIssueType { contrast, tapTarget }

/// A single detected accessibility issue.
class A11yIssue {
  /// Stable identifier matching the `id` given to the guard widget that
  /// reported this issue. Used to update/clear the issue without
  /// duplicating it on rebuilds.
  final String id;

  /// The kind of issue detected.
  final A11yIssueType type;

  /// Human-readable description shown in the report.
  final String message;

  const A11yIssue({
    required this.id,
    required this.type,
    required this.message,
  });

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is A11yIssue &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          message == other.message;

  @override
  int get hashCode => Object.hash(id, type, message);
}

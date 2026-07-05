import 'package:a11y_lens/a11y_lens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => A11yRegistry.instance.reset());

  group('A11yRegistry', () {
    test('report adds an issue', () {
      A11yRegistry.instance.report(
        const A11yIssue(id: 'x', type: A11yIssueType.contrast, message: 'bad'),
      );
      expect(A11yRegistry.instance.issues.value.length, 1);
    });

    test('clear removes an issue by id', () {
      A11yRegistry.instance.report(
        const A11yIssue(id: 'x', type: A11yIssueType.contrast, message: 'bad'),
      );
      A11yRegistry.instance.clear('x');
      expect(A11yRegistry.instance.issues.value.isEmpty, isTrue);
    });

    test('clearing an unknown id is a no-op', () {
      A11yRegistry.instance.clear('does_not_exist');
      expect(A11yRegistry.instance.issues.value.isEmpty, isTrue);
    });

    test('reporting the same id twice overwrites rather than duplicates', () {
      A11yRegistry.instance.report(
        const A11yIssue(
            id: 'x', type: A11yIssueType.contrast, message: 'first'),
      );
      A11yRegistry.instance.report(
        const A11yIssue(
            id: 'x', type: A11yIssueType.contrast, message: 'second'),
      );
      expect(A11yRegistry.instance.issues.value.length, 1);
      expect(A11yRegistry.instance.issues.value['x']!.message, 'second');
    });

    test('reset clears all issues', () {
      A11yRegistry.instance.report(
        const A11yIssue(id: 'a', type: A11yIssueType.contrast, message: 'x'),
      );
      A11yRegistry.instance.report(
        const A11yIssue(id: 'b', type: A11yIssueType.tapTarget, message: 'y'),
      );
      A11yRegistry.instance.reset();
      expect(A11yRegistry.instance.issues.value.isEmpty, isTrue);
    });
  });
}

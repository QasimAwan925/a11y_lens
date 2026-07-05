import 'dart:ui';

import 'package:a11y_lens/a11y_lens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TapTargetChecker', () {
    test('exactly the minimum size passes', () {
      expect(TapTargetChecker.passes(const Size(48, 48)), isTrue);
    });

    test('below minimum width fails', () {
      expect(TapTargetChecker.passes(const Size(40, 48)), isFalse);
    });

    test('below minimum height fails', () {
      expect(TapTargetChecker.passes(const Size(48, 40)), isFalse);
    });

    test('above minimum in both dimensions passes', () {
      expect(TapTargetChecker.passes(const Size(56, 56)), isTrue);
    });
  });
}

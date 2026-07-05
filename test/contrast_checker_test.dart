import 'package:a11y_lens/a11y_lens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContrastChecker', () {
    test('black on white has ratio ~21', () {
      final r = ContrastChecker.ratio(Colors.black, Colors.white);
      expect(r, closeTo(21, 0.1));
    });

    test('identical colors have ratio 1', () {
      final r = ContrastChecker.ratio(Colors.red, Colors.red);
      expect(r, closeTo(1, 0.01));
    });

    test('ratio is symmetric regardless of argument order', () {
      final r1 = ContrastChecker.ratio(Colors.black, Colors.white);
      final r2 = ContrastChecker.ratio(Colors.white, Colors.black);
      expect(r1, closeTo(r2, 0.0001));
    });

    test('passesAA is true for high contrast normal text', () {
      final r = ContrastChecker.ratio(Colors.black, Colors.white);
      expect(ContrastChecker.passesAA(r), isTrue);
    });

    test('passesAA is false for low contrast normal text', () {
      final r = ContrastChecker.ratio(
        const Color(0xFFAAAAAA),
        const Color(0xFFBBBBBB),
      );
      expect(ContrastChecker.passesAA(r), isFalse);
    });

    test('large text has a lower passing threshold than normal text', () {
      expect(ContrastChecker.passesAA(3.5, isLargeText: true), isTrue);
      expect(ContrastChecker.passesAA(3.5, isLargeText: false), isFalse);
    });

    test('passesAAA is stricter than passesAA', () {
      const ratio = 5.0;
      expect(ContrastChecker.passesAA(ratio), isTrue);
      expect(ContrastChecker.passesAAA(ratio), isFalse);
    });
  });
}

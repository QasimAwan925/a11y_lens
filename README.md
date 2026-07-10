# a11y_lens

A lightweight, dependency-free accessibility toolkit for Flutter. Catch
color contrast and tap-target size issues **at debug time**, before they
ship — instead of finding out from an app store rejection or an
accessibility audit.

- ✅ Pure Dart contrast math (WCAG 2.1) — no platform channels, no native code
- ✅ Zero runtime cost in release/profile builds
- ✅ Drop-in guard widgets — wrap what you already have
- ✅ Live floating report overlay while you develop
- ✅ Tap an issue to jump straight to it — no hunting through the screen

## Why

Accessibility bugs are cheap to fix during development and expensive to
fix after launch — and increasingly, they're a legal requirement, not
just a nice-to-have. `a11y_lens` surfaces the two most common, easiest
to miss issues directly in your existing debug workflow: low text
contrast and undersized tap targets.

## Install

```yaml
dependencies:
  a11y_lens: ^0.2.0
```

```bash
flutter pub get
```

## Usage

### 1. Add the live report overlay

Wrap your app once, typically in `MaterialApp.builder`:

```dart
import 'package:a11y_lens/a11y_lens.dart';
import 'package:flutter/material.dart';

MaterialApp(
  builder: (context, child) => A11yLens(child: child ?? const SizedBox()),
  home: const HomePage(),
)
```

This adds a small floating button (debug builds only) that shows a live
count and detail list of any issues currently on screen.

### 2. Guard your text for contrast

```dart
ContrastGuard(
  id: 'hero_title',                    // unique, stable id
  label: 'Welcome banner title',       // optional, shown in the report
  foreground: Colors.grey,
  background: Colors.white,
  child: Text(
    'Welcome',
    style: TextStyle(color: Colors.grey),
  ),
)
```

If the contrast ratio fails WCAG AA (4.5:1 for normal text, 3.0:1 for
large text), the widget gets a red debug outline and the issue appears
in the live report.

### 3. Guard your tappable widgets for size

```dart
TapTargetGuard(
  id: 'close_button',
  label: 'Dialog close icon',          // optional, shown in the report
  child: IconButton(
    icon: const Icon(Icons.close),
    onPressed: onClose,
  ),
)
```

If the rendered size is smaller than 48x48 logical pixels in either
dimension, the widget gets an orange debug outline and the issue
appears in the live report.

### 4. Find an issue instantly with tap-to-locate

Every issue in the live report is tappable. Tapping one:

1. Scrolls the page so the offending widget comes into view
2. Flashes it amber for about a second

No more scanning a long screen for a stray red or orange outline — the
report panel takes you straight to it.

### 5. Use the checkers directly (no widgets)

Both checks are also available as plain static utilities, useful for
unit tests or design-system validation scripts:

```dart
final ratio = ContrastChecker.ratio(Colors.grey, Colors.white);
final ok = ContrastChecker.passesAA(ratio);

final fits = TapTargetChecker.passes(const Size(40, 40)); // false
```

## What this does *not* do (yet)

This is intentionally scoped small:

- No automatic whole-tree scanning — you opt in per widget with the
  guards. This keeps false positives near zero and requires no fragile
  tree-walking.
- No screen reader / semantics label auditing yet.
- No CI/lint-time static analysis yet.

These are natural directions for future versions — contributions and
issues welcome.

## Example

See the [`example/`](example) folder for a full runnable demo with both
passing and intentionally-failing cases.

## Contributing

Issues and pull requests are welcome. Please include a test for any
bug fix or new feature.

## License

MIT — see [LICENSE](LICENSE).
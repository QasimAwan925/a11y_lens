## 0.2.0

- New: tap an issue in the A11yLens report panel to scroll straight to
  the offending widget and see it flash amber — no more hunting through
  the screen to find which element a report line refers to.
- New: ContrastGuard and TapTargetGuard both take an optional
  label parameter for a human-readable description in the report
  (e.g. label: `Welcome banner title`) shown alongside the id.
- A11yIssue gained anchorKey and onLocate fields powering the
  above; both are populated automatically by the guard widgets.

## 0.1.3

- Fix: `README FILE`.


## 0.1.1

- Fix: `ContrastGuard` could trigger "setState() called during build" when
  a violation was detected, because it reported to the registry
  synchronously in `initState`. Reporting is now deferred to a
  post-frame callback, matching `TapTargetGuard`.
- Fix: the report button in `A11yLens` used `showModalBottomSheet`, which
  requires a `Navigator` ancestor — but `A11yLens` typically sits outside
  the app's `Navigator` (it wraps `MaterialApp.builder`'s output), so
  this threw "Navigator operation requested with a context that does
  not include a Navigator." Replaced with a self-contained panel that
  needs no Navigator.

## 0.1.0## 0.1.2

- Fix: replaced deprecated `Color.red`/`.green`/`.blue` (0–255 int)
  getters with the current `.r`/`.g`/`.b` (0.0–1.0 double) getters in
  `ContrastChecker.luminance`. Raised the minimum Flutter SDK constraint
  to `3.27.0` accordingly, since older SDKs don't have these getters.

## 0.1.1

- Fix: `ContrastGuard` could trigger "setState() called during build" when
  a violation was detected, because it reported to the registry
  synchronously in `initState`. Reporting is now deferred to a
  post-frame callback, matching `TapTargetGuard`.
- Fix: the report button in `A11yLens` used `showModalBottomSheet`, which
  requires a `Navigator` ancestor — but `A11yLens` typically sits outside
  the app's `Navigator` (it wraps `MaterialApp.builder`'s output), so
  this threw "Navigator operation requested with a context that does
  not include a Navigator." Replaced with a self-contained panel that
  needs no Navigator.

## 0.1.0

- Initial release.
- `ContrastChecker` — WCAG contrast ratio calculation and AA/AAA pass checks.
- `TapTargetChecker` — minimum tap target size validation (48x48).
- `ContrastGuard` and `TapTargetGuard` — debug-only widgets that visually
  flag violations and report them to a live registry. Zero-cost in
  release/profile builds.
- `A11yLens` — floating overlay widget showing a live accessibility
  issue report.
- Example app demonstrating passing and intentionally-failing cases.

- Initial release.
- `ContrastChecker` — WCAG contrast ratio calculation and AA/AAA pass checks.
- `TapTargetChecker` — minimum tap target size validation (48x48).
- `ContrastGuard` and `TapTargetGuard` — debug-only widgets that visually
  flag violations and report them to a live registry. Zero-cost in
  release/profile builds.
- `A11yLens` — floating overlay widget showing a live accessibility
  issue report.
- Example app demonstrating passing and intentionally-failing cases.

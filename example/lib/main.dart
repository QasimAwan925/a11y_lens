import 'package:a11y_lens/a11y_lens.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'a11y_lens example',
      // Wrap the whole app to get the floating live-report button.
      builder: (context, child) => A11yLens(child: child ?? const SizedBox()),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('a11y_lens demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tap the floating button (bottom right) to see the live '
                'accessibility report. This screen intentionally includes a '
                'couple of violations to demonstrate detection. Tap an issue '
                'in the report to scroll to it and see it flash amber.',
          ),
          const SizedBox(height: 24),
          const Text('Contrast checks',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Passing example.
          ContrastGuard(
            id: 'good_contrast_text',
            label: 'Good contrast example text',
            foreground: Colors.black,
            background: Colors.white,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: const Text('This text has good contrast.'),
            ),
          ),
          const SizedBox(height: 12),

          // Intentional violation.
          ContrastGuard(
            id: 'bad_contrast_text',
            label: 'Poor contrast example text',
            foreground: const Color(0xFFBBBBBB),
            background: const Color(0xFFAAAAAA),
            child: Container(
              color: const Color(0xFFAAAAAA),
              padding: const EdgeInsets.all(12),
              child: const Text(
                'This text has poor contrast (flagged in red).',
                style: TextStyle(color: Color(0xFFBBBBBB)),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Tap target checks',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Passing example: 48x48.
          TapTargetGuard(
            id: 'good_tap_target',
            label: 'Thumbs-up button (48x48)',
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Intentional violation: 24x24.
          TapTargetGuard(
            id: 'bad_tap_target',
            label: 'Close button (too small)',
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: const Icon(Icons.close, size: 16),
              ),
            ),
          ),

          // Extra spacing so there's real distance to scroll through
          // when using tap-to-locate from the report panel.
          const SizedBox(height: 600),
          const Text(
            'If you scrolled here by tapping an issue in the report, '
                'tap-to-locate is working correctly!',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
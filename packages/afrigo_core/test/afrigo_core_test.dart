import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afrigo_core/afrigo_core.dart';

// Note: AfrigoTheme.light() is not exercised here because it eagerly builds
// a TextTheme via google_fonts, which tries to fetch Tajawal/Manrope over
// the network — flaky/unavailable in a sandboxed test runner. It is
// exercised instead by each app's own widget tests, which run with real
// network access.
void main() {
  test('AfrigoColors exposes the brand primary used across every app', () {
    expect(AfrigoColors.green500, const Color(0xFF2AA35C));
    expect(AfrigoColors.error, const Color(0xFFDC2626));
  });

  test('StatusBadge accepts every AfrigoStatus value', () {
    for (final status in AfrigoStatus.values) {
      final widget = StatusBadge(status: status, label: 'x');
      expect(widget.status, status);
    }
  });

  test('AfrigoLogo covers all 4 apps', () {
    for (final app in AfrigoApp.values) {
      final widget = AfrigoLogo(app: app);
      expect(widget.app, app);
    }
  });
}

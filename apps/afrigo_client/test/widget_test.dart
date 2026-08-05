import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afrigo_client/main.dart';

void main() {
  testWidgets('App boots to the Splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AfrigoClientApp()));
    await tester.pump();

    expect(find.text('Afrigo'), findsOneWidget);
    expect(find.text('متابعة ›'), findsOneWidget);
  });

  testWidgets('Splash -> language select -> onboarding -> login flow navigates', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AfrigoClientApp()));
    await tester.pump();

    await tester.tap(find.text('متابعة ›'));
    await tester.pump();
    expect(find.text('اختر لغتك'), findsOneWidget);

    await tester.tap(find.text('متابعة'));
    await tester.pump();
    expect(find.text('تخطي'), findsOneWidget);

    await tester.tap(find.text('تخطي'));
    await tester.pump();
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });
}

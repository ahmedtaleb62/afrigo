import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afrigo_food/main.dart';

void main() {
  testWidgets('App boots to the Splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AfrigoFoodApp()));
    await tester.pump();

    expect(find.text('Afrigo Food — الشركاء'), findsOneWidget);
    expect(find.text('متابعة ›'), findsOneWidget);
  });

  testWidgets('Splash -> login -> signup navigates', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AfrigoFoodApp()));
    await tester.pump();

    await tester.tap(find.text('متابعة ›'));
    await tester.pump();
    expect(find.text('تسجيل دخول المطعم'), findsOneWidget);

    await tester.tap(find.text('إنشاء حساب'));
    await tester.pump();
    expect(find.text('إنشاء حساب مطعم'), findsOneWidget);
  });
}

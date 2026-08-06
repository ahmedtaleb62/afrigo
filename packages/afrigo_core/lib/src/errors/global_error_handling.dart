import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Every network/business error in the app family is already funneled
/// through a curated Arabic message before it reaches a screen (see
/// `friendlyAuthError`, and each app's `_functionErrorMessage`). This
/// covers the other class of error: a genuine bug in a widget's `build()`.
/// Flutter's default `ErrorWidget` is either the "red screen of death" (in
/// debug) or a blank grey box with no text at all (in release) — neither is
/// the "خطأ طبيعي مفهوم" a real user should see. Call once, before
/// `runApp`.
void installFriendlyErrorWidget() {
  ErrorWidget.builder = (details) {
    if (kDebugMode) return ErrorWidget(details.exception);
    return const _FriendlyErrorScreen();
  };
}

class _FriendlyErrorScreen extends StatelessWidget {
  const _FriendlyErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('حدث خطأ غير متوقع', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'أعد فتح التطبيق، وإذا استمرت المشكلة تواصل مع الدعم.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C)),
            ),
          ],
        ),
      ),
    );
  }
}

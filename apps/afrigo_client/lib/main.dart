import 'dart:io' show Platform;

import 'package:afrigo_core/afrigo_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app_root.dart';
import 'src/core/env.dart';
import 'src/state/client_flow_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installFriendlyErrorWidget();
  // iOS only: skip Firebase entirely until GoogleService-Info.plist exists
  // (Android's google-services.json equivalent — not added yet). This
  // isn't optional the way the try/catch below implies: on iOS, the native
  // Firebase SDK calls `fatalError`/raises an uncatchable native exception
  // when it can't find the plist, which crashes the whole process before
  // Dart's try/catch ever runs — this exact crash shipped to TestFlight.
  // Remove this guard once the real plist is added for this app.
  if (!Platform.isIOS) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Non-fatal on Android — push notifications degrade to "not
      // registered" and every Realtime-backed feature keeps working
      // regardless (see `PushNotifications.register`'s doc comment).
    }
  }
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
  // The new design has no app-bar chrome anywhere — every screen's own
  // background is meant to run edge-to-edge, flush with the very top of the
  // phone. Without this, Android paints its own default status-bar scrim
  // (a distinct grey strip) above every screen. Dark icons is the right
  // default since most screens are white/light; the 3 dark-hero screens
  // (splash/login/signup) override this locally via `AnnotatedRegion`.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const ProviderScope(child: AfrigoClientApp()));
}

class AfrigoClientApp extends ConsumerWidget {
  const AfrigoClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `settingsLang` ('ar'/'fr') already persists to `profiles.language_pref`
    // (see `ClientFlowController.setSettingsLang`) — reusing it here as the
    // single source of truth for the app's actual `Locale`/`Directionality`
    // means the home screen's language toggle (and the settings screen's)
    // now really do switch the whole app, not just record a preference.
    final lang = ref.watch(clientFlowControllerProvider.select((s) => s.settingsLang));
    final locale = Locale(lang);
    return MaterialApp(
      title: 'Afrigo',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AfrigoLocalizations.supportedLocales,
      localizationsDelegates: AfrigoLocalizations.localizationsDelegates,
      theme: AfrigoTheme.light(locale: lang == 'fr' ? AfrigoLocale.fr : AfrigoLocale.ar),
      builder: (context, child) => Directionality(textDirection: lang == 'fr' ? TextDirection.ltr : TextDirection.rtl, child: child!),
      home: const AppRoot(),
    );
  }
}

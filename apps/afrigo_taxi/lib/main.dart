import 'package:afrigo_core/afrigo_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app_root.dart';
import 'src/core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Non-fatal — push notifications degrade to "not registered" and every
    // Realtime-backed feature keeps working regardless (see
    // `PushNotifications.register`'s doc comment). Keeps a missing/broken
    // `google-services.json` from ever blocking the app from starting.
  }
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
  // The new design has no app-bar chrome anywhere — every screen's own
  // background is meant to run edge-to-edge, flush with the very top of the
  // phone. Without this, Android paints its own default status-bar scrim
  // (a distinct grey strip) above every screen. Dark icons is the right
  // default since most screens are white/light; the dark-hero screens
  // (splash/login/signup) override this locally via `AnnotatedRegion`.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const ProviderScope(child: AfrigoTaxiApp()));
}

class AfrigoTaxiApp extends StatelessWidget {
  const AfrigoTaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afrigo Taxi',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: AfrigoLocalizations.supportedLocales,
      localizationsDelegates: AfrigoLocalizations.localizationsDelegates,
      theme: AfrigoTheme.light(locale: AfrigoLocale.ar),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const AppRoot(),
    );
  }
}

import 'package:afrigo_core/afrigo_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app_root.dart';
import 'src/core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installFriendlyErrorWidget();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Non-fatal — push notifications degrade to "not registered" and every
    // Realtime-backed feature keeps working regardless (see
    // `PushNotifications.register`'s doc comment). Keeps a missing/broken
    // `google-services.json` from ever blocking the app from starting —
    // this app doesn't have one registered in the Firebase project yet.
  }
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
  runApp(const ProviderScope(child: AfrigoLivreurApp()));
}

class AfrigoLivreurApp extends StatelessWidget {
  const AfrigoLivreurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afrigo Livreur',
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

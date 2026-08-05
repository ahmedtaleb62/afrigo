import 'package:afrigo_core/afrigo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app_root.dart';
import 'src/core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
  runApp(const ProviderScope(child: AfrigoFoodApp()));
}

class AfrigoFoodApp extends StatelessWidget {
  const AfrigoFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afrigo Food',
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

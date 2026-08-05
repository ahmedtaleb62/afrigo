/// Build-time config. Defaults point at the real "Afrigo DB" Supabase
/// project so `flutter run` works with no extra flags; override with
/// `--dart-define=SUPABASE_URL=...` (see `.env.example`) for another
/// environment.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ecbxpcxjfvlobduapctu.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjYnhwY3hqZnZsb2JkdWFwY3R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2ODIyMjcsImV4cCI6MjA4NzI1ODIyN30.g5w8-pRwNsOoVpAr1zEFs_5jGs1-aEgb3F8NYGFMp_s',
  );

  /// No real support desk/phone line exists for this project yet — this is
  /// a placeholder so the support screen's buttons actually do something
  /// instead of being dead `onPressed: () {}` handlers. Override with
  /// `--dart-define=SUPPORT_PHONE=...` once a real number exists.
  static const supportPhone = String.fromEnvironment('SUPPORT_PHONE', defaultValue: '+22245000000');
}

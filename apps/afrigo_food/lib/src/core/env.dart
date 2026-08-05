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

  /// WhatsApp number the wallet screen's شحن/سحب buttons open a chat with —
  /// no real payment gateway exists, so topping up/withdrawing balance is a
  /// manual admin action requested over WhatsApp.
  static const supportPhone = String.fromEnvironment('SUPPORT_PHONE', defaultValue: '+22245000000');
}

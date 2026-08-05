/// Build-time config. Defaults point at the real "Afrigo DB" Supabase
/// project so `npm run dev` works with no extra setup; override via a
/// `.env` file (see `.env.example`) for another environment.
export const env = {
  supabaseUrl: import.meta.env.VITE_SUPABASE_URL ?? 'https://ecbxpcxjfvlobduapctu.supabase.co',
  supabaseAnonKey:
    import.meta.env.VITE_SUPABASE_ANON_KEY ??
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjYnhwY3hqZnZsb2JkdWFwY3R1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE2ODIyMjcsImV4cCI6MjA4NzI1ODIyN30.g5w8-pRwNsOoVpAr1zEFs_5jGs1-aEgb3F8NYGFMp_s',
}

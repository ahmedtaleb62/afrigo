-- Lets provider apps watch `commission_settings` live instead of fetching
-- it once at login. The Taxi app's Wallet screen shows "نسبة العمولة" —
-- until now that was a one-time read (`_fetchCommissionPct`), so an admin
-- changing the rate mid-session in `CommissionSettingsPage` wouldn't reach
-- an already-logged-in driver until their next login. RLS still applies —
-- `commission_settings_select_authenticated` already lets any authenticated
-- user read every row (it's not owner-scoped data), so this doesn't widen
-- access, just makes the existing read live.
alter publication supabase_realtime add table public.commission_settings;

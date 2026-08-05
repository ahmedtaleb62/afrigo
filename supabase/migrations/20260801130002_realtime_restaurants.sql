-- Afrigo Food screens 64 (Pending Approval / Rejected) watch their own
-- `restaurants` row's status live, same pattern as vehicles in
-- 20260801120001_realtime_vehicles_wallets.sql.
alter publication supabase_realtime add table public.restaurants;

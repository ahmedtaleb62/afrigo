-- Lets clients subscribe (via Supabase Realtime `postgres_changes`/`.stream()`)
-- to their own row's changes. RLS still applies to realtime — a user only
-- ever receives change events for rows their own SELECT policy allows them
-- to see, so this does not widen access.
--
-- Needed by:
--  - Afrigo Taxi screens 49/50 (Pending Approval / Rejected) watching their
--    own `vehicles` row's `status`.
--  - Afrigo Taxi screen 51/52 (Home) watching their own `wallets.balance`
--    live as commission gets deducted.
alter publication supabase_realtime add table public.vehicles;
alter publication supabase_realtime add table public.wallets;

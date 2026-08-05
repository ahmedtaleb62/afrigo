-- Fixes a real bug: `submitVehicleDocs` (Taxi/Food/Livreur apps) did a
-- plain INSERT with no check for an existing row, so re-submitting vehicle
-- docs (e.g. after a rejection, or just re-testing) silently created a
-- second `vehicles` row for the same owner+service_type instead of
-- replacing the first. `toggle-online-status`'s `.maybeSingle()` lookup
-- errors out (returns no row, not an ambiguous one) the moment more than
-- one row matches — surfaced to the driver as "لا توجد مركبة مرتبطة بهذا
-- الحساب" (no vehicle linked to this account) even though a verified
-- vehicle existed, just duplicated. One production account had already
-- accumulated 3 rows this way before this migration (cleaned up manually).
--
-- This constraint makes that state impossible going forward; the
-- accompanying app fix changes the INSERT to an UPSERT keyed on this same
-- (owner_id, service_type) pair.
alter table public.vehicles
  add constraint vehicles_owner_service_unique unique (owner_id, service_type);

-- Same class of bug, same fix: `submitRestaurantDocs` (Food app) also does
-- a plain INSERT with no existing-row check. No `restaurants` rows exist
-- yet in production, so this is a preventive constraint, not a cleanup.
alter table public.restaurants
  add constraint restaurants_owner_unique unique (owner_id);

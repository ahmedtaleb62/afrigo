-- Adds plain numeric lat/lng columns alongside `pickup_location`/
-- `dropoff_location` (PostGIS `geography(Point)`). Those geography columns
-- are what `find_nearby_vehicles` etc. actually need for spatial matching,
-- but PostgREST has no way to ask for `st_x`/`st_y` extraction in a
-- `select()` call — a client reading a `rides` row back gets an opaque WKB
-- blob for the location, not usable coordinates. The Taxi driver app needs
-- real lat/lng to show a real map (pickup pin, live tracking) instead of
-- the placeholder grid it's had until now — plain columns populated once at
-- insert time (see `_shared/orders.ts`'s `createRide`) sidestep the
-- PostgREST/PostGIS gap with zero query-time cost.
alter table public.rides
  add column pickup_lat double precision,
  add column pickup_lng double precision,
  add column dropoff_lat double precision,
  add column dropoff_lng double precision;

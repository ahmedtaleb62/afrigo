-- Bug: find_nearby_vehicles never checked profiles.is_suspended, so a
-- suspended driver stayed fully matchable (kept receiving ride offers) as
-- long as their vehicle row was still is_online = true. admin-suspend-user
-- now forces is_online false the moment someone is suspended, but this
-- closes the gap for good — a suspended owner is excluded from matching
-- regardless of their vehicle's online flag.
create or replace function public.find_nearby_vehicles(
  p_pickup extensions.geography,
  p_service_type public.vehicle_service_type,
  p_radius_m integer default 3000
)
returns table (owner_id uuid, vehicle_id uuid, distance_m double precision)
language sql
security definer
stable
set search_path = public, extensions
as $$
  select v.owner_id, v.id as vehicle_id, ST_Distance(v.current_location, p_pickup) as distance_m
  from public.vehicles v
  join public.wallets w on w.owner_id = v.owner_id
  join public.profiles p on p.id = v.owner_id
  where v.service_type = p_service_type
    and v.status = 'verified'
    and v.is_online = true
    and v.current_location is not null
    and ST_DWithin(v.current_location, p_pickup, p_radius_m)
    and w.balance > w.low_balance_threshold
    and p.is_suspended = false
  order by distance_m asc
  limit 10;
$$;

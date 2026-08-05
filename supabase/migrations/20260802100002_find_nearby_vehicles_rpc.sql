-- Backs `request-ride`/`request-delivery`'s PostGIS matching step. Kept as
-- SQL (not hand-rolled in the Edge Function) so the geo query runs inside
-- Postgres where the GIST index on `vehicles.current_location` actually
-- gets used, instead of pulling all online vehicles over the wire.
--
-- SECURITY DEFINER + execute revoked from public/authenticated: a regular
-- user must never be able to enumerate other drivers' live locations
-- directly — only a service-role Edge Function (after its own auth +
-- business-rule checks) may call this.
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
  where v.service_type = p_service_type
    and v.status = 'verified'
    and v.is_online = true
    and v.current_location is not null
    and ST_DWithin(v.current_location, p_pickup, p_radius_m)
    and w.balance > w.low_balance_threshold
  order by distance_m asc
  limit 10;
$$;

revoke all on function public.find_nearby_vehicles(extensions.geography, public.vehicle_service_type, integer) from public;
grant execute on function public.find_nearby_vehicles(extensions.geography, public.vehicle_service_type, integer) to service_role;

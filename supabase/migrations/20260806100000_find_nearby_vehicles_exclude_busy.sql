-- Bug: find_nearby_vehicles never excluded a driver/courier already on an
-- active order — accepting a ride/delivery only ever sets driver_id/
-- livreur_id + status on the *order* row, nothing on `vehicles` ever marked
-- them "busy". So an on-trip driver kept consuming one of the 10
-- nearest-match slots and kept getting pushed offers they could never act
-- on (the Taxi app's own `_showIncomingRideOffer` already drops these
-- client-side — this closes the same gap server-side, at the source,
-- rather than relying on every client to self-police). Meaningful in a
-- low-driver-density market like Nouakchott where a few busy drivers
-- crowding out the top-10 nearest can measurably hurt matching.
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
    and not exists (
      select 1 from public.rides r
      where r.driver_id = v.owner_id
        and r.status in ('accepted', 'driver_arriving', 'in_progress')
    )
    and not exists (
      select 1 from public.delivery_requests d
      where d.livreur_id = v.owner_id
        and d.status in ('accepted', 'picked_up')
    )
    and not exists (
      select 1 from public.food_orders fo
      where fo.livreur_id = v.owner_id
        and fo.status = 'out_for_delivery'
    )
  order by distance_m asc
  limit 10;
$$;

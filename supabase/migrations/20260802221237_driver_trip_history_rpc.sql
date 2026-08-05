-- driver_trip_history() — backs the Taxi app's Trip History screen and the
-- Home screen's "رحلات اليوم"/"أرباح اليوم" cards. A plain
-- `.from('rides').select('*, profiles(...)')` from the driver's own app
-- can't embed the client's name: `profiles_select_own_or_admin` only lets a
-- caller read their own row (or admin's), and the driver is neither for
-- the client's row — same gap `get_order_counterpart` closes for a single
-- *active* order, but there's no bulk equivalent for trip history yet.
-- SECURITY DEFINER, and scoped to `driver_id = auth.uid()` internally
-- (never a caller-supplied filter) so a driver can only ever see their own
-- trips, never anyone else's.
create or replace function public.driver_trip_history(p_limit int default 50)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_caller uuid := auth.uid();
  v_result jsonb;
begin
  if v_caller is null then
    return '[]'::jsonb;
  end if;

  with recent as (
    select r.id, p.full_name as client_name, r.price, r.distance_km, r.status, r.created_at, r.completed_at
    from rides r
    join profiles p on p.id = r.client_id
    where r.driver_id = v_caller
    order by r.created_at desc
    limit p_limit
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', id, 'client_name', client_name, 'price', price, 'distance_km', distance_km,
    'status', status, 'created_at', created_at, 'completed_at', completed_at
  ) order by created_at desc), '[]'::jsonb) into v_result
  from recent;

  return v_result;
end;
$$;

revoke all on function public.driver_trip_history(int) from public;
grant execute on function public.driver_trip_history(int) to authenticated;

-- `get_order_counterpart`'s food_order branch always returned the owner's
-- own account phone as `restaurant_phone`. The new سياسة المطعم screen lets
-- an owner set a dedicated client-facing support number
-- (`restaurants.contact_phone`) that should be preferred, falling back to
-- the owner's account phone only when it hasn't been set.
create or replace function public.get_order_counterpart(p_order_type public.order_type, p_order_id uuid)
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_caller uuid := auth.uid();
  v_client_id uuid;
  v_counterpart_id uuid;
  v_result jsonb;
begin
  if v_caller is null then
    return null;
  end if;

  if p_order_type = 'ride' then
    select client_id, driver_id into v_client_id, v_counterpart_id
    from rides where id = p_order_id and (client_id = v_caller or driver_id = v_caller);
    if v_client_id is null then return null; end if;

    if v_caller = v_client_id then
      -- caller is the client -> return the driver's info
      select jsonb_build_object(
        'full_name', p.full_name, 'phone', p.phone,
        'vehicle_name', v.vehicle_name, 'vehicle_plate', v.plate_number, 'car_type', v.car_type
      ) into v_result
      from profiles p
      left join vehicles v on v.owner_id = p.id and v.service_type = 'taxi'
      where p.id = v_counterpart_id;
    else
      -- caller is the driver -> return the client's info
      select jsonb_build_object('full_name', p.full_name, 'phone', p.phone) into v_result
      from profiles p where p.id = v_client_id;
    end if;

  elsif p_order_type = 'delivery_request' then
    select client_id, livreur_id into v_client_id, v_counterpart_id
    from delivery_requests where id = p_order_id and (client_id = v_caller or livreur_id = v_caller);
    if v_client_id is null then return null; end if;

    if v_caller = v_client_id then
      select jsonb_build_object(
        'full_name', p.full_name, 'phone', p.phone,
        'vehicle_name', v.vehicle_name, 'vehicle_plate', v.plate_number, 'car_type', v.car_type
      ) into v_result
      from profiles p
      left join vehicles v on v.owner_id = p.id and v.service_type = 'delivery'
      where p.id = v_counterpart_id;
    else
      select jsonb_build_object('full_name', p.full_name, 'phone', p.phone) into v_result
      from profiles p where p.id = v_client_id;
    end if;

  elsif p_order_type = 'food_order' then
    -- food orders have two possible counterparts (restaurant, then later
    -- livreur), so this branch doesn't use the single v_counterpart_id var.
    declare
      v_restaurant_id uuid;
      v_livreur_id uuid;
    begin
      select restaurant_id, livreur_id into v_restaurant_id, v_livreur_id
      from food_orders where id = p_order_id and client_id = v_caller;
      if v_restaurant_id is null then return null; end if;
      select jsonb_build_object(
        'restaurant_name', r.name, 'restaurant_phone', coalesce(r.contact_phone, p_owner.phone),
        'livreur_name', p_livreur.full_name, 'livreur_phone', p_livreur.phone
      ) into v_result
      from restaurants r
      join profiles p_owner on p_owner.id = r.owner_id
      left join profiles p_livreur on p_livreur.id = v_livreur_id
      where r.id = v_restaurant_id;
    end;
  end if;

  return v_result;
end;
$$;

revoke all on function public.get_order_counterpart(public.order_type, uuid) from public;
grant execute on function public.get_order_counterpart(public.order_type, uuid) to authenticated;

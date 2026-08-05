-- Bug: handle_order_completion() inserted `tg_table_name` ('rides',
-- 'food_orders', 'delivery_requests' — the actual, plural, table names)
-- into wallet_transactions.related_order_type, but that column's check
-- constraint only allows the singular order-type values ('ride',
-- 'food_order', 'delivery_request') used everywhere else in the schema.
-- Every completion trigger therefore failed its own INSERT with
-- "violates check constraint wallet_transactions_related_order_type_check",
-- which rolled back the whole triggering UPDATE — so no ride/food_order/
-- delivery_request has ever actually reached 'completed': the status
-- write itself was silently undone, no commission was ever deducted, and
-- update-order-status returned a 500 the client swallowed into
-- state.actionError without surfacing it. Map tg_table_name to the
-- singular form before the insert instead of using it directly.
create or replace function public.handle_order_completion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_service_type public.commission_service_type;
  v_related_order_type text;
  v_provider_owner uuid;
  v_amount numeric;
  v_percentage numeric;
  v_commission numeric;
  v_wallet_id uuid;
  v_new_balance numeric;
  v_low_balance_threshold numeric;
begin
  if tg_table_name = 'rides' then
    v_service_type := 'taxi';
    v_related_order_type := 'ride';
    v_provider_owner := new.driver_id;
    v_amount := new.price;
  elsif tg_table_name = 'food_orders' then
    v_service_type := 'food';
    v_related_order_type := 'food_order';
    select owner_id into v_provider_owner from public.restaurants where id = new.restaurant_id;
    v_amount := new.total;
  elsif tg_table_name = 'delivery_requests' then
    v_service_type := 'delivery';
    v_related_order_type := 'delivery_request';
    v_provider_owner := new.livreur_id;
    v_amount := new.price;
  end if;

  if v_provider_owner is null or v_amount is null then
    return new;
  end if;

  select percentage into v_percentage from public.commission_settings where service_type = v_service_type;
  v_commission := round(v_amount * coalesce(v_percentage, 0) / 100, 2);

  select id, low_balance_threshold into v_wallet_id, v_low_balance_threshold
  from public.wallets where owner_id = v_provider_owner;

  if v_wallet_id is null or v_commission <= 0 then
    return new;
  end if;

  update public.wallets set balance = balance - v_commission where id = v_wallet_id
  returning balance into v_new_balance;

  insert into public.wallet_transactions (wallet_id, amount, type, related_order_id, related_order_type, note)
  values (v_wallet_id, -v_commission, 'commission_deduction', new.id, v_related_order_type, 'عمولة ' || v_service_type::text);

  if v_new_balance <= v_low_balance_threshold then
    insert into public.notifications (user_id, title, body, data)
    values (
      v_provider_owner,
      'رصيدك منخفض',
      'رصيدك الحالي ' || v_new_balance || ' أوقية. يرجى شحن رصيدك لمواصلة استقبال الطلبات.',
      jsonb_build_object('balance', v_new_balance)
    );
  end if;

  return new;
end;
$$;

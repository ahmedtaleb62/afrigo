-- Two triggers that together implement "complete-order-and-deduct-commission"
-- as a DB trigger rather than a manual Edge Function call, per the spec's
-- own recommendation ("Trigger أفضل من استدعاء يدوي لضمان عدم التلاعب") —
-- a trigger can't be skipped or called twice by a buggy/malicious client the
-- way an extra Edge Function call could.

-- 1) food_orders/delivery_requests: the design's own UI has no separate
--    "confirm completed" step after "تم التسليم" (delivered) — the provider
--    tapping "delivered" IS the completion. This auto-promotes
--    delivered -> completed in the same write, while still recording
--    delivered_at, so `handle_order_completion()` below (which fires on
--    'completed') is the single place commission deduction happens for
--    every order type.
create or replace function public.auto_complete_on_delivered()
returns trigger
language plpgsql
as $$
begin
  if new.status = 'delivered' and old.status is distinct from 'delivered' then
    new.delivered_at := coalesce(new.delivered_at, now());
    new.status := 'completed';
    new.completed_at := now();
  end if;
  return new;
end;
$$;

create trigger food_orders_auto_complete
  before update on public.food_orders
  for each row execute function public.auto_complete_on_delivered();

create trigger delivery_requests_auto_complete
  before update on public.delivery_requests
  for each row execute function public.auto_complete_on_delivered();

-- 2) Commission deduction — fires once, the moment any of the 3 order
-- tables actually reaches 'completed'. SECURITY DEFINER so it can write
-- wallets/wallet_transactions/notifications regardless of which role
-- performed the triggering UPDATE (RLS has no UPDATE policy on wallets at
-- all — this is the one place balance legitimately decreases on its own).
create or replace function public.handle_order_completion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_service_type public.commission_service_type;
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
    v_provider_owner := new.driver_id;
    v_amount := new.price;
  elsif tg_table_name = 'food_orders' then
    v_service_type := 'food';
    select owner_id into v_provider_owner from public.restaurants where id = new.restaurant_id;
    v_amount := new.total;
  elsif tg_table_name = 'delivery_requests' then
    v_service_type := 'delivery';
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
  values (v_wallet_id, -v_commission, 'commission_deduction', new.id, tg_table_name, 'عمولة ' || v_service_type::text);

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

create trigger rides_deduct_commission
  after update of status on public.rides
  for each row
  when (new.status = 'completed' and old.status is distinct from 'completed')
  execute function public.handle_order_completion();

create trigger food_orders_deduct_commission
  after update of status on public.food_orders
  for each row
  when (new.status = 'completed' and old.status is distinct from 'completed')
  execute function public.handle_order_completion();

create trigger delivery_requests_deduct_commission
  after update of status on public.delivery_requests
  for each row
  when (new.status = 'completed' and old.status is distinct from 'completed')
  execute function public.handle_order_completion();

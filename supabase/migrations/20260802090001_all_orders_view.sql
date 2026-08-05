-- Unified orders view for the Admin panel's Orders screen (87) — spec calls
-- for "استعلام UNION أو View مجمّعة all_orders_view" rather than the client
-- querying 3 tables and merging them itself.
--
-- `security_invoker = true` is required (Postgres 15+/Supabase default is
-- security_definer-like view-owner permissions otherwise): without it this
-- view would run as the view's *owner* and silently bypass the RLS on
-- rides/food_orders/delivery_requests for every caller. With it, a client
-- querying this view still only sees their own rows (client_id = auth.uid()
-- per each table's existing SELECT policy) and only admins see everything.
create view public.all_orders_view
with (security_invoker = true)
as
  select
    id,
    'ride'::text as order_type,
    client_id,
    driver_id as provider_id,
    price,
    status::text as status,
    created_at
  from public.rides
  union all
  select
    id,
    'food_order'::text,
    client_id,
    restaurant_id as provider_id,
    total as price,
    status::text,
    created_at
  from public.food_orders
  union all
  select
    id,
    'delivery_request'::text,
    client_id,
    livreur_id as provider_id,
    price,
    status::text,
    created_at
  from public.delivery_requests;

grant select on public.all_orders_view to authenticated;

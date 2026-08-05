create table public.food_orders (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles (id),
  restaurant_id uuid not null references public.restaurants (id),
  livreur_id uuid references public.profiles (id),
  items jsonb not null,
  subtotal numeric(10, 2) not null,
  delivery_fee numeric(10, 2) not null default 0,
  total numeric(10, 2) not null,
  distance_km numeric(8, 2),
  delivery_address text not null,
  delivery_location extensions.geography(Point, 4326) not null,
  client_note text,
  status public.food_order_status not null default 'pending_restaurant',
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  rejected_at timestamptz,
  preparing_at timestamptz,
  ready_at timestamptz,
  out_for_delivery_at timestamptz,
  delivered_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz
);

create index food_orders_client_id_idx on public.food_orders (client_id);
create index food_orders_restaurant_id_idx on public.food_orders (restaurant_id);
create index food_orders_livreur_id_idx on public.food_orders (livreur_id);
create index food_orders_status_idx on public.food_orders (status);
create index food_orders_delivery_location_gix on public.food_orders using gist (delivery_location);

alter table public.food_orders enable row level security;

-- Read-only from the client's perspective; all writes go through
-- service-role Edge Functions (request-food-order, respond-to-order,
-- update-order-status), same reasoning as `rides`.
create policy "food_orders_select_participants_or_admin"
  on public.food_orders for select
  to authenticated
  using (
    client_id = auth.uid()
    or livreur_id = auth.uid()
    or public.is_admin()
    or exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id and r.owner_id = auth.uid()
    )
  );

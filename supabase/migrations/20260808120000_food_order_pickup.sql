-- Lets a client choose pickup instead of delivery for a food order — was
-- previously delivery-only, no way to skip the livreur leg and the
-- delivery fee even when the client is happy to collect it themselves.
alter table public.food_orders
  add column is_pickup boolean not null default false;

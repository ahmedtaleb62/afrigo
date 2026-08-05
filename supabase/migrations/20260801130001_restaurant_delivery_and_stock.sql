-- Afrigo Food's Menu Management (screen 67) and Delivery Settings screen
-- need a few operational fields the original table spec didn't include.
-- Both are plain owner-editable attributes already covered by the existing
-- RLS policies on `restaurants` / `restaurant_dishes` (owner-or-admin) —
-- no policy changes needed, just new columns.

alter table public.restaurants
  add column delivery_method text not null default 'afrigo'
    check (delivery_method in ('afrigo', 'own', 'pickup')),
  add column delivery_fee numeric(10, 2) not null default 0,
  add column min_order numeric(10, 2) not null default 0,
  add column prep_time_minutes text;

alter table public.restaurant_dishes
  add column available_for_delivery boolean not null default true,
  add column stock_quantity integer not null default 20 check (stock_quantity >= 0);

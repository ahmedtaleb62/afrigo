create table public.commission_settings (
  service_type public.commission_service_type primary key,
  percentage numeric(5, 2) not null check (percentage >= 0 and percentage <= 100)
);

alter table public.commission_settings enable row level security;

create policy "commission_settings_select_authenticated"
  on public.commission_settings for select
  to authenticated
  using (true);

create policy "commission_settings_write_admin"
  on public.commission_settings for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Seed defaults so calculate-fare / complete-order-and-deduct-commission
-- have something to read before an admin configures real values.
insert into public.commission_settings (service_type, percentage) values
  ('taxi', 15),
  ('food', 20),
  ('delivery', 15);

--------------------------------------------------------------------------
-- pricing_settings
--------------------------------------------------------------------------
create table public.pricing_settings (
  service_type public.commission_service_type primary key,
  base_fare numeric(10, 2) not null check (base_fare >= 0),
  price_per_km numeric(10, 2) not null check (price_per_km >= 0),
  price_per_min numeric(10, 2) not null check (price_per_min >= 0),
  updated_at timestamptz not null default now()
);

create trigger set_pricing_settings_updated_at
  before update on public.pricing_settings
  for each row execute function public.set_updated_at();

alter table public.pricing_settings enable row level security;

create policy "pricing_settings_select_authenticated"
  on public.pricing_settings for select
  to authenticated
  using (true);

create policy "pricing_settings_write_admin"
  on public.pricing_settings for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

insert into public.pricing_settings (service_type, base_fare, price_per_km, price_per_min) values
  ('taxi', 50, 15, 2),
  ('food', 30, 12, 0),
  ('delivery', 40, 15, 0);

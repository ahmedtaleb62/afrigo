create table public.platform_settings (
  key text primary key,
  value jsonb not null
);

alter table public.platform_settings enable row level security;

create policy "platform_settings_select_authenticated"
  on public.platform_settings for select
  to authenticated
  using (true);

create policy "platform_settings_write_admin"
  on public.platform_settings for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

-- Seed the keys screen 91 (platform settings form) edits, so it has
-- something to load on first render.
insert into public.platform_settings (key, value) values
  ('support_phone', '""'::jsonb),
  ('terms_and_conditions_ar', '""'::jsonb),
  ('terms_and_conditions_fr', '""'::jsonb),
  ('provider_search_radius_km', '3'::jsonb),
  ('order_acceptance_timeout_seconds', '20'::jsonb);

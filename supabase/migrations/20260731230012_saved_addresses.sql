create table public.saved_addresses (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles (id) on delete cascade,
  label public.address_label not null,
  address text not null,
  location extensions.geography(Point, 4326) not null
);

create index saved_addresses_client_id_idx on public.saved_addresses (client_id);
create index saved_addresses_location_gix on public.saved_addresses using gist (location);

alter table public.saved_addresses enable row level security;

-- Fully owner-managed (screens 41-ish: manage home/work/other addresses).
create policy "saved_addresses_select_own_or_admin"
  on public.saved_addresses for select
  to authenticated
  using (client_id = auth.uid() or public.is_admin());

create policy "saved_addresses_write_own"
  on public.saved_addresses for insert
  to authenticated
  with check (client_id = auth.uid());

create policy "saved_addresses_update_own"
  on public.saved_addresses for update
  to authenticated
  using (client_id = auth.uid())
  with check (client_id = auth.uid());

create policy "saved_addresses_delete_own"
  on public.saved_addresses for delete
  to authenticated
  using (client_id = auth.uid());

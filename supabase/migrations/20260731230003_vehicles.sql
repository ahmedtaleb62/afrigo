-- NOTE: `is_online`, `current_location` and `location_updated_at` are not in
-- the original table spec, but are required for the PostGIS proximity
-- search in the `request-ride` / `request-delivery` Edge Functions
-- (`ST_DWithin(location, pickup_point, radius) ... AND is_online = true`).
-- They live here (one row per verified provider) rather than on `profiles`,
-- since a provider only has a live location while they have a verified
-- vehicle for that service type.
create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  service_type public.vehicle_service_type not null,
  vehicle_name text not null,
  address text not null,
  driving_license_url text not null,
  car_type text not null,
  plate_number text not null,
  notes text,
  status public.verification_status not null default 'pending',
  rejection_reason text,
  reviewed_by uuid references public.profiles (id),
  reviewed_at timestamptz,
  is_online boolean not null default false,
  current_location extensions.geography(Point, 4326),
  location_updated_at timestamptz,
  created_at timestamptz not null default now()
);

create index vehicles_owner_id_idx on public.vehicles (owner_id);
create index vehicles_status_idx on public.vehicles (status);
create index vehicles_service_type_idx on public.vehicles (service_type);
create index vehicles_online_lookup_idx on public.vehicles (service_type, status, is_online);
create index vehicles_current_location_gix on public.vehicles using gist (current_location);

-- Guards `status`/`rejection_reason`/`reviewed_by`/`reviewed_at`/`is_online`
-- so only a service-role Edge Function (review-verification,
-- toggle-online-status) can change them — never the owner directly. Also
-- auto-resets a verified/rejected vehicle back to `pending` when the owner
-- edits any of its substantive fields (screen 60: "إعادة تقديم").
create or replace function public.vehicles_guard()
returns trigger
language plpgsql
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;

  if tg_op = 'INSERT' then
    new.status := 'pending';
    new.rejection_reason := null;
    new.reviewed_by := null;
    new.reviewed_at := null;
    new.is_online := false;
    return new;
  end if;

  if new.status is distinct from old.status
     or new.rejection_reason is distinct from old.rejection_reason
     or new.reviewed_by is distinct from old.reviewed_by
     or new.reviewed_at is distinct from old.reviewed_at
     or new.is_online is distinct from old.is_online then
    raise exception 'vehicles: status/rejection_reason/reviewed_by/reviewed_at/is_online can only be changed by a service-role Edge Function';
  end if;

  if old.status in ('verified', 'rejected') and (
    new.vehicle_name is distinct from old.vehicle_name or
    new.address is distinct from old.address or
    new.driving_license_url is distinct from old.driving_license_url or
    new.car_type is distinct from old.car_type or
    new.plate_number is distinct from old.plate_number
  ) then
    new.status := 'pending';
    new.rejection_reason := null;
    new.reviewed_by := null;
    new.reviewed_at := null;
  end if;

  return new;
end;
$$;

create trigger vehicles_guard_trigger
  before insert or update on public.vehicles
  for each row execute function public.vehicles_guard();

alter table public.vehicles enable row level security;

create policy "vehicles_select_own_or_admin"
  on public.vehicles for select
  to authenticated
  using (owner_id = auth.uid() or public.is_admin());

create policy "vehicles_insert_own"
  on public.vehicles for insert
  to authenticated
  with check (owner_id = auth.uid());

create policy "vehicles_update_own_or_admin"
  on public.vehicles for update
  to authenticated
  using (owner_id = auth.uid() or public.is_admin())
  with check (owner_id = auth.uid() or public.is_admin());

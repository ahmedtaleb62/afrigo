create table public.rides (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles (id),
  driver_id uuid references public.profiles (id),
  pickup_location extensions.geography(Point, 4326) not null,
  pickup_address text not null,
  dropoff_location extensions.geography(Point, 4326) not null,
  dropoff_address text not null,
  distance_km numeric(8, 2),
  duration_min numeric(8, 2),
  price numeric(10, 2),
  status public.ride_status not null default 'searching',
  client_note text,
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz
);

create index rides_client_id_idx on public.rides (client_id);
create index rides_driver_id_idx on public.rides (driver_id);
create index rides_status_idx on public.rides (status);
create index rides_pickup_location_gix on public.rides using gist (pickup_location);
create index rides_dropoff_location_gix on public.rides using gist (dropoff_location);

alter table public.rides enable row level security;

-- Read-only from the client's perspective for every role, including admin:
-- all writes (create/accept/status transitions/cancel) are state-machine
-- validated in service-role Edge Functions (request-ride, respond-to-order,
-- update-order-status), never as free-form table updates.
create policy "rides_select_participants_or_admin"
  on public.rides for select
  to authenticated
  using (client_id = auth.uid() or driver_id = auth.uid() or public.is_admin());

--------------------------------------------------------------------------
-- ride_locations — optional persisted breadcrumb trail (live tracking
-- itself is a Realtime Broadcast, not a DB write; this table is for
-- reconstructing the route afterwards, e.g. in the admin panel).
--------------------------------------------------------------------------
create table public.ride_locations (
  id uuid primary key default gen_random_uuid(),
  ride_id uuid not null references public.rides (id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  recorded_at timestamptz not null default now()
);

create index ride_locations_ride_id_idx on public.ride_locations (ride_id, recorded_at);

alter table public.ride_locations enable row level security;

create policy "ride_locations_select_participants_or_admin"
  on public.ride_locations for select
  to authenticated
  using (
    exists (
      select 1 from public.rides r
      where r.id = ride_id
        and (r.client_id = auth.uid() or r.driver_id = auth.uid() or public.is_admin())
    )
  );

create policy "ride_locations_insert_assigned_driver"
  on public.ride_locations for insert
  to authenticated
  with check (
    exists (
      select 1 from public.rides r
      where r.id = ride_id and r.driver_id = auth.uid() and r.status = 'in_progress'
    )
  );

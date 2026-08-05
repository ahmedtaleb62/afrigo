create table public.delivery_requests (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles (id),
  livreur_id uuid references public.profiles (id),
  pickup_location extensions.geography(Point, 4326) not null,
  pickup_address text not null,
  dropoff_location extensions.geography(Point, 4326) not null,
  dropoff_address text not null,
  recipient_name text not null,
  recipient_phone text not null,
  package_type text not null,
  package_notes text,
  package_image_url text,
  distance_km numeric(8, 2),
  price numeric(10, 2),
  status public.delivery_status not null default 'searching',
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  picked_up_at timestamptz,
  delivered_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz
);

create index delivery_requests_client_id_idx on public.delivery_requests (client_id);
create index delivery_requests_livreur_id_idx on public.delivery_requests (livreur_id);
create index delivery_requests_status_idx on public.delivery_requests (status);
create index delivery_requests_pickup_location_gix on public.delivery_requests using gist (pickup_location);
create index delivery_requests_dropoff_location_gix on public.delivery_requests using gist (dropoff_location);

alter table public.delivery_requests enable row level security;

-- Read-only from the client's perspective; all writes go through
-- service-role Edge Functions (request-delivery, respond-to-order,
-- update-order-status), same reasoning as `rides`.
create policy "delivery_requests_select_participants_or_admin"
  on public.delivery_requests for select
  to authenticated
  using (client_id = auth.uid() or livreur_id = auth.uid() or public.is_admin());

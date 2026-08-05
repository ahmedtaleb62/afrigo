create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  address text not null,
  location extensions.geography(Point, 4326) not null,
  license_url text not null,
  cuisine_type text not null,
  cover_image_url text,
  logo_url text,
  opening_hours jsonb not null default '{}'::jsonb,
  notes text,
  status public.verification_status not null default 'pending',
  rejection_reason text,
  is_open boolean not null default false,
  created_at timestamptz not null default now()
);

create index restaurants_owner_id_idx on public.restaurants (owner_id);
create index restaurants_status_idx on public.restaurants (status);
create index restaurants_location_gix on public.restaurants using gist (location);

-- Same protection pattern as vehicles_guard(): status/is_open can only
-- change via a service-role Edge Function, and editing substantive fields
-- resets a verified/rejected restaurant back to `pending` (screen 72).
create or replace function public.restaurants_guard()
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
    new.is_open := false;
    return new;
  end if;

  if new.status is distinct from old.status
     or new.rejection_reason is distinct from old.rejection_reason
     or new.is_open is distinct from old.is_open then
    raise exception 'restaurants: status/rejection_reason/is_open can only be changed by a service-role Edge Function';
  end if;

  if old.status in ('verified', 'rejected') and (
    new.name is distinct from old.name or
    new.address is distinct from old.address or
    new.license_url is distinct from old.license_url or
    new.cuisine_type is distinct from old.cuisine_type
  ) then
    new.status := 'pending';
    new.rejection_reason := null;
  end if;

  return new;
end;
$$;

create trigger restaurants_guard_trigger
  before insert or update on public.restaurants
  for each row execute function public.restaurants_guard();

alter table public.restaurants enable row level security;

-- Clients browse verified restaurants (screens 21-30); owners always see
-- their own regardless of status (to track review progress).
create policy "restaurants_select_verified_or_own_or_admin"
  on public.restaurants for select
  to authenticated
  using (status = 'verified' or owner_id = auth.uid() or public.is_admin());

create policy "restaurants_insert_own"
  on public.restaurants for insert
  to authenticated
  with check (owner_id = auth.uid());

create policy "restaurants_update_own_or_admin"
  on public.restaurants for update
  to authenticated
  using (owner_id = auth.uid() or public.is_admin())
  with check (owner_id = auth.uid() or public.is_admin());

--------------------------------------------------------------------------
-- restaurant_dish_categories
--------------------------------------------------------------------------
create table public.restaurant_dish_categories (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  name text not null,
  sort_order integer not null default 0
);

create index restaurant_dish_categories_restaurant_id_idx
  on public.restaurant_dish_categories (restaurant_id);

alter table public.restaurant_dish_categories enable row level security;

create policy "dish_categories_select_visible"
  on public.restaurant_dish_categories for select
  to authenticated
  using (
    exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id
        and (r.status = 'verified' or r.owner_id = auth.uid() or public.is_admin())
    )
  );

create policy "dish_categories_write_own"
  on public.restaurant_dish_categories for all
  to authenticated
  using (
    exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id and (r.owner_id = auth.uid() or public.is_admin())
    )
  )
  with check (
    exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id and (r.owner_id = auth.uid() or public.is_admin())
    )
  );

--------------------------------------------------------------------------
-- restaurant_dishes
--------------------------------------------------------------------------
create table public.restaurant_dishes (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  category_id uuid references public.restaurant_dish_categories (id) on delete set null,
  name text not null,
  description text,
  price numeric(10, 2) not null check (price >= 0),
  image_url text,
  options jsonb not null default '[]'::jsonb,
  is_available boolean not null default true
);

create index restaurant_dishes_restaurant_id_idx on public.restaurant_dishes (restaurant_id);
create index restaurant_dishes_category_id_idx on public.restaurant_dishes (category_id);

alter table public.restaurant_dishes enable row level security;

create policy "dishes_select_visible"
  on public.restaurant_dishes for select
  to authenticated
  using (
    exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id
        and (r.status = 'verified' or r.owner_id = auth.uid() or public.is_admin())
    )
  );

create policy "dishes_write_own"
  on public.restaurant_dishes for all
  to authenticated
  using (
    exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id and (r.owner_id = auth.uid() or public.is_admin())
    )
  )
  with check (
    exists (
      select 1 from public.restaurants r
      where r.id = restaurant_id and (r.owner_id = auth.uid() or public.is_admin())
    )
  );

-- Powers the Client app's "المطاعم القريبة" filters/sort (highest rated,
-- nearest, cheapest/priciest, open/closed) — none of `avg_rating`,
-- `ratings_count`, or a per-request distance existed before this.

-- Denormalized rating aggregate, maintained by a trigger on `ratings`
-- inserts (same reasoning as commission deduction being a trigger: it must
-- stay in sync with every insert, not rely on the app remembering to call
-- something). `ratings` has no UPDATE/DELETE policy for anyone but admin,
-- so an AFTER INSERT trigger is enough — there's no edit-a-rating path to
-- also handle.
alter table public.restaurants
  add column avg_rating numeric(3, 2) not null default 0,
  add column ratings_count integer not null default 0;

create or replace function public.update_restaurant_rating_agg()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.rated_entity_type = 'restaurant' then
    update public.restaurants
    set avg_rating = coalesce((
          select round(avg(rating)::numeric, 2) from public.ratings
          where rated_entity_type = 'restaurant' and rated_entity_id = new.rated_entity_id
        ), 0),
        ratings_count = (
          select count(*) from public.ratings
          where rated_entity_type = 'restaurant' and rated_entity_id = new.rated_entity_id
        )
    where id = new.rated_entity_id;
  end if;
  return new;
end;
$$;

create trigger ratings_update_restaurant_agg
  after insert on public.ratings
  for each row execute function public.update_restaurant_rating_agg();

-- SECURITY DEFINER RPC (same reasoning as `get_order_counterpart`/
-- `can_rate_order`: a pure read, no side effect, needs PostGIS math
-- PostgREST's plain `.select()` can't express) — re-implements the
-- `restaurants_select_verified_or_own_or_admin` policy's "verified" half
-- manually since SECURITY DEFINER bypasses RLS. `p_lat`/`p_lng` is
-- whatever pickup point the client currently has — the placeholder
-- Algiers-center coordinate everywhere else in this app until a real map
-- picker exists (see apps/afrigo_client/README.md), so "nearest" is a real
-- PostGIS distance, just anchored to a placeholder point for now.
create or replace function public.nearby_restaurants(p_lat double precision, p_lng double precision)
returns table (
  id uuid,
  name text,
  cuisine_type text,
  delivery_fee numeric,
  min_order numeric,
  is_open boolean,
  avg_rating numeric,
  ratings_count integer,
  distance_km numeric
)
language sql
stable
security definer
set search_path = public
as $$
  select
    r.id, r.name, r.cuisine_type, r.delivery_fee, r.min_order, r.is_open, r.avg_rating, r.ratings_count,
    round((extensions.ST_Distance(r.location, extensions.ST_SetSRID(extensions.ST_MakePoint(p_lng, p_lat), 4326)::extensions.geography) / 1000)::numeric, 2) as distance_km
  from public.restaurants r
  where r.status = 'verified'
$$;

revoke all on function public.nearby_restaurants(double precision, double precision) from public;
grant execute on function public.nearby_restaurants(double precision, double precision) to authenticated;

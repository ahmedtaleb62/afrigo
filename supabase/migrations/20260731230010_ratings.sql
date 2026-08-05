-- Is `p_rater` allowed to rate `p_order_id`/`p_order_type`? True only once
-- the order is `completed` and the rater was actually a party to it.
-- SECURITY DEFINER so the ratings INSERT policy (below) can call it without
-- granting the caller direct SELECT on rides/food_orders/delivery_requests
-- rows belonging to other users.
create or replace function public.can_rate_order(p_order_id uuid, p_order_type public.order_type, p_rater uuid)
returns boolean
language plpgsql
security definer
stable
set search_path = public
as $$
begin
  if p_order_type = 'ride' then
    return exists (
      select 1 from public.rides
      where id = p_order_id and status = 'completed'
        and (client_id = p_rater or driver_id = p_rater)
    );
  elsif p_order_type = 'food_order' then
    return exists (
      select 1 from public.food_orders fo
      where fo.id = p_order_id and fo.status = 'completed'
        and (
          fo.client_id = p_rater
          or fo.livreur_id = p_rater
          or exists (select 1 from public.restaurants r where r.id = fo.restaurant_id and r.owner_id = p_rater)
        )
    );
  elsif p_order_type = 'delivery_request' then
    return exists (
      select 1 from public.delivery_requests
      where id = p_order_id and status = 'completed'
        and (client_id = p_rater or livreur_id = p_rater)
    );
  end if;
  return false;
end;
$$;

create table public.ratings (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null,
  order_type public.order_type not null,
  rated_by uuid not null references public.profiles (id),
  rated_entity_type public.rated_entity_type not null,
  rated_entity_id uuid not null,
  rating integer not null check (rating between 1 and 5),
  comment text,
  quick_tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  unique (order_id, order_type, rated_by, rated_entity_id)
);

create index ratings_rated_entity_idx on public.ratings (rated_entity_type, rated_entity_id);
create index ratings_order_idx on public.ratings (order_id, order_type);

alter table public.ratings enable row level security;

create policy "ratings_select_involved_or_admin"
  on public.ratings for select
  to authenticated
  using (
    rated_by = auth.uid()
    or rated_entity_id = auth.uid()
    or public.is_admin()
    or (
      rated_entity_type = 'restaurant'
      and exists (select 1 from public.restaurants r where r.id = rated_entity_id and r.owner_id = auth.uid())
    )
  );

create policy "ratings_insert_validated"
  on public.ratings for insert
  to authenticated
  with check (
    rated_by = auth.uid()
    and public.can_rate_order(order_id, order_type, auth.uid())
  );

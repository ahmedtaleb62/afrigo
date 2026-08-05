-- The Overview page's "الإيرادات" (revenue) KPI card and time-series chart
-- summed the *gross* order price/total (what clients paid), which reads to
-- an admin as the platform's own income but is actually total transaction
-- volume most of which belongs to the driver/restaurant/livreur. The
-- platform's real revenue is the commission actually deducted into
-- `wallet_transactions` (type = 'commission_deduction') by
-- handle_order_completion() — switch both to that. "متوسط قيمة الطلب"
-- (average order value) is kept on the gross figure since it's genuinely
-- about order size, not platform income, so a separate `gross` sum is
-- carried alongside the commission-based `revenue`.
create or replace function public.admin_dashboard_stats(p_period text default 'week')
returns jsonb
language plpgsql
security definer
stable
set search_path = public
as $$
declare
  v_bucket text;
  v_buckets int;
  v_result jsonb;
begin
  v_bucket := case p_period when 'day' then 'hour' when 'year' then 'month' else 'day' end;
  v_buckets := case p_period when 'day' then 24 when 'week' then 7 when 'month' then 30 when 'year' then 12 else 7 end;

  with
  revenue_today as (
    select
      coalesce((select sum(-amount) from wallet_transactions where type = 'commission_deduction' and created_at >= date_trunc('day', now())), 0) as revenue,
      coalesce((select sum(price) from rides where status = 'completed' and completed_at >= date_trunc('day', now())), 0)
      + coalesce((select sum(total) from food_orders where status = 'completed' and completed_at >= date_trunc('day', now())), 0)
      + coalesce((select sum(price) from delivery_requests where status = 'completed' and completed_at >= date_trunc('day', now())), 0) as gross,
      (select count(*) from rides where status = 'completed' and completed_at >= date_trunc('day', now()))
      + (select count(*) from food_orders where status = 'completed' and completed_at >= date_trunc('day', now()))
      + (select count(*) from delivery_requests where status = 'completed' and completed_at >= date_trunc('day', now())) as order_count
  ),
  revenue_yesterday as (
    select
      coalesce((select sum(-amount) from wallet_transactions where type = 'commission_deduction' and created_at >= date_trunc('day', now()) - interval '1 day' and created_at < date_trunc('day', now())), 0) as revenue,
      (select count(*) from rides where status = 'completed' and completed_at >= date_trunc('day', now()) - interval '1 day' and completed_at < date_trunc('day', now()))
      + (select count(*) from food_orders where status = 'completed' and completed_at >= date_trunc('day', now()) - interval '1 day' and completed_at < date_trunc('day', now()))
      + (select count(*) from delivery_requests where status = 'completed' and completed_at >= date_trunc('day', now()) - interval '1 day' and completed_at < date_trunc('day', now())) as order_count
  ),
  active_users as (
    select
      (select count(distinct client_id) from rides where created_at >= date_trunc('day', now()))
      + (select count(distinct client_id) from food_orders where created_at >= date_trunc('day', now()))
      + (select count(distinct client_id) from delivery_requests where created_at >= date_trunc('day', now())) as today,
      (select count(distinct client_id) from rides where created_at >= date_trunc('day', now()) - interval '1 day' and created_at < date_trunc('day', now()))
      + (select count(distinct client_id) from food_orders where created_at >= date_trunc('day', now()) - interval '1 day' and created_at < date_trunc('day', now()))
      + (select count(distinct client_id) from delivery_requests where created_at >= date_trunc('day', now()) - interval '1 day' and created_at < date_trunc('day', now())) as yesterday
  ),
  active_providers as (
    select
      (select count(*) from vehicles where is_online = true) + (select count(*) from restaurants where is_open = true) as now_count
  ),
  period_orders as (
    select 'taxi'::text as service_type, created_at, completed_at, status::text as status, price as amount from rides where created_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
    union all
    select 'food', created_at, completed_at, status::text, total from food_orders where created_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
    union all
    select 'delivery', created_at, completed_at, status::text, price from delivery_requests where created_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
  ),
  orders_by_service as (
    select service_type, count(*) as cnt
    from period_orders
    where status = 'completed'
    group by service_type
  ),
  orders_by_hour as (
    select extract(hour from created_at)::int as hr, count(*) as cnt
    from period_orders
    where status = 'completed'
    group by hr
  ),
  period_commissions as (
    select
      case related_order_type
        when 'ride' then 'taxi'
        when 'food_order' then 'food'
        when 'delivery_request' then 'delivery'
      end as service_type,
      created_at,
      -amount as commission
    from wallet_transactions
    where type = 'commission_deduction'
      and created_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
  ),
  revenue_series as (
    select date_trunc(v_bucket, created_at) as bucket, service_type, sum(commission) as revenue
    from period_commissions
    group by bucket, service_type
    order by bucket
  ),
  driver_leaderboard as (
    select v.owner_id, p.full_name, count(*) as orders, avg(r.rating) as rating, sum(rd.price) as revenue
    from rides rd
    join vehicles v on v.owner_id = rd.driver_id and v.service_type = 'taxi'
    join profiles p on p.id = v.owner_id
    left join ratings r on r.order_id = rd.id and r.order_type = 'ride' and r.rated_entity_id = rd.driver_id
    where rd.status = 'completed' and rd.completed_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
    group by v.owner_id, p.full_name
    order by orders desc
    limit 3
  ),
  restaurant_leaderboard as (
    select r.id as entity_id, r.name, count(*) as orders, avg(rt.rating) as rating, sum(fo.total) as revenue
    from food_orders fo
    join restaurants r on r.id = fo.restaurant_id
    left join ratings rt on rt.order_id = fo.id and rt.order_type = 'food_order' and rt.rated_entity_type = 'restaurant' and rt.rated_entity_id = r.id
    where fo.status = 'completed' and fo.completed_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
    group by r.id, r.name
    order by orders desc
    limit 3
  ),
  courier_leaderboard as (
    select v.owner_id, p.full_name, count(*) as orders, avg(r.rating) as rating, sum(dr.price) as revenue
    from delivery_requests dr
    join vehicles v on v.owner_id = dr.livreur_id and v.service_type = 'delivery'
    join profiles p on p.id = v.owner_id
    left join ratings r on r.order_id = dr.id and r.order_type = 'delivery_request' and r.rated_entity_id = dr.livreur_id
    where dr.status = 'completed' and dr.completed_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
    group by v.owner_id, p.full_name
    order by orders desc
    limit 3
  ),
  growth as (
    select date_trunc(v_bucket, created_at) as bucket, role, count(*) as cnt
    from profiles
    where created_at >= now() - (v_buckets || ' ' || v_bucket || 's')::interval
      and role in ('client', 'taxi_driver', 'restaurant_owner', 'livreur')
    group by bucket, role
    order by bucket
  )
  select jsonb_build_object(
    'period', p_period,
    'stats', jsonb_build_object(
      'revenue_today', (select revenue from revenue_today),
      'revenue_yesterday', (select revenue from revenue_yesterday),
      'orders_today', (select order_count from revenue_today),
      'orders_yesterday', (select order_count from revenue_yesterday),
      'active_users_today', (select today from active_users),
      'active_users_yesterday', (select yesterday from active_users),
      'active_providers_now', (select now_count from active_providers),
      'avg_order_value_today', case when (select order_count from revenue_today) > 0
        then round((select gross from revenue_today) / (select order_count from revenue_today), 2)
        else 0 end
    ),
    'orders_by_service', (select coalesce(jsonb_object_agg(service_type, cnt), '{}'::jsonb) from orders_by_service),
    'orders_by_hour', (select coalesce(jsonb_object_agg(hr, cnt), '{}'::jsonb) from orders_by_hour),
    'revenue_series', (select coalesce(jsonb_agg(jsonb_build_object('bucket', bucket, 'service_type', service_type, 'revenue', revenue)), '[]'::jsonb) from revenue_series),
    'leaderboard', jsonb_build_object(
      'drivers', (select coalesce(jsonb_agg(jsonb_build_object('id', owner_id, 'name', full_name, 'orders', orders, 'rating', round(coalesce(rating, 0), 1), 'revenue', revenue)), '[]'::jsonb) from driver_leaderboard),
      'restaurants', (select coalesce(jsonb_agg(jsonb_build_object('id', entity_id, 'name', name, 'orders', orders, 'rating', round(coalesce(rating, 0), 1), 'revenue', revenue)), '[]'::jsonb) from restaurant_leaderboard),
      'couriers', (select coalesce(jsonb_agg(jsonb_build_object('id', owner_id, 'name', full_name, 'orders', orders, 'rating', round(coalesce(rating, 0), 1), 'revenue', revenue)), '[]'::jsonb) from courier_leaderboard)
    ),
    'growth', (select coalesce(jsonb_agg(jsonb_build_object('bucket', bucket, 'role', role, 'count', cnt)), '[]'::jsonb) from growth)
  ) into v_result;

  return v_result;
end;
$$;

revoke all on function public.admin_dashboard_stats(text) from public;
grant execute on function public.admin_dashboard_stats(text) to service_role;

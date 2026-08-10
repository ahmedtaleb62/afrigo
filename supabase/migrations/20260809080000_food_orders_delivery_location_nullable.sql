-- The pickup migration (20260808120000) added `is_pickup` and taught
-- createFoodOrder to insert `delivery_location: null` for pickup orders,
-- but never relaxed the column's own `not null` constraint from when it
-- was delivery-only — every pickup order failed at insert with "null
-- value in column delivery_location violates not-null constraint".
alter table public.food_orders
  alter column delivery_location drop not null;

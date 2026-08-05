-- Adds the fields needed to close two Client-app gaps flagged in review:
-- (1) payment method was always implicitly cash with no way to record a
-- different choice, (2) the ride vehicle-class picker (economy/comfort)
-- was collected in the UI but had nowhere to land server-side, so it was
-- silently dropped. Neither changes matching/pricing behavior — both are
-- plain record-keeping columns the client app can now actually populate.
create type public.payment_method as enum ('cash', 'baridimob', 'bank_transfer');

alter table public.rides add column payment_method public.payment_method not null default 'cash';
alter table public.food_orders add column payment_method public.payment_method not null default 'cash';
alter table public.delivery_requests add column payment_method public.payment_method not null default 'cash';

alter table public.rides add column vehicle_class text;

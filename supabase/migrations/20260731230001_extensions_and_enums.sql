-- Extensions
create extension if not exists postgis with schema extensions;
create extension if not exists pgcrypto with schema extensions;

-- Enums
create type public.user_role as enum ('client', 'taxi_driver', 'restaurant_owner', 'livreur', 'admin');
create type public.language_pref as enum ('ar', 'fr');
create type public.vehicle_service_type as enum ('taxi', 'delivery');
create type public.verification_status as enum ('pending', 'verified', 'rejected');
create type public.wallet_transaction_type as enum ('topup', 'commission_deduction');
create type public.commission_service_type as enum ('taxi', 'food', 'delivery');
create type public.ride_status as enum (
  'searching', 'no_driver_found', 'accepted', 'driver_arriving',
  'in_progress', 'completed', 'cancelled_by_client', 'cancelled_by_driver'
);
create type public.food_order_status as enum (
  'pending_restaurant', 'rejected_by_restaurant', 'accepted', 'preparing', 'ready',
  'searching_livreur', 'no_livreur_found', 'out_for_delivery', 'delivered', 'completed', 'cancelled'
);
create type public.delivery_status as enum (
  'searching', 'no_livreur_found', 'accepted', 'picked_up', 'delivered', 'completed', 'cancelled'
);
create type public.order_type as enum ('ride', 'food_order', 'delivery_request');
create type public.rated_entity_type as enum ('driver', 'restaurant', 'livreur', 'client');
create type public.voice_order_status as enum ('processing', 'pending_confirmation', 'confirmed', 'failed');
create type public.address_label as enum ('home', 'work', 'other');

-- Helper: generic `updated_at = now()` trigger, reused by every table that
-- has an updated_at column.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

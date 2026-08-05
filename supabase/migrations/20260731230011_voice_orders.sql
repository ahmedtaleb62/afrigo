create table public.voice_orders (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles (id),
  audio_url text not null,
  transcribed_text text,
  parsed_intent jsonb,
  service_type text,
  status public.voice_order_status not null default 'processing',
  failure_reason text,
  resulting_order_id uuid,
  resulting_order_type text check (resulting_order_type in ('ride', 'food_order', 'delivery_request')),
  created_at timestamptz not null default now()
);

create index voice_orders_client_id_idx on public.voice_orders (client_id, created_at desc);
create index voice_orders_status_idx on public.voice_orders (status);

alter table public.voice_orders enable row level security;

create policy "voice_orders_select_own_or_admin"
  on public.voice_orders for select
  to authenticated
  using (client_id = auth.uid() or public.is_admin());

-- The client uploads the recording and creates the row (status defaults to
-- 'processing'); transcription/parsing/confirmation are all done by
-- service-role Edge Functions (voice-order-transcribe/-parse-intent/-confirm),
-- so there is no client UPDATE policy.
create policy "voice_orders_insert_own"
  on public.voice_orders for insert
  to authenticated
  with check (client_id = auth.uid());

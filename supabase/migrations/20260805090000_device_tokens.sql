-- Backs real push notifications (FCM). A user can have multiple tokens
-- (multiple devices, or a reinstall that gets a fresh token) — sending fans
-- out to every row for that user_id. Only service_role may ever read this
-- table: a client must never be able to enumerate another user's device
-- tokens, same privacy posture as `vehicles.current_location`.
create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android', 'ios')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index device_tokens_user_id_idx on public.device_tokens (user_id);

create or replace function public.device_tokens_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger device_tokens_set_updated_at_trigger
  before update on public.device_tokens
  for each row execute function public.device_tokens_set_updated_at();

alter table public.device_tokens enable row level security;

-- Owner may register/refresh/remove their own token(s) — this is all a
-- client ever needs; register-device-token still runs as the authenticated
-- user (not service-role) so `auth.uid()` is trustworthy here.
create policy "device_tokens_insert_own"
  on public.device_tokens for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "device_tokens_update_own"
  on public.device_tokens for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "device_tokens_delete_own"
  on public.device_tokens for delete
  to authenticated
  using (user_id = auth.uid());

-- No select policy for `authenticated` on purpose — only service_role
-- (which bypasses RLS entirely) reads tokens, to send pushes.

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index notifications_user_id_idx on public.notifications (user_id, created_at desc);

-- Owner may only ever flip `is_read`; everything else is written by the
-- service-role `send-notification` Edge Function.
create or replace function public.notifications_guard()
returns trigger
language plpgsql
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;

  if new.title is distinct from old.title
     or new.body is distinct from old.body
     or new.data is distinct from old.data
     or new.user_id is distinct from old.user_id then
    raise exception 'notifications: only is_read can be changed by the recipient';
  end if;

  return new;
end;
$$;

create trigger notifications_guard_trigger
  before update on public.notifications
  for each row execute function public.notifications_guard();

alter table public.notifications enable row level security;

create policy "notifications_select_own_or_admin"
  on public.notifications for select
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

create policy "notifications_update_own"
  on public.notifications for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

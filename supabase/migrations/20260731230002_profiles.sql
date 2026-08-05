create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.user_role not null,
  full_name text not null,
  email text unique,
  phone text unique,
  language_pref public.language_pref not null default 'ar',
  is_suspended boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index profiles_role_idx on public.profiles (role);

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Helper: is the caller an admin? SECURITY DEFINER + fixed search_path so it
-- can be called from any table's RLS policy (including profiles' own,
-- without recursive-RLS errors) without granting broad table privileges.
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- Without this, "profiles_update_own_or_admin" below would let a client set
-- their *own* role to 'admin' (or clear is_suspended) in a plain UPDATE —
-- role is only ever assigned at signup by the service-role
-- `register-provider` Edge Function, and is_suspended is only ever flipped
-- by the admin-suspend Edge Function (so it lands in admin_audit_log, per
-- spec). Admin's `is_admin()` grant on the RLS policy is for every *other*
-- column; role/is_suspended stay service-role-only even for admins.
create or replace function public.profiles_guard()
returns trigger
language plpgsql
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;

  if tg_op = 'UPDATE' and (
    new.role is distinct from old.role
    or new.is_suspended is distinct from old.is_suspended
  ) then
    raise exception 'profiles: role/is_suspended can only be changed by a service-role Edge Function';
  end if;

  return new;
end;
$$;

create trigger profiles_guard_trigger
  before update on public.profiles
  for each row execute function public.profiles_guard();

alter table public.profiles enable row level security;

create policy "profiles_select_own_or_admin"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_admin());

-- No client-side INSERT policy: `register-provider` (service-role) is the
-- only path that creates a profile row, immediately after Auth signup.

create policy "profiles_update_own_or_admin"
  on public.profiles for update
  to authenticated
  using (id = auth.uid() or public.is_admin())
  with check (id = auth.uid() or public.is_admin());

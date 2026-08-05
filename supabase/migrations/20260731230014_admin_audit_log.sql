create table public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid not null references public.profiles (id),
  action text not null,
  target_table text not null,
  target_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index admin_audit_log_admin_id_idx on public.admin_audit_log (admin_id, created_at desc);
create index admin_audit_log_target_idx on public.admin_audit_log (target_table, target_id);

alter table public.admin_audit_log enable row level security;

create policy "admin_audit_log_admin_only"
  on public.admin_audit_log for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

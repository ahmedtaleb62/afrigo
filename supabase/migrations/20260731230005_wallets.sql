create table public.wallets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references public.profiles (id) on delete cascade,
  balance numeric(12, 2) not null default 0,
  currency text not null default 'MRU',
  low_balance_threshold numeric(12, 2) not null default 0,
  updated_at timestamptz not null default now()
);

create trigger set_wallets_updated_at
  before update on public.wallets
  for each row execute function public.set_updated_at();

alter table public.wallets enable row level security;

-- Wallets are read-only from the client's perspective, for owner and admin
-- alike. There is deliberately no INSERT/UPDATE policy for `authenticated`
-- here: every balance change goes through a service-role Edge Function
-- (register-provider creates the row; admin-topup-wallet and
-- complete-order-and-deduct-commission change `balance`), which bypasses
-- RLS entirely via the service_role key.
create policy "wallets_select_own_or_admin"
  on public.wallets for select
  to authenticated
  using (owner_id = auth.uid() or public.is_admin());

--------------------------------------------------------------------------
-- wallet_transactions
--------------------------------------------------------------------------
create table public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets (id) on delete cascade,
  amount numeric(12, 2) not null,
  type public.wallet_transaction_type not null,
  related_order_id uuid,
  related_order_type text check (related_order_type in ('ride', 'food_order', 'delivery_request')),
  note text,
  created_by uuid references public.profiles (id),
  created_at timestamptz not null default now()
);

create index wallet_transactions_wallet_id_idx on public.wallet_transactions (wallet_id, created_at desc);

alter table public.wallet_transactions enable row level security;

create policy "wallet_transactions_select_own_or_admin"
  on public.wallet_transactions for select
  to authenticated
  using (
    public.is_admin()
    or exists (select 1 from public.wallets w where w.id = wallet_id and w.owner_id = auth.uid())
  );

create policy "wallet_transactions_insert_admin"
  on public.wallet_transactions for insert
  to authenticated
  with check (public.is_admin());

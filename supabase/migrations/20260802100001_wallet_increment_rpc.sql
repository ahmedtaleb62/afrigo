-- Atomic wallet balance increment, for use by service-role Edge Functions
-- only (admin-topup-wallet, complete-order-and-deduct-commission). A plain
-- "read balance, add delta, write balance" from an Edge Function would race
-- against a concurrent deduction; this does it in one UPDATE statement.
--
-- SECURITY DEFINER so it can write `wallets.balance` despite RLS having no
-- UPDATE policy for anyone — but EXECUTE is revoked from public/authenticated
-- and granted only to service_role, so a regular authenticated user still
-- cannot call this to credit themselves.
create or replace function public.increment_wallet_balance(p_wallet_id uuid, p_delta numeric)
returns numeric
language plpgsql
security definer
set search_path = public
as $$
declare
  new_balance numeric;
begin
  update public.wallets
  set balance = balance + p_delta
  where id = p_wallet_id
  returning balance into new_balance;

  if new_balance is null then
    raise exception 'wallet % not found', p_wallet_id;
  end if;

  return new_balance;
end;
$$;

revoke all on function public.increment_wallet_balance(uuid, numeric) from public;
grant execute on function public.increment_wallet_balance(uuid, numeric) to service_role;

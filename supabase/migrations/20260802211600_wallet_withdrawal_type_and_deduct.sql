-- Adds the admin-initiated withdrawal path: previously `admin-topup-wallet`
-- was the only way a balance could ever change from an admin action, with
-- no counterpart for "admin paid the provider out-of-band, now deduct it
-- from their recorded balance." `wallet_transaction_type` only had
-- 'topup'/'commission_deduction' — neither is an honest label for this, so
-- add 'admin_withdrawal' rather than reusing 'commission_deduction' (which
-- would misattribute it to the automatic per-order trigger in
-- `wallet_transactions` history/reporting).
alter type public.wallet_transaction_type add value 'admin_withdrawal';

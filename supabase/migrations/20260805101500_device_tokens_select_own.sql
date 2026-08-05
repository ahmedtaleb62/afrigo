-- `device_tokens` was deliberately left with no SELECT policy for
-- `authenticated` (only service_role should enumerate tokens, same privacy
-- posture as `vehicles.current_location`). That broke every real insert:
-- `supabase_flutter`'s `.upsert()` always requests `Prefer:
-- return=representation`, and Postgres requires the just-written row to
-- pass RLS *SELECT* visibility for a RETURNING clause to succeed — with no
-- SELECT policy at all, every insert failed with "new row violates row-
-- level security policy" even though the INSERT policy's WITH CHECK was
-- satisfied. A user seeing their own token rows doesn't violate the
-- original privacy goal (never seeing *other* users' tokens); this policy
-- is still scoped to `user_id = auth.uid()`.
create policy "device_tokens_select_own"
  on public.device_tokens for select
  to authenticated
  using (user_id = auth.uid());

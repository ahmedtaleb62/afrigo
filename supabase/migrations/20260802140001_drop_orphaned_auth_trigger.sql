-- Removes a leftover trigger+function from the unrelated app that occupied
-- this Supabase project before Afrigo's schema was pushed (see
-- supabase/README.md's "Housekeeping note" — the earlier cleanup dropped
-- the orphaned `public` schema types/functions found at the time, but this
-- trigger lives on `auth.users` itself, so it wasn't caught by that scan).
--
-- `handle_new_user()` fired on every single signup across all 5 apps and
-- always failed: it tries to insert `profiles.role = 'student'` (not a
-- valid value in Afrigo's `user_role` enum: client/taxi_driver/
-- restaurant_owner/livreur/admin) and references a `teacher_profiles` table
-- that doesn't exist in this schema at all. Root cause of every
-- "Database error saving new user" signup failure — Postgres rolls back
-- the whole transaction (including the `auth.users` insert) when an AFTER
-- INSERT trigger raises, which is why `auth.users` stayed empty despite
-- every app's signup screen appearing to submit successfully client-side.
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();

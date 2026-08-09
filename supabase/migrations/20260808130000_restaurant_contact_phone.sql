-- Restaurant Policies screen (حسابي → سياسة المطعم) needs a client-facing
-- support number, distinct from the owner's own account phone.
alter table public.restaurants
  add column contact_phone text;

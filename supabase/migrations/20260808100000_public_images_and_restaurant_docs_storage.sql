-- Two new buckets:
--
-- `public-images` (public read) — profile photos (any role, uploaded any
-- time from "حسابي"), restaurant logos, and dish photos. All customer-
-- facing, so unlike vehicle-docs/restaurant-docs these need to be readable
-- without auth. Path convention: `{uid}/profile.jpg`,
-- `{uid}/restaurant-logo.jpg`, `{uid}/dishes/{dish_id}.jpg` — write access
-- restricted to the owning user via the same first-path-segment == auth.uid()
-- convention already used for vehicle-docs; the "public" bucket flag makes
-- reads work via a plain public URL with no RLS/signed-URL dance needed.
--
-- `restaurant-docs` (private) — the business license photo, same
-- ownership/visibility model as vehicle-docs (owner + admin only).
insert into storage.buckets (id, name, public)
values ('public-images', 'public-images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('restaurant-docs', 'restaurant-docs', false)
on conflict (id) do nothing;

create policy "public_images_insert_own"
on storage.objects for insert
to authenticated
with check (bucket_id = 'public-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "public_images_update_own"
on storage.objects for update
to authenticated
using (bucket_id = 'public-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "public_images_delete_own"
on storage.objects for delete
to authenticated
using (bucket_id = 'public-images' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "public_images_select_all"
on storage.objects for select
to public
using (bucket_id = 'public-images');

create policy "restaurant_docs_insert_own"
on storage.objects for insert
to authenticated
with check (bucket_id = 'restaurant-docs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "restaurant_docs_update_own"
on storage.objects for update
to authenticated
using (bucket_id = 'restaurant-docs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "restaurant_docs_select_own_or_admin"
on storage.objects for select
to authenticated
using (bucket_id = 'restaurant-docs' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

create policy "restaurant_docs_delete_own"
on storage.objects for delete
to authenticated
using (bucket_id = 'restaurant-docs' and (storage.foldername(name))[1] = auth.uid()::text);

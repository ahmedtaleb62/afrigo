-- Real storage for vehicle verification documents (driving license photo).
-- Previously `vehicles.driving_license_url` was always the literal string
-- 'pending-upload' or '' -- no file picker, no Storage call anywhere in
-- the app, so admin had nothing real to review. Private bucket: only the
-- owning driver and admins may read/write, via the standard Supabase
-- convention of keying the RLS check off the first path segment
-- (`{owner_id}/license.jpg`) matching `auth.uid()`.
insert into storage.buckets (id, name, public)
values ('vehicle-docs', 'vehicle-docs', false)
on conflict (id) do nothing;

create policy "vehicle_docs_insert_own"
on storage.objects for insert
to authenticated
with check (bucket_id = 'vehicle-docs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "vehicle_docs_update_own"
on storage.objects for update
to authenticated
using (bucket_id = 'vehicle-docs' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "vehicle_docs_select_own_or_admin"
on storage.objects for select
to authenticated
using (bucket_id = 'vehicle-docs' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

create policy "vehicle_docs_delete_own"
on storage.objects for delete
to authenticated
using (bucket_id = 'vehicle-docs' and (storage.foldername(name))[1] = auth.uid()::text);

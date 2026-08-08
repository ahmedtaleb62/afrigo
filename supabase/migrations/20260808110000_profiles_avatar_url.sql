-- Profile photo, uploadable any time from "حسابي" by any role — an
-- explicit product request ("جميع المستخدمين يمكنهم رفع صورهم من صفحة
-- حسابي"). Stored in the public `public-images` bucket (see
-- 20260808100000_public_images_and_restaurant_docs_storage.sql) at
-- `{uid}/profile.jpg`; this column just holds the resulting public URL.
alter table public.profiles add column if not exists avatar_url text;

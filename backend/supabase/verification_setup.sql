-- ---------------------------------------------------------------------------
-- Account verification support.
--
-- 1. profiles.government_id — stores the NID/passport number the user submits
--    (the UI only ever shows its last few characters).
-- 2. Storage policies for the private `verification-docs` bucket, so a signed-in
--    user can upload their own NID photos and read only their own back.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column if not exists government_id text;

-- Keep the documents bucket private: photos of ID must not be publicly readable.
insert into storage.buckets (id, name, public)
values ('verification-docs', 'verification-docs', false)
on conflict (id) do update set public = false;

drop policy if exists "users upload own verification docs" on storage.objects;
drop policy if exists "users read own verification docs" on storage.objects;
drop policy if exists "users delete own verification docs" on storage.objects;

-- Files are stored under "<auth uid>/<file>", so the first path segment is the
-- owner's id — that is what restricts each user to their own folder.
create policy "users upload own verification docs"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'verification-docs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "users read own verification docs"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'verification-docs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "users delete own verification docs"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'verification-docs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Check
select column_name
from information_schema.columns
where table_schema = 'public' and table_name = 'profiles'
  and column_name = 'government_id';

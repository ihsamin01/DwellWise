-- ───────────────────────────────────────────────────────────────────────
-- Storage access for listing photos.
--
-- 0014 created the `property-images` bucket but left its policies as a
-- TODO. storage.objects has row-level security on by default, so with no
-- policy every upload from the app was refused and each listing was saved
-- with an empty image_urls — which is why owners' photos never appeared.
--
-- A signed-in user may upload, and anyone may read, since listing photos
-- are shown publicly. Uploads go to a folder named after the uploader, so
-- one owner cannot overwrite another's photo.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('property-images', 'property-images', true)
on conflict (id) do update set public = true;

drop policy if exists "property images are publicly readable" on storage.objects;
drop policy if exists "authenticated can upload property images" on storage.objects;
drop policy if exists "owners can update their property images" on storage.objects;
drop policy if exists "owners can delete their property images" on storage.objects;

create policy "property images are publicly readable"
  on storage.objects for select
  using (bucket_id = 'property-images');

create policy "authenticated can upload property images"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'property-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "owners can update their property images"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'property-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "owners can delete their property images"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'property-images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Check: should list all four policies.
select policyname
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and policyname ilike '%property images%'
order by policyname;

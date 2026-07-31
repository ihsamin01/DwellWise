-- ---------------------------------------------------------------------------
-- Storage access for listing photos.
--
-- The `property-images` bucket was created with the schema, but storage.objects
-- has Row Level Security on by default and no policies were ever added — so
-- uploads from the app were rejected. These policies let a signed-in user
-- upload photos and let anyone read them, which is what the public listing
-- images need.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ---------------------------------------------------------------------------

-- Make sure the bucket exists and is public (public URLs, no signed links).
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
  with check (bucket_id = 'property-images');

create policy "owners can update their property images"
  on storage.objects for update to authenticated
  using (bucket_id = 'property-images' and owner = auth.uid());

create policy "owners can delete their property images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'property-images' and owner = auth.uid());

-- Check
select policyname
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and policyname ilike '%property images%'
order by policyname;

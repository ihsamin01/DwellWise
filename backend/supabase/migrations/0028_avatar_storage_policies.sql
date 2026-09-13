-- ───────────────────────────────────────────────────────────────────────
-- Storage access for profile photos.
--
-- 0014 created the `avatars` bucket and left its policies as a TODO, the
-- same way it did for property-images. storage.objects has row-level
-- security on by default, so with no policy every upload was refused and
-- choosing a photo from the gallery silently did nothing — which is why
-- every avatar in the database is still one of the built-in presets.
--
-- A signed-in user may upload, and anyone may read, since avatars are
-- shown publicly on cards and in chat. Each photo goes to a folder named
-- after the uploader, so nobody can overwrite someone else's.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

drop policy if exists "avatars are publicly readable" on storage.objects;
drop policy if exists "authenticated can upload their own avatar" on storage.objects;
drop policy if exists "owners can update their own avatar" on storage.objects;
drop policy if exists "owners can delete their own avatar" on storage.objects;

create policy "avatars are publicly readable"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "authenticated can upload their own avatar"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Replacing a photo overwrites the same object, so update is needed too.
create policy "owners can update their own avatar"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "owners can delete their own avatar"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Check: should list all four policies.
select policyname
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
  and policyname ilike '%avatar%'
order by policyname;

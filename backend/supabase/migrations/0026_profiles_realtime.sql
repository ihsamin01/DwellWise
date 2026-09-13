-- ───────────────────────────────────────────────────────────────────────
-- Profile changes over realtime.
--
-- Changing a profile photo only reached the other side of a conversation
-- after they reloaded their inbox, because the name and avatar are read
-- once when the chat list is fetched. Publishing profiles lets the app
-- pick the new photo up as it is saved.
--
-- Only the columns the app already shows are of interest; row-level
-- security still decides who receives what.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

do $$
begin
  begin
    alter publication supabase_realtime add table public.profiles;
  exception when duplicate_object then null;
  end;
end $$;

-- Carries the whole row on update, which is what Supabase asks for before
-- it will apply row-level security to update events.
alter table public.profiles replica identity full;

-- Check: should list "profiles".
select tablename
from pg_publication_tables
where pubname = 'supabase_realtime'
  and tablename = 'profiles';

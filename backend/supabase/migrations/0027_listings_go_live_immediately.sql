-- ───────────────────────────────────────────────────────────────────────
-- Listings are live the moment they are posted.
--
-- The column defaulted to 'pending' while the app writes 'approved' with
-- every insert, so the default never actually applied and the two
-- disagreed about what a new listing is. There is no moderation step in
-- the app, so the column now says what really happens.
--
-- The enum keeps its other values, so turning moderation on later is a
-- matter of writing 'pending' again rather than a schema change.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

alter table public.properties
  alter column status set default 'approved';

-- Anything left waiting on a review that never comes.
update public.properties
   set status = 'approved'
 where status = 'pending';

-- Check: should report 0 pending and the default as 'approved'.
select
  (select count(*) from public.properties where status = 'pending') as still_pending,
  (select column_default
     from information_schema.columns
    where table_schema = 'public'
      and table_name = 'properties'
      and column_name = 'status') as status_default;

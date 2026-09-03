-- ───────────────────────────────────────────────────────────────────────
-- Read receipts over realtime.
--
-- Marking a chat read is an UPDATE on rows the *sender* is subscribed to,
-- so the sender's ticks can turn blue without a reload. `messages` is
-- already in the supabase_realtime publication (0015); this makes the
-- replica carry the whole row, which is what Supabase asks for before it
-- will evaluate row-level security on update and delete events.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

alter table public.messages replica identity full;

-- Check: should list "messages" as full ('f').
select relname, relreplident
from pg_class
where relname = 'messages'
  and relnamespace = 'public'::regnamespace;

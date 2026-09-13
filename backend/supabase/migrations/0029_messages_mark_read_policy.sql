-- ───────────────────────────────────────────────────────────────────────
-- Let a chat participant mark the other side's messages read.
--
-- `messages` had a select and an insert policy but no update policy, so
-- ChatService.markRead's `update({'is_read': true})` was rejected by row
-- level security every time -- not just silently missing from realtime,
-- the write itself never happened. Seen ticks could never turn on.
--
-- Same participant check as the existing select policy: either side of
-- the chat may update its rows (needed so the reader can flip is_read on
-- what the other person sent).
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

drop policy if exists "participants mark messages read" on public.messages;

create policy "participants mark messages read"
  on public.messages for update
  using (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (c.participant_a = auth.uid() or c.participant_b = auth.uid())
    )
  )
  with check (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (c.participant_a = auth.uid() or c.participant_b = auth.uid())
    )
  );

-- Check: should list the new policy alongside the existing select/insert ones.
select policyname, cmd
from pg_policies
where schemaname = 'public'
  and tablename = 'messages'
order by policyname;

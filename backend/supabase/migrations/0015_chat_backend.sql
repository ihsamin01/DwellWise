-- ───────────────────────────────────────────────────────────────────────
-- Chat: row-level security policies, the columns the app already models, a
-- trigger to keep the conversation preview in step, and realtime.
-- ───────────────────────────────────────────────────────────────────────

-- ── columns the app already models ───────────────────────────────────────
alter table public.messages
  add column if not exists type        text not null default 'text',
  add column if not exists duration_ms integer,
  add column if not exists latitude    double precision,
  add column if not exists longitude   double precision;

alter table public.chats
  add column if not exists is_muted boolean not null default false;

-- ── who may see what ─────────────────────────────────────────────────────
-- A chat is visible only to its two participants; a message only to the
-- participants of its chat.

drop policy if exists chats_select_own on public.chats;
create policy chats_select_own on public.chats
  for select using (auth.uid() = participant_a or auth.uid() = participant_b);

drop policy if exists chats_insert_own on public.chats;
create policy chats_insert_own on public.chats
  for insert with check (auth.uid() = participant_a or auth.uid() = participant_b);

drop policy if exists chats_update_own on public.chats;
create policy chats_update_own on public.chats
  for update using (auth.uid() = participant_a or auth.uid() = participant_b);

drop policy if exists chats_delete_own on public.chats;
create policy chats_delete_own on public.chats
  for delete using (auth.uid() = participant_a or auth.uid() = participant_b);

drop policy if exists messages_select_participant on public.messages;
create policy messages_select_participant on public.messages
  for select using (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (auth.uid() = c.participant_a or auth.uid() = c.participant_b)
    )
  );

-- Insert requires being the sender *and* a participant, so nobody can post
-- into someone else's thread or forge another user as the sender.
drop policy if exists messages_insert_own on public.messages;
create policy messages_insert_own on public.messages
  for insert with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (auth.uid() = c.participant_a or auth.uid() = c.participant_b)
    )
  );

-- Update is for marking read, which the *recipient* does.
drop policy if exists messages_update_participant on public.messages;
create policy messages_update_participant on public.messages
  for update using (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (auth.uid() = c.participant_a or auth.uid() = c.participant_b)
    )
  );

-- ── keep the conversation list in sync ───────────────────────────────────
-- The chats list shows a preview of the latest message.
create or replace function public.touch_chat_on_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.chats
     set last_message           = coalesce(nullif(new.message, ''), '[attachment]'),
         last_message_time      = new.created_at,
         last_message_sender_id = new.sender_id
   where id = new.chat_id;
  return new;
end;
$$;

drop trigger if exists messages_touch_chat on public.messages;
create trigger messages_touch_chat
  after insert on public.messages
  for each row execute function public.touch_chat_on_message();

-- ── realtime ─────────────────────────────────────────────────────────────
-- Lets the app subscribe to new messages instead of polling.
do $$
begin
  begin
    alter publication supabase_realtime add table public.messages;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.chats;
  exception when duplicate_object then null;
  end;
end $$;

-- ───────────────────────────────────────────────────────────────────────
-- Assistant chat history, so past conversations can be reopened.
--
-- property_ids keeps the listings a reply showed, which is what lets the
-- cards come back when an old conversation is loaded. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

create table if not exists public.ai_conversations (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  title      text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ai_conversations_user_idx
  on public.ai_conversations (user_id, updated_at desc);

create table if not exists public.ai_messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null
                    references public.ai_conversations (id) on delete cascade,
  role            text not null check (role in ('user', 'assistant')),
  content         text not null default '',
  property_ids    text[] not null default '{}',
  created_at      timestamptz not null default now()
);

create index if not exists ai_messages_conversation_idx
  on public.ai_messages (conversation_id, created_at);

alter table public.ai_conversations enable row level security;
alter table public.ai_messages enable row level security;

-- A conversation belongs to one user, and only that user may see it.
drop policy if exists ai_conversations_own on public.ai_conversations;
create policy ai_conversations_own on public.ai_conversations
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Messages follow their conversation.
drop policy if exists ai_messages_own on public.ai_messages;
create policy ai_messages_own on public.ai_messages
  for all using (
    exists (
      select 1 from public.ai_conversations c
      where c.id = ai_messages.conversation_id and c.user_id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from public.ai_conversations c
      where c.id = ai_messages.conversation_id and c.user_id = auth.uid()
    )
  );

-- Keeps the history list ordered by real activity.
create or replace function public.touch_ai_conversation()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
begin
  update public.ai_conversations
     set updated_at = new.created_at
   where id = new.conversation_id;
  return new;
end;
$func$;

drop trigger if exists ai_messages_touch_conversation on public.ai_messages;
create trigger ai_messages_touch_conversation
  after insert on public.ai_messages
  for each row execute function public.touch_ai_conversation();

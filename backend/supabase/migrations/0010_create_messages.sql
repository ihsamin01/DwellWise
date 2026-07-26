-- ─────────────────────────────────────────────────────────────────────────
-- messages  →  lib/models/chat_message_model.dart
-- Screens: chat (thread view). Realtime subscription per chat_id.
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.messages (
  id             uuid primary key default gen_random_uuid(),
  chat_id        uuid not null references public.chats (id) on delete cascade,
  sender_id      uuid not null references public.profiles (id) on delete cascade,
  message        text not null default '',
  attachment_url text,
  is_read        boolean not null default false,
  created_at     timestamptz not null default now()
);

create index if not exists messages_chat_idx on public.messages (chat_id, created_at);

alter table public.messages enable row level security;

-- TODO: policies — only chat participants can read/insert
-- TODO: trigger to update chats.last_message* on new message

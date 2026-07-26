-- ─────────────────────────────────────────────────────────────────────────
-- chats  →  lib/models/chat_model.dart (UI aggregate over a conversation)
-- Screens: chats (list)
-- A conversation between two participants, optionally about a property.
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.chats (
  id                uuid primary key default gen_random_uuid(),
  participant_a     uuid not null references public.profiles (id) on delete cascade,
  participant_b     uuid not null references public.profiles (id) on delete cascade,
  property_id       uuid references public.properties (id) on delete set null,
  last_message      text not null default '',
  last_message_time timestamptz,
  last_message_sender_id uuid references public.profiles (id),
  is_priority       boolean not null default false,
  created_at        timestamptz not null default now(),
  unique (participant_a, participant_b, property_id)
);

create index if not exists chats_a_idx on public.chats (participant_a);
create index if not exists chats_b_idx on public.chats (participant_b);

alter table public.chats enable row level security;

-- TODO: policies — only the two participants can read/write; realtime enabled
-- Note: unread_count / is_online / is_typing (ChatModel) are computed at read
-- time or tracked via Realtime presence, not stored columns.

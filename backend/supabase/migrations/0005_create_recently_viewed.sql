-- ─────────────────────────────────────────────────────────────────────────
-- recently_viewed  →  lib/providers/recently_viewed_provider.dart
-- Screens: recently_viewed
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.recently_viewed (
  user_id     uuid not null references public.profiles (id) on delete cascade,
  property_id uuid not null references public.properties (id) on delete cascade,
  viewed_at   timestamptz not null default now(),
  primary key (user_id, property_id)
);

create index if not exists recently_viewed_user_idx
  on public.recently_viewed (user_id, viewed_at desc);

alter table public.recently_viewed enable row level security;

create policy "users manage own history"
  on public.recently_viewed for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

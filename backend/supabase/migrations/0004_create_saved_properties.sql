-- ─────────────────────────────────────────────────────────────────────────
-- saved_properties  →  lib/providers/saved_properties_provider.dart
-- Screens: saved (tenant bookmarks / favourites)
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.saved_properties (
  user_id     uuid not null references public.profiles (id) on delete cascade,
  property_id uuid not null references public.properties (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, property_id)
);

alter table public.saved_properties enable row level security;

-- TODO: policies — user manages only their own saves

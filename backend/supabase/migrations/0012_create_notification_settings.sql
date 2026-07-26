-- ─────────────────────────────────────────────────────────────────────────
-- notification_settings  →  lib/providers/notification_settings_provider.dart
-- Screens: notification_settings
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.notification_settings (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  push_enabled      boolean not null default true,
  email_enabled     boolean not null default true,
  new_message       boolean not null default true,
  inquiry_updates   boolean not null default true,
  listing_updates   boolean not null default true,
  promotions        boolean not null default false,
  updated_at        timestamptz not null default now()
);

alter table public.notification_settings enable row level security;

-- TODO: policies — user manages only their own row

-- ─────────────────────────────────────────────────────────────────────────
-- app_reviews  →  lib/models/app_review_model.dart
-- Screens: rate_app (user rates the DwellWise app itself)
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.app_reviews (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references public.profiles (id) on delete set null,
  user_name   text not null default '',
  rating      numeric not null default 0 check (rating >= 0 and rating <= 5),
  review_text text not null default '',
  created_at  timestamptz not null default now()
);

alter table public.app_reviews enable row level security;

-- TODO: policies — anyone reads; authenticated writes own

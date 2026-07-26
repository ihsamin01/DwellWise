-- ─────────────────────────────────────────────────────────────────────────
-- reviews  →  lib/models/review_model.dart
-- Screens: property_details (tenant reviews of a property)
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.reviews (
  id          uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties (id) on delete cascade,
  tenant_id   uuid not null references public.profiles (id) on delete cascade,
  tenant_name text not null default 'Anonymous',
  rating      numeric not null default 0 check (rating >= 0 and rating <= 5),
  comment     text not null default '',
  created_at  timestamptz not null default now(),
  unique (property_id, tenant_id)
);

create index if not exists reviews_property_idx on public.reviews (property_id);

alter table public.reviews enable row level security;

-- TODO: policies — anyone reads; tenant writes own; admin all

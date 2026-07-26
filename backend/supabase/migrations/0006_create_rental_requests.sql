-- ─────────────────────────────────────────────────────────────────────────
-- rental_requests  →  lib/models/rental_request_model.dart
-- Screens: inquiries (tenant), owner_inquiries (owner), purchase_history
-- ─────────────────────────────────────────────────────────────────────────

create type rental_request_status as enum ('pending', 'approved', 'rejected', 'cancelled');

create table if not exists public.rental_requests (
  id            uuid primary key default gen_random_uuid(),
  property_id   uuid not null references public.properties (id) on delete cascade,
  tenant_id     uuid not null references public.profiles (id) on delete cascade,
  owner_id      uuid not null references public.profiles (id) on delete cascade,
  proposed_rent numeric not null default 0,
  move_in_date  timestamptz not null,
  status        rental_request_status not null default 'pending',
  message       text,
  created_at    timestamptz not null default now()
);

create index if not exists rental_requests_tenant_idx on public.rental_requests (tenant_id);
create index if not exists rental_requests_owner_idx  on public.rental_requests (owner_id);

alter table public.rental_requests enable row level security;

-- TODO: policies
-- select/insert: tenant on own; select/update status: owner of the property; admin all

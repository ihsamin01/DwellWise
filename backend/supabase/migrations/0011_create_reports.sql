-- ─────────────────────────────────────────────────────────────────────────
-- reports
-- Screens: admin/reported_listings (users flag a listing → admin reviews)
-- ─────────────────────────────────────────────────────────────────────────

create type report_status as enum ('open', 'reviewed', 'dismissed', 'removed');

create table if not exists public.reports (
  id           uuid primary key default gen_random_uuid(),
  property_id  uuid not null references public.properties (id) on delete cascade,
  reporter_id  uuid not null references public.profiles (id) on delete cascade,
  reason       text not null default '',
  status       report_status not null default 'open',
  reviewed_by  uuid references public.profiles (id),
  created_at   timestamptz not null default now()
);

create index if not exists reports_property_idx on public.reports (property_id);
create index if not exists reports_status_idx   on public.reports (status);

alter table public.reports enable row level security;

-- TODO: policies — reporter inserts; admin reads/updates all

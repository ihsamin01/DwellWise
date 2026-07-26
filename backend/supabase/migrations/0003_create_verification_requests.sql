-- ─────────────────────────────────────────────────────────────────────────
-- verification_requests
-- Screens: account_verification (user submits form + fee → admin approves)
-- On approval → profiles.verification_status = 'verified' (green badge).
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.verification_requests (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles (id) on delete cascade,
  full_name    text not null default '',
  document_url text,                         -- uploaded ID doc (storage)
  fee_paid     boolean not null default false,
  transaction_id uuid,   -- FK to transactions added in 0013 (created later)
  status       verification_status not null default 'pending',
  reviewed_by  uuid references public.profiles (id),
  created_at   timestamptz not null default now()
);

create index if not exists verification_user_idx on public.verification_requests (user_id);

alter table public.verification_requests enable row level security;

-- TODO: policies
-- insert/select own: user; select/update all: admin

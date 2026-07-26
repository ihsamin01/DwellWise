-- ─────────────────────────────────────────────────────────────────────────
-- transactions  →  lib/services/payment_service.dart
-- Screens: purchase_history, account_verification (fee)
-- Records payments: verification fees and rent payments.
-- ─────────────────────────────────────────────────────────────────────────

create type transaction_type as enum ('verification_fee', 'rent', 'other');
create type transaction_status as enum ('pending', 'success', 'failed', 'refunded');

create table if not exists public.transactions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles (id) on delete cascade,
  property_id   uuid references public.properties (id) on delete set null,
  type          transaction_type not null default 'other',
  amount        numeric not null default 0,
  currency      text not null default 'BDT',
  status        transaction_status not null default 'pending',
  provider_ref  text,                    -- gateway transaction reference
  created_at    timestamptz not null default now()
);

create index if not exists transactions_user_idx on public.transactions (user_id);

-- Wire up the deferred FK from 0003_create_verification_requests.sql
alter table public.verification_requests
  add constraint verification_requests_transaction_fk
  foreign key (transaction_id) references public.transactions (id) on delete set null;

alter table public.transactions enable row level security;

-- TODO: policies — user reads own; service_role writes (via payment fn); admin all

-- ─────────────────────────────────────────────────────────────────────────
-- properties.is_rented  →  lib/models/property_model.dart
-- Screens: my_properties, search, search_results, home
--
-- `status` (pending/approved/rejected) is the admin moderation state and is
-- not reused here -- marking a listing "rented" is an owner action, entirely
-- separate from moderation, and the enum has no spare value for it. This
-- adds one boolean instead: false means publicly visible (subject to
-- `status = 'approved'` as before), true means the owner has taken it off
-- the market without deleting it.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ─────────────────────────────────────────────────────────────────────────

alter table public.properties
  add column if not exists is_rented boolean not null default false;

create index if not exists properties_is_rented_idx on public.properties (is_rented);

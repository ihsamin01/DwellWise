-- ─────────────────────────────────────────────────────────────────────────
-- profiles  →  lib/models/user_model.dart
-- Screens: login, registration, otp, profile, edit_profile,
--          account_security, change_password
-- Extends Supabase auth.users with app-specific profile fields.
-- ─────────────────────────────────────────────────────────────────────────

create type user_role as enum ('tenant', 'owner', 'admin');
create type verification_status as enum ('unverified', 'pending', 'verified');

create table if not exists public.profiles (
  id                  uuid primary key references auth.users (id) on delete cascade,
  email               text not null,
  name                text not null default '',
  phone_number        text not null default '',
  role                user_role not null default 'tenant',
  avatar_url          text,
  address             text,
  verification_status verification_status not null default 'unverified',
  created_at          timestamptz not null default now()
);

-- Auto-create a profile row when a new auth user signs up.
-- create function public.handle_new_user() ... (TODO)
-- create trigger on_auth_user_created after insert on auth.users ... (TODO)

alter table public.profiles enable row level security;

-- TODO: policies
-- select: anyone can read basic profile (owner name/phone shown on cards)
-- update: users can update only their own row
-- admin: full access

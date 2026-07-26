-- ─────────────────────────────────────────────────────────────────────────
-- properties  →  lib/models/property_model.dart
-- Screens: home, listings, search, search_results, map_view,
--          property_details, create_listing, add_property, my_listings,
--          my_properties, listing_details, admin/pending_listings
-- ─────────────────────────────────────────────────────────────────────────

create type property_status as enum ('pending', 'approved', 'rejected');

create table if not exists public.properties (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null references public.profiles (id) on delete cascade,
  title          text not null,
  description    text not null default '',
  -- optional Bangla variants
  title_bn       text not null default '',
  address_bn     text not null default '',
  description_bn text not null default '',
  price          numeric not null default 0,
  price_for      text not null default 'Monthly',   -- Monthly | Weekly | Daily
  property_type  text not null default 'Apartment',
  area           text not null default '',
  address        text not null default '',
  latitude       double precision not null default 0,
  longitude      double precision not null default 0,
  beds           int not null default 0,
  baths          int not null default 0,
  balcony        int not null default 0,
  size_sqft      numeric not null default 0,
  available_from text not null default '',
  included_bills text[] not null default '{}',
  image_urls     text[] not null default '{}',
  facilities     text[] not null default '{}',
  is_verified    boolean not null default false,
  status         property_status not null default 'pending',  -- admin moderation
  created_at     timestamptz not null default now()
);

create index if not exists properties_owner_idx on public.properties (owner_id);
create index if not exists properties_area_idx  on public.properties (area);
create index if not exists properties_status_idx on public.properties (status);

alter table public.properties enable row level security;

-- TODO: policies
-- select: anyone can read approved listings; owner can read own; admin all
-- insert/update/delete: owner on own rows; admin all

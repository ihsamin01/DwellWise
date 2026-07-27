-- ─────────────────────────────────────────────────────────────────────────
-- DwellWise — one-shot Supabase setup (schema + RLS policies).
-- Run ONCE in the Supabase Dashboard → SQL Editor → New query → Run.
-- Creates every table, enables Row Level Security, and adds sensible policies:
--   • public can READ browse data (properties, profiles, reviews)
--   • signed-in users can only WRITE their own rows
-- (Re-running fails on "type already exists" — it is meant for a fresh project.)
-- ─────────────────────────────────────────────────────────────────────────

-- ===== ENUMS =============================================================
create type user_role as enum ('tenant', 'owner', 'admin');
create type verification_status as enum ('unverified', 'pending', 'verified');
create type property_status as enum ('pending', 'approved', 'rejected');
create type rental_request_status as enum ('pending', 'approved', 'rejected', 'cancelled');
create type report_status as enum ('open', 'reviewed', 'dismissed', 'removed');
create type transaction_type as enum ('verification_fee', 'rent', 'other');
create type transaction_status as enum ('pending', 'success', 'failed', 'refunded');

-- ===== PROFILES ==========================================================
create table public.profiles (
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
alter table public.profiles enable row level security;
create policy "profiles are readable by everyone"
  on public.profiles for select using (true);
create policy "users insert own profile"
  on public.profiles for insert with check (auth.uid() = id);
create policy "users update own profile"
  on public.profiles for update using (auth.uid() = id);

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, name, phone_number, role)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.raw_user_meta_data->>'phone_number', ''),
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'tenant')
  );
  return new;
end;
$$;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===== PROPERTIES ========================================================
create table public.properties (
  id             uuid primary key default gen_random_uuid(),
  owner_id       uuid not null references public.profiles (id) on delete cascade,
  title          text not null,
  description    text not null default '',
  title_bn       text not null default '',
  address_bn     text not null default '',
  description_bn text not null default '',
  price          numeric not null default 0,
  price_for      text not null default 'Monthly',
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
  status         property_status not null default 'pending',
  created_at     timestamptz not null default now()
);
create index properties_owner_idx  on public.properties (owner_id);
create index properties_status_idx on public.properties (status);
alter table public.properties enable row level security;
create policy "approved properties are public; owners see their own"
  on public.properties for select
  using (status = 'approved' or owner_id = auth.uid());
create policy "owners insert own properties"
  on public.properties for insert with check (owner_id = auth.uid());
create policy "owners update own properties"
  on public.properties for update using (owner_id = auth.uid());
create policy "owners delete own properties"
  on public.properties for delete using (owner_id = auth.uid());

-- ===== TRANSACTIONS ======================================================
create table public.transactions (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references public.profiles (id) on delete cascade,
  property_id   uuid references public.properties (id) on delete set null,
  type          transaction_type not null default 'other',
  amount        numeric not null default 0,
  currency      text not null default 'BDT',
  status        transaction_status not null default 'pending',
  provider_ref  text,
  created_at    timestamptz not null default now()
);
create index transactions_user_idx on public.transactions (user_id);
alter table public.transactions enable row level security;
create policy "users read own transactions"
  on public.transactions for select using (user_id = auth.uid());
create policy "users insert own transactions"
  on public.transactions for insert with check (user_id = auth.uid());

-- ===== VERIFICATION REQUESTS =============================================
create table public.verification_requests (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles (id) on delete cascade,
  full_name      text not null default '',
  document_url   text,
  fee_paid       boolean not null default false,
  transaction_id uuid references public.transactions (id) on delete set null,
  status         verification_status not null default 'pending',
  reviewed_by    uuid references public.profiles (id),
  created_at     timestamptz not null default now()
);
create index verification_user_idx on public.verification_requests (user_id);
alter table public.verification_requests enable row level security;
create policy "users read own verification"
  on public.verification_requests for select using (user_id = auth.uid());
create policy "users insert own verification"
  on public.verification_requests for insert with check (user_id = auth.uid());

-- ===== SAVED PROPERTIES ==================================================
create table public.saved_properties (
  user_id     uuid not null references public.profiles (id) on delete cascade,
  property_id uuid not null references public.properties (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, property_id)
);
alter table public.saved_properties enable row level security;
create policy "users manage own saves"
  on public.saved_properties for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ===== RECENTLY VIEWED ===================================================
create table public.recently_viewed (
  user_id     uuid not null references public.profiles (id) on delete cascade,
  property_id uuid not null references public.properties (id) on delete cascade,
  viewed_at   timestamptz not null default now(),
  primary key (user_id, property_id)
);
create index recently_viewed_user_idx on public.recently_viewed (user_id, viewed_at desc);
alter table public.recently_viewed enable row level security;
create policy "users manage own history"
  on public.recently_viewed for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ===== RENTAL REQUESTS ===================================================
create table public.rental_requests (
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
create index rental_requests_tenant_idx on public.rental_requests (tenant_id);
create index rental_requests_owner_idx  on public.rental_requests (owner_id);
alter table public.rental_requests enable row level security;
create policy "tenant and owner see the request"
  on public.rental_requests for select
  using (tenant_id = auth.uid() or owner_id = auth.uid());
create policy "tenant creates own request"
  on public.rental_requests for insert with check (tenant_id = auth.uid());
create policy "tenant or owner update the request"
  on public.rental_requests for update
  using (tenant_id = auth.uid() or owner_id = auth.uid());

-- ===== REVIEWS ===========================================================
create table public.reviews (
  id          uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties (id) on delete cascade,
  tenant_id   uuid not null references public.profiles (id) on delete cascade,
  tenant_name text not null default 'Anonymous',
  rating      numeric not null default 0 check (rating >= 0 and rating <= 5),
  comment     text not null default '',
  created_at  timestamptz not null default now(),
  unique (property_id, tenant_id)
);
create index reviews_property_idx on public.reviews (property_id);
alter table public.reviews enable row level security;
create policy "reviews are public"
  on public.reviews for select using (true);
create policy "tenant writes own review"
  on public.reviews for insert with check (tenant_id = auth.uid());

-- ===== APP REVIEWS =======================================================
create table public.app_reviews (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references public.profiles (id) on delete set null,
  user_name   text not null default '',
  rating      numeric not null default 0 check (rating >= 0 and rating <= 5),
  review_text text not null default '',
  created_at  timestamptz not null default now()
);
alter table public.app_reviews enable row level security;
create policy "app reviews are public"
  on public.app_reviews for select using (true);
create policy "signed-in users write app reviews"
  on public.app_reviews for insert with check (auth.uid() is not null);

-- ===== CHATS =============================================================
create table public.chats (
  id                     uuid primary key default gen_random_uuid(),
  participant_a          uuid not null references public.profiles (id) on delete cascade,
  participant_b          uuid not null references public.profiles (id) on delete cascade,
  property_id            uuid references public.properties (id) on delete set null,
  last_message           text not null default '',
  last_message_time      timestamptz,
  last_message_sender_id uuid references public.profiles (id),
  is_priority            boolean not null default false,
  created_at             timestamptz not null default now(),
  unique (participant_a, participant_b, property_id)
);
create index chats_a_idx on public.chats (participant_a);
create index chats_b_idx on public.chats (participant_b);
alter table public.chats enable row level security;
create policy "participants see their chats"
  on public.chats for select
  using (participant_a = auth.uid() or participant_b = auth.uid());
create policy "participants create chats"
  on public.chats for insert
  with check (participant_a = auth.uid() or participant_b = auth.uid());
create policy "participants update their chats"
  on public.chats for update
  using (participant_a = auth.uid() or participant_b = auth.uid());

-- ===== MESSAGES ==========================================================
create table public.messages (
  id             uuid primary key default gen_random_uuid(),
  chat_id        uuid not null references public.chats (id) on delete cascade,
  sender_id      uuid not null references public.profiles (id) on delete cascade,
  message        text not null default '',
  attachment_url text,
  type           text not null default 'text',
  duration_ms    int,
  latitude       double precision,
  longitude      double precision,
  is_read        boolean not null default false,
  created_at     timestamptz not null default now()
);
create index messages_chat_idx on public.messages (chat_id, created_at);
alter table public.messages enable row level security;
create policy "participants read messages"
  on public.messages for select using (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (c.participant_a = auth.uid() or c.participant_b = auth.uid())
    )
  );
create policy "sender sends messages"
  on public.messages for insert with check (sender_id = auth.uid());

-- ===== REPORTS ===========================================================
create table public.reports (
  id           uuid primary key default gen_random_uuid(),
  property_id  uuid not null references public.properties (id) on delete cascade,
  reporter_id  uuid not null references public.profiles (id) on delete cascade,
  reason       text not null default '',
  status       report_status not null default 'open',
  reviewed_by  uuid references public.profiles (id),
  created_at   timestamptz not null default now()
);
create index reports_property_idx on public.reports (property_id);
alter table public.reports enable row level security;
create policy "users file own reports"
  on public.reports for insert with check (reporter_id = auth.uid());
create policy "users read own reports"
  on public.reports for select using (reporter_id = auth.uid());

-- ===== NOTIFICATION SETTINGS =============================================
create table public.notification_settings (
  user_id         uuid primary key references public.profiles (id) on delete cascade,
  push_enabled    boolean not null default true,
  email_enabled   boolean not null default true,
  new_message     boolean not null default true,
  inquiry_updates boolean not null default true,
  listing_updates boolean not null default true,
  promotions      boolean not null default false,
  updated_at      timestamptz not null default now()
);
alter table public.notification_settings enable row level security;
create policy "users manage own notification settings"
  on public.notification_settings for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ===== STORAGE BUCKETS ===================================================
insert into storage.buckets (id, name, public) values
  ('property-images', 'property-images', true),
  ('avatars',         'avatars',         true),
  ('verification-docs','verification-docs', false)
on conflict (id) do nothing;

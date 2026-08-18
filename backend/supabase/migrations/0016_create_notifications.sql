-- ─────────────────────────────────────────────────────────────────────────
-- notifications  →  lib/models/notification_model.dart
-- Screens: notifications (inbox), home (unread badge).
--
-- The inbox was a hardcoded list in NotificationProvider, so it reset on every
-- launch and was identical for every user.
--
-- `kind` is stored instead of an icon: an icon is a Flutter value, and pinning
-- one in the database would freeze the app's iconography into old rows.
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  kind       text not null default 'system',
  title      text not null,
  message    text not null default '',
  is_read    boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_idx
  on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;

-- A notification belongs to exactly one user, and only that user may see it.
drop policy if exists notifications_select_own on public.notifications;
create policy notifications_select_own on public.notifications
  for select using (auth.uid() = user_id);

-- Inserting for yourself covers the in-app cases (verification approved, and
-- so on). Anything raised *for another user* is server-side work and runs
-- with the service_role key, which bypasses these policies.
drop policy if exists notifications_insert_own on public.notifications;
create policy notifications_insert_own on public.notifications
  for insert with check (auth.uid() = user_id);

drop policy if exists notifications_update_own on public.notifications;
create policy notifications_update_own on public.notifications
  for update using (auth.uid() = user_id);

drop policy if exists notifications_delete_own on public.notifications;
create policy notifications_delete_own on public.notifications
  for delete using (auth.uid() = user_id);

-- Lets the badge update without polling.
do $$
begin
  begin
    alter publication supabase_realtime add table public.notifications;
  exception when duplicate_object then null;
  end;
end $$;

-- ─────────────────────────────────────────────────────────────────────────
-- Storage buckets
--   property-images  → listing photos (create_listing / add_property)
--   avatars          → profile pictures (edit_profile)
--   verification-docs→ ID uploads (account_verification) — private
-- ─────────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values
  ('property-images', 'property-images', true),
  ('avatars',         'avatars',         true),
  ('verification-docs','verification-docs', false)
on conflict (id) do nothing;

-- TODO: storage RLS policies
--   property-images: owner can upload/delete under their own folder; public read
--   avatars: user can upload/delete own; public read
--   verification-docs: user uploads own; only user + admin can read

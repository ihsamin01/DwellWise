-- ───────────────────────────────────────────────────────────────────────
-- chat-attachments bucket → photos, voice notes and documents sent in chat.
-- ───────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('chat-attachments', 'chat-attachments', true)
on conflict (id) do nothing;

-- Upload and manage only your own folder.
drop policy if exists chat_attachments_insert_own on storage.objects;
create policy chat_attachments_insert_own on storage.objects
  for insert with check (
    bucket_id = 'chat-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists chat_attachments_update_own on storage.objects;
create policy chat_attachments_update_own on storage.objects
  for update using (
    bucket_id = 'chat-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists chat_attachments_delete_own on storage.objects;
create policy chat_attachments_delete_own on storage.objects
  for delete using (
    bucket_id = 'chat-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Read is open, matching the bucket being public: the object name is a
-- random timestamped path that only reaches the other participant through a
-- message row, which row-level security already restricts to the two of
-- them.
drop policy if exists chat_attachments_read on storage.objects;
create policy chat_attachments_read on storage.objects
  for select using (bucket_id = 'chat-attachments');

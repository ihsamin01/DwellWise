-- ─────────────────────────────────────────────────────────────────────────
-- chat-attachments bucket → photos, voice notes and documents sent in chat.
--
-- Attachments used to be sent as the sender's local file path, so the row
-- persisted but the file existed only on the device that sent it — the other
-- participant saw a broken reference, and so did the sender after a reinstall.
--
-- Files are stored under the sender's own id ('<uid>/<timestamp>.<ext>'),
-- which is what the policies below key off.
--
-- Safe to re-run.
-- ─────────────────────────────────────────────────────────────────────────

insert into storage.buckets (id, name, public)
values ('chat-attachments', 'chat-attachments', true)
on conflict (id) do nothing;

-- Upload and manage only your own folder. The first path segment is the
-- uploader's user id, so a user cannot write into anyone else's.
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

-- Read is open, matching the bucket being public: the object name is a random
-- timestamped path that only reaches the other participant through a message
-- row, which row-level security already restricts to the two of them.
drop policy if exists chat_attachments_read on storage.objects;
create policy chat_attachments_read on storage.objects
  for select using (bucket_id = 'chat-attachments');

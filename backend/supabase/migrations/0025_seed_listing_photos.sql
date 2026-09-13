-- ───────────────────────────────────────────────────────────────────────
-- Photos for the seeded listings.
--
-- 0018 and 0020 added listings without any, and the app no longer paints
-- a stock photo over an empty one — a real listing must never show a
-- building that is not the one being let. That left the seeded rows as
-- grey boxes in the feed, so they get their own photos here instead.
--
-- Scoped to the four demo owners, and only where there is no photo, so a
-- real owner's listing is never given a picture they did not take.
-- Each type gets a fitting shot, and rows of the same type cycle through
-- a few so the feed does not repeat one image down the page.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

with stock as (
  select *
  from (values
    ('Family',      0, 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=900&q=80'),
    ('Family',      1, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=900&q=80'),
    ('Family',      2, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=900&q=80'),
    ('Bachelor',    0, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=900&q=80'),
    ('Bachelor',    1, 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=900&q=80'),
    ('Bachelor',    2, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=900&q=80'),
    ('Sublet',      0, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=900&q=80'),
    ('Sublet',      1, 'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=900&q=80'),
    ('Sublet',      2, 'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?auto=format&fit=crop&w=900&q=80'),
    ('Hostel',      0, 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=900&q=80'),
    ('Hostel',      1, 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=900&q=80'),
    ('Hostel',      2, 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?auto=format&fit=crop&w=900&q=80'),
    ('Office room', 0, 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=900&q=80'),
    ('Office room', 1, 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=900&q=80'),
    ('Office room', 2, 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=900&q=80')
  ) as t(property_type, slot, url)
),
targets as (
  select id,
         property_type,
         (row_number() over (partition by property_type order by created_at, id) - 1) % 3 as slot
  from public.properties
  where image_urls = '{}'
    and owner_id in (
      'd0000000-0000-4000-8000-000000000001',
      'd0000000-0000-4000-8000-000000000002',
      'd0000000-0000-4000-8000-000000000003',
      'd0000000-0000-4000-8000-000000000004'
    )
)
update public.properties p
   set image_urls = array[s.url]
  from targets t
  join stock s
    on s.property_type = t.property_type
   and s.slot = t.slot
 where p.id = t.id;

-- Check: should report 0 seeded listings still without a photo.
select count(*) as seeded_without_photo
from public.properties
where image_urls = '{}'
  and owner_id in (
    'd0000000-0000-4000-8000-000000000001',
    'd0000000-0000-4000-8000-000000000002',
    'd0000000-0000-4000-8000-000000000003',
    'd0000000-0000-4000-8000-000000000004'
  );

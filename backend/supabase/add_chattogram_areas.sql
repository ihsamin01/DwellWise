-- ---------------------------------------------------------------------------
-- Adds listings for Chattogram places whose names also exist in Dhaka.
--
-- Without these rows, a user living at "Chawkbazar, Chattogram" got the Dhaka
-- Chawkbazar listings, because only Dhaka's copy of the name was seeded. The
-- app now filters by city as well, so these rows make the Chattogram side real.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ---------------------------------------------------------------------------

with areas(area, city, lat, lng) as (
  values
    ('Chawkbazar','Chattogram',22.3592,91.8340),
    ('Kotwali','Chattogram',22.3350,91.8330),
    ('New Market','Chattogram',22.3345,91.8318),
    ('Sadarghat','Chattogram',22.3190,91.8390)
)
delete from public.properties p
using areas a
where p.owner_id like 'o%'
  and lower(p.area) = lower(a.area)
  and p.address ilike '%' || a.city || '%';

with areas(area, city, lat, lng) as (
  values
    ('Chawkbazar','Chattogram',22.3592,91.8340),
    ('Kotwali','Chattogram',22.3350,91.8330),
    ('New Market','Chattogram',22.3345,91.8318),
    ('Sadarghat','Chattogram',22.3190,91.8390)
)
insert into public.properties (
  owner_id, title, description, price, price_for, property_type,
  area, address, latitude, longitude, beds, baths, balcony, size_sqft,
  available_from, included_bills, image_urls, facilities, is_verified,
  status, created_at
)
select
  (array['o1','o3','o5','o6','o7','o8','o9','o10','o12','o13'])[1 + floor(random() * 10)::int],
  (array[
    'Cozy Apartment in','Family Flat near','Modern 2-Bed in','Bachelor Sublet in',
    'Spacious Rental in','Furnished Flat in','Affordable Room in','Premium Apartment in',
    'Sunny Studio in','Well-lit Flat near','Peaceful Home in','Renovated Flat in'
  ])[1 + ((g - 1) % 12)] || ' ' || a.area,
  'A comfortable rental in ' || a.area || ', ' || a.city ||
    '. Close to local markets, transport and schools - ideal for anyone who wants to live around '
    || a.area || '.',
  (7 + floor(random() * 34)) * 1000,
  'Monthly',
  (array['Apartment','Sublet','Family','Studio'])[1 + floor(random() * 4)::int],
  a.area,
  'Block ' || chr(65 + floor(random() * 6)::int) || ', Road ' ||
    (1 + floor(random() * 20))::text || ', ' || a.area || ', ' || a.city,
  a.lat + (random() - 0.5) * 0.0018,
  a.lng + (random() - 0.5) * 0.0018,
  1 + floor(random() * 4)::int,
  1 + floor(random() * 3)::int,
  floor(random() * 3)::int,
  400 + floor(random() * 1400),
  (array['August','September','October','November'])[1 + floor(random() * 4)::int],
  case when random() < 0.5 then array['Gas bill'] else '{}'::text[] end,
  array[
    'https://images.unsplash.com/photo-' || (array[
      '1522708323590-d24dbb6b0267','1600585154340-be6161a56a0c','1560448204-e02f11c3d0e2',
      '1502672260266-1c1ef2d93688','1512917774080-9991f1c4c750','1493809842364-78817add7ffb',
      '1484154218962-a197022b5858','1567767292278-a4f21aa2d36e'
    ])[1 + floor(random() * 8)::int] || '?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-' || (array[
      '1522708323590-d24dbb6b0267','1600585154340-be6161a56a0c','1560448204-e02f11c3d0e2',
      '1502672260266-1c1ef2d93688','1512917774080-9991f1c4c750','1493809842364-78817add7ffb',
      '1484154218962-a197022b5858','1567767292278-a4f21aa2d36e'
    ])[1 + floor(random() * 8)::int] || '?auto=format&fit=crop&w=600&q=80'
  ],
  string_to_array((array[
    'Wifi,Gas,Security','Gas,Lift,Parking','Wifi,Lift,Backup,Security',
    'Gas,Parking,CCTV','Wifi,Gas,Lift,Parking','Gas,Security,Backup',
    'Wifi,Parking,Lift,CCTV','Gas,Wifi,Backup'
  ])[1 + floor(random() * 8)::int], ','),
  random() < 0.5,
  'approved',
  now() - ((g * 7 + floor(random() * 40)) || ' hours')::interval
from areas a, generate_series(1, 10) g;

-- Check: both cities' copies now exist.
select area,
       case when address ilike '%Chattogram%' then 'Chattogram' else 'Dhaka' end as city,
       count(*) as listings
from public.properties
where area in ('Chawkbazar','Kotwali','New Market','Sadarghat')
group by 1, 2
order by 1, 2;

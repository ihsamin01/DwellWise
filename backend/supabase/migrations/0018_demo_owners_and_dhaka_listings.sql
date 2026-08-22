-- ─────────────────────────────────────────────────────────────────────────
-- Demo owner accounts, and listings for the Dhaka areas the assistant is
-- most often asked about.
--
-- Why the accounts: the seeded listings carry owner ids like 'o10', which are
-- not real users. Messaging an owner creates a row in `chats` whose
-- participant is a profile, so "Message owner" could never work on them —
-- there was nobody on the other side. These owners are real accounts with
-- profiles, so the whole flow works end to end.
--
-- Why the listings: the catalogue is thin on sublets and office rooms around
-- Mirpur, ECB, Banani and Hatirjheel, so the assistant answered a sublet
-- request with family flats.
--
-- Demo passwords are deliberately obvious — these are sample accounts, not
-- anybody's real login.
--
-- Safe to re-run: every insert is guarded by `on conflict do nothing`.
-- ─────────────────────────────────────────────────────────────────────────

-- ── owner accounts ───────────────────────────────────────────────────────
-- Fixed uuids so re-running maps to the same owners and the listings below
-- keep pointing at them.
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data
)
values
  ('00000000-0000-0000-0000-000000000000',
   'd0000000-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'rumana.owner@dwellwise.demo',
   crypt('dwellwise123', gen_salt('bf')), now(), now(), now(),
   '{"provider":"email","providers":["email"]}',
   '{"name":"Rumana Chowdhury"}'),
  ('00000000-0000-0000-0000-000000000000',
   'd0000000-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'tanvir.owner@dwellwise.demo',
   crypt('dwellwise123', gen_salt('bf')), now(), now(), now(),
   '{"provider":"email","providers":["email"]}',
   '{"name":"Tanvir Hasan"}'),
  ('00000000-0000-0000-0000-000000000000',
   'd0000000-0000-4000-8000-000000000003',
   'authenticated', 'authenticated', 'shirin.owner@dwellwise.demo',
   crypt('dwellwise123', gen_salt('bf')), now(), now(), now(),
   '{"provider":"email","providers":["email"]}',
   '{"name":"Shirin Akter"}'),
  ('00000000-0000-0000-0000-000000000000',
   'd0000000-0000-4000-8000-000000000004',
   'authenticated', 'authenticated', 'jashim.owner@dwellwise.demo',
   crypt('dwellwise123', gen_salt('bf')), now(), now(), now(),
   '{"provider":"email","providers":["email"]}',
   '{"name":"Jashim Uddin"}')
on conflict (id) do nothing;

-- The profile trigger only fires on sign-up through the API, so the rows are
-- written here too.
insert into public.profiles (id, email, name, phone_number, role, verification_status)
values
  ('d0000000-0000-4000-8000-000000000001', 'rumana.owner@dwellwise.demo',
   'Rumana Chowdhury', '+8801711000001', 'owner', 'verified'),
  ('d0000000-0000-4000-8000-000000000002', 'tanvir.owner@dwellwise.demo',
   'Tanvir Hasan', '+8801711000002', 'owner', 'verified'),
  ('d0000000-0000-4000-8000-000000000003', 'shirin.owner@dwellwise.demo',
   'Shirin Akter', '+8801711000003', 'owner', 'unverified'),
  ('d0000000-0000-4000-8000-000000000004', 'jashim.owner@dwellwise.demo',
   'Jashim Uddin', '+8801711000004', 'owner', 'verified')
on conflict (id) do nothing;

-- ── listings ─────────────────────────────────────────────────────────────
-- Fixed ids again, so re-running updates nothing and duplicates nothing.
-- Coordinates match the area, so the assistant's radius search behaves.
insert into public.properties (
  id, owner_id, title, description, price, price_for, property_type,
  area, address, latitude, longitude, beds, baths, balcony, size_sqft,
  available_from, included_bills, image_urls, facilities, is_verified, status
)
values
  -- Mirpur 11 (23.8195, 90.3660)
  ('e0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001',
   'Sublet room in Mirpur 11', 'A furnished sublet room in a family building, close to Mirpur 11 bus stand. Suitable for a single tenant or a couple.',
   7000, 'Monthly', 'Sublet', 'Mirpur 11', 'Block C, Road 3, Mirpur 11, Dhaka',
   23.8195, 90.3660, 1, 1, 1, 320, 'September',
   '{"Gas bill","Water bill"}', '{}', '{GAS,CCTV}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000002',
   'Two-room sublet near Mirpur 11', 'Two rooms with an attached bathroom, shared kitchen. Lift in the building, gas line available.',
   11000, 'Monthly', 'Sublet', 'Mirpur 11', 'Block B, Road 7, Mirpur 11, Dhaka',
   23.8199, 90.3671, 2, 1, 1, 520, 'Immediately',
   '{"Gas bill"}', '{}', '{GAS,LIFT}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000003',
   'Bachelor seat in Mirpur 11', 'Seat in a bachelor mess, three to a room. Wifi and gas included in the rent.',
   4500, 'Monthly', 'Bachelor', 'Mirpur 11', 'Road 2, Mirpur 11, Dhaka',
   23.8188, 90.3655, 1, 1, 0, 200, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS}', false, 'approved'),

  ('e0000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000004',
   'Family flat in Mirpur 11', 'Three bedrooms with two balconies on the fifth floor. Lift, generator and parking.',
   26000, 'Monthly', 'Family', 'Mirpur 11', 'Block A, Road 1, Mirpur 11, Dhaka',
   23.8202, 90.3648, 3, 3, 2, 1250, 'October',
   '{"Gas bill","Service charge"}', '{}', '{GAS,LIFT,GARAGE,CCTV}', true, 'approved'),

  -- Mirpur 10 (23.8069, 90.3686)
  ('e0000000-0000-4000-8000-000000000005', 'd0000000-0000-4000-8000-000000000001',
   'Sublet near Mirpur 10 circle', 'One room sublet a two-minute walk from the metro station. Gas and water included.',
   8000, 'Monthly', 'Sublet', 'Mirpur 10', 'Road 4, Mirpur 10, Dhaka',
   23.8069, 90.3686, 1, 1, 1, 350, 'Immediately',
   '{"Gas bill","Water bill"}', '{}', '{GAS,LIFT}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000006', 'd0000000-0000-4000-8000-000000000002',
   'Office room in Mirpur 10', 'Ground-floor commercial space suitable for a small office or coaching centre.',
   18000, 'Monthly', 'Office room', 'Mirpur 10', 'Main Road, Mirpur 10, Dhaka',
   23.8074, 90.3692, 2, 2, 0, 700, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV,GARAGE}', true, 'approved'),

  -- ECB Chattar (23.8320, 90.3980)
  ('e0000000-0000-4000-8000-000000000007', 'd0000000-0000-4000-8000-000000000003',
   'Sublet room at ECB Chattar', 'Furnished room in a quiet building near ECB Chattar. Gas line and lift.',
   9000, 'Monthly', 'Sublet', 'ECB Chattar', 'ECB Chattar, Dhaka Cantonment, Dhaka',
   23.8320, 90.3980, 1, 1, 1, 380, 'Immediately',
   '{"Gas bill"}', '{}', '{GAS,LIFT,CCTV}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000008', 'd0000000-0000-4000-8000-000000000004',
   'Three-bedroom family flat, ECB Chattar', 'Three bedrooms, three bathrooms and two balconies. Gas line, lift and parking.',
   32000, 'Monthly', 'Family', 'ECB Chattar', 'Road 5, ECB Chattar, Dhaka',
   23.8325, 90.3988, 3, 3, 2, 1400, 'September',
   '{"Gas bill","Service charge"}', '{}', '{GAS,LIFT,GARAGE,CCTV}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000009', 'd0000000-0000-4000-8000-000000000001',
   'Family flat near ECB, two bedrooms', 'Two bedrooms with a large balcony, on a quiet lane off the main road.',
   19000, 'Monthly', 'Family', 'ECB Chattar', 'Manikdi, near ECB Chattar, Dhaka',
   23.8298, 90.3961, 2, 2, 1, 950, 'Immediately',
   '{"Gas bill"}', '{}', '{GAS,CCTV}', false, 'approved'),

  ('e0000000-0000-4000-8000-000000000010', 'd0000000-0000-4000-8000-000000000002',
   'Office space at ECB Chattar', 'Second-floor office with its own washroom, lift and generator backup.',
   24000, 'Monthly', 'Office room', 'ECB Chattar', 'ECB Chattar, Dhaka',
   23.8331, 90.3975, 3, 1, 0, 900, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV}', true, 'approved'),

  -- Banani (23.7937, 90.4066)
  ('e0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000003',
   'Sublet in Banani Block E', 'One furnished room with an attached bath in a shared flat. Lift and generator.',
   16000, 'Monthly', 'Sublet', 'Banani', 'Block E, Banani, Dhaka',
   23.7937, 90.4066, 1, 1, 1, 400, 'Immediately',
   '{"Service charge","Internet"}', '{}', '{LIFT,CCTV,GARAGE}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000012', 'd0000000-0000-4000-8000-000000000004',
   'Office room in Banani', 'Corner office suite on Kemal Ataturk Avenue, lift and round-the-clock security.',
   55000, 'Monthly', 'Office room', 'Banani', 'Kemal Ataturk Avenue, Banani, Dhaka',
   23.7942, 90.4058, 4, 2, 0, 1600, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV,GARAGE}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000013', 'd0000000-0000-4000-8000-000000000001',
   'Family apartment in Banani', 'Three bedrooms facing the lake, two balconies, gas line and reserved parking.',
   65000, 'Monthly', 'Family', 'Banani', 'Road 11, Banani, Dhaka',
   23.7929, 90.4074, 3, 3, 2, 1800, 'October',
   '{"Gas bill","Service charge"}', '{}', '{GAS,LIFT,GARAGE,CCTV}', true, 'approved'),

  -- Hatirjheel (23.7530, 90.4050)
  ('e0000000-0000-4000-8000-000000000014', 'd0000000-0000-4000-8000-000000000002',
   'Sublet beside Hatirjheel', 'Single room sublet overlooking the lake walkway. Gas and water included.',
   10000, 'Monthly', 'Sublet', 'Hatirjheel', 'Hatirjheel, Dhaka',
   23.7530, 90.4050, 1, 1, 1, 360, 'Immediately',
   '{"Gas bill","Water bill"}', '{}', '{GAS,LIFT}', true, 'approved'),

  ('e0000000-0000-4000-8000-000000000015', 'd0000000-0000-4000-8000-000000000003',
   'Bachelor mess near Hatirjheel', 'Bachelor accommodation, two seats free. Wifi, gas and cleaning included.',
   5500, 'Monthly', 'Bachelor', 'Hatirjheel', 'Ulon Road, Hatirjheel, Dhaka',
   23.7541, 90.4062, 1, 1, 0, 220, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS}', false, 'approved'),

  ('e0000000-0000-4000-8000-000000000016', 'd0000000-0000-4000-8000-000000000004',
   'Two-bedroom family flat, Hatirjheel', 'Two bedrooms and a balcony facing the water. Lift, gas line, parking.',
   28000, 'Monthly', 'Family', 'Hatirjheel', 'Hatirjheel, Dhaka',
   23.7522, 90.4041, 2, 2, 1, 1050, 'September',
   '{"Gas bill","Service charge"}', '{}', '{GAS,LIFT,GARAGE}', true, 'approved')
on conflict (id) do nothing;

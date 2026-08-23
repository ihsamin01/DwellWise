-- ───────────────────────────────────────────────────────────────────────
-- Fills out the Dhaka areas the assistant is asked about, so every kind of
-- request finds something. Two gaps are deliberate: Mirpur 12 has no office
-- room and Uttara has none either, which is what makes the assistant widen
-- its search and offer Mirpur DOHS (0.8 km away) instead.
--
-- Owners are the demo accounts from 0018, so every listing can be messaged
-- and called. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

insert into public.properties (
  id, owner_id, title, description, price, price_for, property_type,
  area, address, latitude, longitude, beds, baths, balcony, size_sqft,
  available_from, included_bills, image_urls, facilities, is_verified, status
)
values
  -- Mirpur 12 (23.8285, 90.3640) — no office room here, on purpose.
  ('f0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001',
   'Bachelor mess in Mirpur 12', 'Four seats in a clean bachelor mess near Mirpur 12 bus stand. Cook and cleaner included.',
   5000, 'Monthly', 'Bachelor', 'Mirpur 12', 'Block C, Mirpur 12, Dhaka',
   23.8285, 90.3640, 1, 1, 0, 220, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS}', false, 'approved'),

  ('f0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000002',
   'Student hostel seat, Mirpur 12', 'Hostel for students, two per room, study desk and wifi in every room.',
   4200, 'Monthly', 'Hostel', 'Mirpur 12', 'Road 5, Mirpur 12, Dhaka',
   23.8291, 90.3648, 1, 1, 0, 180, 'Immediately',
   '{"Gas bill","Water bill","Internet"}', '{}', '{GAS,CCTV}', false, 'approved'),

  ('f0000000-0000-4000-8000-000000000003', 'd0000000-0000-4000-8000-000000000003',
   'Two-bedroom family flat, Mirpur 12', 'Second floor, two bedrooms and a balcony. Gas line and lift in the building.',
   17000, 'Monthly', 'Family', 'Mirpur 12', 'Block B, Road 2, Mirpur 12, Dhaka',
   23.8279, 90.3633, 2, 2, 1, 900, 'September',
   '{"Gas bill"}', '{}', '{GAS,LIFT}', true, 'approved'),

  -- Mirpur DOHS (23.8285, 90.3720) — 0.8 km from Mirpur 12, and this is
  -- where the office rooms are.
  ('f0000000-0000-4000-8000-000000000004', 'd0000000-0000-4000-8000-000000000004',
   'Office room in Mirpur DOHS', 'Quiet first-floor office in a residential building. Lift, generator and parking.',
   26000, 'Monthly', 'Office room', 'Mirpur DOHS', 'Avenue 3, Mirpur DOHS, Dhaka',
   23.8285, 90.3720, 3, 2, 0, 850, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,GARAGE,CCTV}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000005', 'd0000000-0000-4000-8000-000000000001',
   'Small office space, Mirpur DOHS', 'Two-room office suitable for a startup or a chamber. Wifi ready.',
   16000, 'Monthly', 'Office room', 'Mirpur DOHS', 'Avenue 5, Mirpur DOHS, Dhaka',
   23.8292, 90.3728, 2, 1, 0, 550, 'Immediately',
   '{"Service charge","Internet"}', '{}', '{LIFT,CCTV}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000006', 'd0000000-0000-4000-8000-000000000002',
   'Bachelor seat in Mirpur DOHS', 'Seat in a shared flat with two others. Quiet, secure neighbourhood.',
   7500, 'Monthly', 'Bachelor', 'Mirpur DOHS', 'Avenue 1, Mirpur DOHS, Dhaka',
   23.8277, 90.3713, 1, 1, 0, 240, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS,CCTV}', false, 'approved'),

  -- Uttara (23.8759, 90.3795) — also left without an office room.
  ('f0000000-0000-4000-8000-000000000007', 'd0000000-0000-4000-8000-000000000003',
   'Bachelor mess in Uttara Sector 7', 'Mess for working bachelors, three seats free. Meals available.',
   6500, 'Monthly', 'Bachelor', 'Uttara', 'Sector 7, Uttara, Dhaka',
   23.8759, 90.3795, 1, 1, 0, 250, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS,LIFT}', false, 'approved'),

  ('f0000000-0000-4000-8000-000000000008', 'd0000000-0000-4000-8000-000000000004',
   'Girls hostel, Uttara Sector 4', 'Hostel for female students with a common room and round-the-clock security.',
   7000, 'Monthly', 'Hostel', 'Uttara', 'Sector 4, Uttara, Dhaka',
   23.8741, 90.3802, 1, 1, 0, 200, 'Immediately',
   '{"Gas bill","Water bill","Internet"}', '{}', '{GAS,LIFT,CCTV}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000009', 'd0000000-0000-4000-8000-000000000001',
   'Sublet room in Uttara Sector 11', 'One furnished room with attached bath in a family flat.',
   12000, 'Monthly', 'Sublet', 'Uttara', 'Sector 11, Uttara, Dhaka',
   23.8772, 90.3781, 1, 1, 1, 380, 'Immediately',
   '{"Gas bill"}', '{}', '{GAS,LIFT}', true, 'approved'),

  -- ECB Chattar (23.8320, 90.3980)
  ('f0000000-0000-4000-8000-000000000010', 'd0000000-0000-4000-8000-000000000002',
   'Bachelor seat near ECB Chattar', 'Seat in a bachelor flat, walking distance from ECB Chattar.',
   6000, 'Monthly', 'Bachelor', 'ECB Chattar', 'Manikdi, ECB Chattar, Dhaka',
   23.8312, 90.3972, 1, 1, 0, 230, 'Immediately',
   '{"Gas bill"}', '{}', '{GAS}', false, 'approved'),

  ('f0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000003',
   'Hostel seat at ECB Chattar', 'Student hostel, three to a room, meals included in the rent.',
   4800, 'Monthly', 'Hostel', 'ECB Chattar', 'ECB Chattar, Dhaka',
   23.8328, 90.3989, 1, 1, 0, 190, 'Immediately',
   '{"Gas bill","Water bill"}', '{}', '{GAS,CCTV}', false, 'approved'),

  -- Mirpur 11 (23.8195, 90.3660)
  ('f0000000-0000-4000-8000-000000000012', 'd0000000-0000-4000-8000-000000000004',
   'Office room in Mirpur 11', 'Ground floor space on the main road, suitable for an office or showroom.',
   20000, 'Monthly', 'Office room', 'Mirpur 11', 'Main Road, Mirpur 11, Dhaka',
   23.8201, 90.3667, 2, 2, 0, 720, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV,GARAGE}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000013', 'd0000000-0000-4000-8000-000000000001',
   'Hostel seat in Mirpur 11', 'Hostel for students near the school, wifi and gas included.',
   4300, 'Monthly', 'Hostel', 'Mirpur 11', 'Road 3, Mirpur 11, Dhaka',
   23.8189, 90.3652, 1, 1, 0, 185, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS}', false, 'approved'),

  -- Mirpur 10 (23.8069, 90.3686)
  ('f0000000-0000-4000-8000-000000000014', 'd0000000-0000-4000-8000-000000000002',
   'Bachelor mess near Mirpur 10', 'Mess close to the metro station, two seats free this month.',
   5200, 'Monthly', 'Bachelor', 'Mirpur 10', 'Road 2, Mirpur 10, Dhaka',
   23.8062, 90.3679, 1, 1, 0, 210, 'Immediately',
   '{"Gas bill","Internet"}', '{}', '{GAS}', false, 'approved'),

  ('f0000000-0000-4000-8000-000000000015', 'd0000000-0000-4000-8000-000000000003',
   'Hostel seat, Mirpur 10', 'Student hostel with study room, walking distance from the circle.',
   4600, 'Monthly', 'Hostel', 'Mirpur 10', 'Mirpur 10, Dhaka',
   23.8076, 90.3693, 1, 1, 0, 195, 'Immediately',
   '{"Gas bill","Water bill"}', '{}', '{GAS,CCTV}', false, 'approved'),

  -- Gulshan (23.7925, 90.4078)
  ('f0000000-0000-4000-8000-000000000016', 'd0000000-0000-4000-8000-000000000004',
   'Family apartment in Gulshan 2', 'Three bedrooms with two balconies, lift, generator and reserved parking.',
   85000, 'Monthly', 'Family', 'Gulshan', 'Road 45, Gulshan 2, Dhaka',
   23.7925, 90.4078, 3, 3, 2, 2000, 'October',
   '{"Gas bill","Service charge"}', '{}', '{GAS,LIFT,GARAGE,CCTV}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000017', 'd0000000-0000-4000-8000-000000000001',
   'Office floor in Gulshan 1', 'Full floor office with a reception area, lift and standby generator.',
   120000, 'Monthly', 'Office room', 'Gulshan', 'Gulshan 1 Circle, Dhaka',
   23.7809, 90.4152, 5, 3, 0, 2600, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,GARAGE,CCTV}', true, 'approved'),

  -- Dhanmondi (23.7461, 90.3742)
  ('f0000000-0000-4000-8000-000000000018', 'd0000000-0000-4000-8000-000000000002',
   'Sublet room in Dhanmondi 27', 'Furnished room with attached bath in a family flat near the lake.',
   15000, 'Monthly', 'Sublet', 'Dhanmondi', 'Road 27, Dhanmondi, Dhaka',
   23.7461, 90.3742, 1, 1, 1, 400, 'Immediately',
   '{"Gas bill","Service charge"}', '{}', '{GAS,LIFT}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000019', 'd0000000-0000-4000-8000-000000000003',
   'Chamber space in Dhanmondi', 'Small office suitable for a doctor''s chamber or a consultancy.',
   35000, 'Monthly', 'Office room', 'Dhanmondi', 'Road 8A, Dhanmondi, Dhaka',
   23.7448, 90.3731, 2, 2, 0, 700, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV,GARAGE}', true, 'approved'),

  -- New Market (23.7335, 90.3850)
  ('f0000000-0000-4000-8000-000000000020', 'd0000000-0000-4000-8000-000000000004',
   'Family flat near New Market', 'Two bedrooms in a quiet lane, minutes from New Market and the university.',
   22000, 'Monthly', 'Family', 'New Market', 'Nilkhet Road, New Market, Dhaka',
   23.7335, 90.3850, 2, 2, 1, 950, 'September',
   '{"Gas bill"}', '{}', '{GAS,LIFT}', true, 'approved'),

  ('f0000000-0000-4000-8000-000000000021', 'd0000000-0000-4000-8000-000000000001',
   'Office room at New Market', 'First-floor commercial space facing the main road.',
   28000, 'Monthly', 'Office room', 'New Market', 'New Market, Dhaka',
   23.7341, 90.3843, 2, 1, 0, 650, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV}', true, 'approved'),

  -- Lalbagh, old Dhaka (23.7185, 90.3880)
  ('f0000000-0000-4000-8000-000000000022', 'd0000000-0000-4000-8000-000000000002',
   'Sublet room in Lalbagh', 'One room in an old Dhaka family house, near Lalbagh Fort.',
   6500, 'Monthly', 'Sublet', 'Lalbagh', 'Lalbagh, Dhaka',
   23.7185, 90.3880, 1, 1, 0, 260, 'Immediately',
   '{"Gas bill","Water bill"}', '{}', '{GAS}', false, 'approved'),

  ('f0000000-0000-4000-8000-000000000023', 'd0000000-0000-4000-8000-000000000003',
   'Family flat in old Dhaka', 'Three rooms on a quiet lane, gas line and water reserve.',
   16000, 'Monthly', 'Family', 'Lalbagh', 'Nawabganj, Lalbagh, Dhaka',
   23.7192, 90.3871, 3, 2, 1, 1000, 'Immediately',
   '{"Gas bill","Water bill"}', '{}', '{GAS}', false, 'approved'),

  -- Hatirjheel (23.7530, 90.4050)
  ('f0000000-0000-4000-8000-000000000024', 'd0000000-0000-4000-8000-000000000004',
   'Office room beside Hatirjheel', 'Second-floor office overlooking the lake, lift and generator.',
   32000, 'Monthly', 'Office room', 'Hatirjheel', 'Hatirjheel, Dhaka',
   23.7536, 90.4057, 3, 2, 0, 800, 'Immediately',
   '{"Service charge"}', '{}', '{LIFT,CCTV,GARAGE}', true, 'approved')
on conflict (id) do nothing;

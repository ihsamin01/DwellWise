-- ---------------------------------------------------------------------------
-- DwellWise - real rental listings for every supported area (8 divisions).
-- Run ONCE in Supabase Dashboard -> SQL Editor. Safe to re-run: it clears the
-- previously seeded rows first.
--
-- Part 1 relaxes properties.owner_id so demo owner ids ('o1', 'o3', ...) from
-- the in-app owner directory can be stored; the FK to profiles only made sense
-- once every owner is a real signed-up user.
-- ---------------------------------------------------------------------------

-- ===== Part 1: schema =====================================================
-- The RLS policies below reference owner_id, so Postgres will not let us change
-- the column type while they exist: drop them, alter, then recreate them
-- against the text column (auth.uid() now needs an explicit ::text cast).
drop policy if exists "approved properties are public; owners see their own" on public.properties;
drop policy if exists "owners insert own properties" on public.properties;
drop policy if exists "owners update own properties" on public.properties;
drop policy if exists "owners delete own properties" on public.properties;

alter table public.properties
  drop constraint if exists properties_owner_id_fkey;

alter table public.properties
  alter column owner_id type text using owner_id::text;

create policy "approved properties are public; owners see their own"
  on public.properties for select
  using (status = 'approved' or owner_id = auth.uid()::text);
create policy "owners insert own properties"
  on public.properties for insert with check (owner_id = auth.uid()::text);
create policy "owners update own properties"
  on public.properties for update using (owner_id = auth.uid()::text);
create policy "owners delete own properties"
  on public.properties for delete using (owner_id = auth.uid()::text);

-- ===== Part 2: seed =======================================================
delete from public.properties where owner_id like 'o%';

with areas(area, city, lat, lng) as (
  values
    ('Dhaka','',23.8103,90.4125),
    ('Banani','Dhaka',23.7937,90.4066),
    ('Banani DOHS','Dhaka',23.7965,90.3998),
    ('Gulshan','Dhaka',23.7925,90.4078),
    ('Gulshan 1','Dhaka',23.7806,90.4143),
    ('Gulshan 2','Dhaka',23.7947,90.4145),
    ('Niketan','Dhaka',23.7815,90.4118),
    ('Baridhara','Dhaka',23.8043,90.4181),
    ('Bashundhara','Dhaka',23.8203,90.4288),
    ('Bashundhara R/A','Dhaka',23.8203,90.4288),
    ('Uttara','Dhaka',23.8759,90.3795),
    ('Uttara East','Dhaka',23.8687,90.4009),
    ('Uttara West','Dhaka',23.8759,90.3667),
    ('Airport','Dhaka',23.8433,90.3978),
    ('Khilkhet','Dhaka',23.8290,90.4203),
    ('Nikunja','Dhaka',23.8275,90.4212),
    ('Vatara','Dhaka',23.8060,90.4260),
    ('Badda','Dhaka',23.7806,90.4258),
    ('Middle Badda','Dhaka',23.7818,90.4247),
    ('North Badda','Dhaka',23.7877,90.4258),
    ('South Badda','Dhaka',23.7742,90.4249),
    ('Merul Badda','Dhaka',23.7690,90.4230),
    ('Aftabnagar','Dhaka',23.7625,90.4380),
    ('Rampura','Dhaka',23.7614,90.4180),
    ('Banasree','Dhaka',23.7605,90.4285),
    ('Khilgaon','Dhaka',23.7500,90.4260),
    ('Goran','Dhaka',23.7455,90.4310),
    ('Basabo','Dhaka',23.7392,90.4290),
    ('Mugda','Dhaka',23.7381,90.4243),
    ('Motijheel','Dhaka',23.7330,90.4172),
    ('Arambagh','Dhaka',23.7345,90.4155),
    ('Kamalapur','Dhaka',23.7325,90.4265),
    ('Paltan','Dhaka',23.7345,90.4120),
    ('Purana Paltan','Dhaka',23.7337,90.4122),
    ('Naya Paltan','Dhaka',23.7382,90.4148),
    ('Segunbagicha','Dhaka',23.7365,90.4062),
    ('Ramna','Dhaka',23.7380,90.4010),
    ('Eskaton','Dhaka',23.7480,90.4030),
    ('Kakrail','Dhaka',23.7385,90.4090),
    ('Siddheswari','Dhaka',23.7420,90.4055),
    ('Moghbazar','Dhaka',23.7480,90.4085),
    ('Hatirjheel','Dhaka',23.7530,90.4050),
    ('Tejgaon','Dhaka',23.7639,90.3936),
    ('Farmgate','Dhaka',23.7580,90.3893),
    ('Nakhalpara','Dhaka',23.7660,90.3930),
    ('Agargaon','Dhaka',23.7770,90.3780),
    ('Sher-e-bangla Nagar','Dhaka',23.7745,90.3782),
    ('Mohammadpur','Dhaka',23.7590,90.3595),
    ('Shyamoli','Dhaka',23.7740,90.3660),
    ('Adabor','Dhaka',23.7745,90.3560),
    ('Bosila','Dhaka',23.7530,90.3450),
    ('Dhanmondi','Dhaka',23.7461,90.3742),
    ('Dhanmondi 27','Dhaka',23.7530,90.3740),
    ('Dhanmondi 32','Dhaka',23.7513,90.3760),
    ('Jigatola','Dhaka',23.7395,90.3735),
    ('Kalabagan','Dhaka',23.7480,90.3830),
    ('Panthapath','Dhaka',23.7520,90.3870),
    ('Green Road','Dhaka',23.7500,90.3840),
    ('Hazaribagh','Dhaka',23.7355,90.3630),
    ('Lalbagh','Dhaka',23.7185,90.3880),
    ('Azimpur','Dhaka',23.7300,90.3860),
    ('New Market','Dhaka',23.7335,90.3850),
    ('Nilkhet','Dhaka',23.7330,90.3872),
    ('Elephant Road','Dhaka',23.7390,90.3860),
    ('Shahbagh','Dhaka',23.7385,90.3955),
    ('Kotwali','Dhaka',23.7100,90.4090),
    ('Sadarghat','Dhaka',23.7060,90.4110),
    ('Wari','Dhaka',23.7175,90.4180),
    ('Sutrapur','Dhaka',23.7085,90.4190),
    ('Gendaria','Dhaka',23.7080,90.4230),
    ('Bangshal','Dhaka',23.7200,90.4050),
    ('Chawkbazar','Dhaka',23.7180,90.3960),
    ('Jatrabari','Dhaka',23.7100,90.4360),
    ('Demra','Dhaka',23.7150,90.4830),
    ('Shyampur','Dhaka',23.6960,90.4360),
    ('Kadamtali','Dhaka',23.7000,90.4300),
    ('Kamrangirchar','Dhaka',23.7160,90.3720),
    ('Mirpur','Dhaka',23.8223,90.3654),
    ('Mirpur 1','Dhaka',23.7980,90.3540),
    ('Mirpur 2','Dhaka',23.8060,90.3630),
    ('Mirpur 6','Dhaka',23.8110,90.3660),
    ('Mirpur 10','Dhaka',23.8069,90.3686),
    ('Mirpur 11','Dhaka',23.8195,90.3660),
    ('Mirpur 12','Dhaka',23.8285,90.3640),
    ('Mirpur 13','Dhaka',23.8180,90.3760),
    ('Mirpur 14','Dhaka',23.8100,90.3830),
    ('Mirpur DOHS','Dhaka',23.8285,90.3720),
    ('Pallabi','Dhaka',23.8240,90.3650),
    ('Kalshi','Dhaka',23.8250,90.3800),
    ('Rupnagar','Dhaka',23.8225,90.3555),
    ('Kazipara','Dhaka',23.7970,90.3720),
    ('Sheorapara','Dhaka',23.7930,90.3720),
    ('Kafrul','Dhaka',23.7920,90.3860),
    ('Ibrahimpur','Dhaka',23.7975,90.3855),
    ('Bhashantek','Dhaka',23.8095,90.3900),
    ('Cantonment','Dhaka',23.7997,90.3966),
    ('Dhaka Cantonment','Dhaka',23.7997,90.3966),
    ('Shah Ali','Dhaka',23.8140,90.3560),
    ('Turag','Dhaka',23.8760,90.3540),
    ('Dakshinkhan','Dhaka',23.8720,90.4110),
    ('Uttarkhan','Dhaka',23.8830,90.4120),
    ('Ashkona','Dhaka',23.8570,90.4030),
    ('Savar','Dhaka',23.8583,90.2667),
    ('Ashulia','Dhaka',23.8930,90.3170),
    ('Hemayetpur','Dhaka',23.8000,90.2760),
    ('Keraniganj','Dhaka',23.7000,90.3800),
    ('Dohar','Dhaka',23.5800,90.1000),
    ('Nawabganj','Dhaka',23.6100,90.1600),
    ('Dhamrai','Dhaka',23.9100,90.2200),
    ('Gazipur','',23.9999,90.4203),
    ('Joydebpur','',24.0000,90.4200),
    ('Tongi','',23.8900,90.4030),
    ('Kaliakair','',24.0700,90.2200),
    ('Sreepur','',24.1900,90.4700),
    ('Narayanganj','',23.6238,90.5000),
    ('Chashara','',23.6250,90.5000),
    ('Fatullah','',23.6300,90.4900),
    ('Siddhirganj','',23.6700,90.5200),
    ('Sonargaon','',23.6480,90.6000),
    ('Rupganj','',23.7700,90.5300),
    ('Narsingdi','',23.9200,90.7150),
    ('Munshiganj','',23.5422,90.5305),
    ('Manikganj','',23.8600,90.0000),
    ('Tangail','',24.2513,89.9167),
    ('Kishoreganj','',24.4449,90.7766),
    ('Bhairab','',24.0500,90.9800),
    ('Faridpur','',23.6070,89.8429),
    ('Madaripur','',23.1641,90.1897),
    ('Shariatpur','',23.2423,90.4348),
    ('Rajbari','',23.7574,89.6444),
    ('Gopalganj','',23.0050,89.8266),
    ('Chattogram','',22.3569,91.7832),
    ('Chittagong','Chattogram',22.3569,91.7832),
    ('Agrabad','Chattogram',22.3280,91.8123),
    ('Nasirabad','Chattogram',22.3690,91.8100),
    ('Panchlaish','Chattogram',22.3630,91.8290),
    ('Khulshi','Chattogram',22.3600,91.8100),
    ('Halishahar','Chattogram',22.3200,91.7800),
    ('Chandgaon','Chattogram',22.3720,91.8480),
    ('Bayazid','Chattogram',22.3800,91.8200),
    ('Pahartali','Chattogram',22.3550,91.7300),
    ('Patenga','Chattogram',22.2300,91.7900),
    ('Bakalia','Chattogram',22.3450,91.8500),
    ('Double Mooring','Chattogram',22.3300,91.8100),
    ('Jamal Khan','Chattogram',22.3400,91.8300),
    ('Lalkhan Bazar','Chattogram',22.3480,91.8180),
    ('Oxygen','Chattogram',22.3830,91.8060),
    ('Muradpur','Chattogram',22.3660,91.8330),
    ('Coxs Bazar','Chattogram',21.4272,92.0058),
    ('Kolatoli','Chattogram',21.4200,91.9900),
    ('Cumilla','Chattogram',23.4607,91.1809),
    ('Comilla','Chattogram',23.4607,91.1809),
    ('Kandirpar','Chattogram',23.4600,91.1800),
    ('Brahmanbaria','Chattogram',23.9571,91.1115),
    ('Chandpur','Chattogram',23.2333,90.6667),
    ('Feni','Chattogram',23.0159,91.3976),
    ('Noakhali','Chattogram',22.8696,91.0995),
    ('Maijdee','Chattogram',22.8400,91.1000),
    ('Lakshmipur','Chattogram',22.9447,90.8282),
    ('Bandarban','Chattogram',22.1953,92.2184),
    ('Rangamati','Chattogram',22.6533,92.1750),
    ('Khagrachhari','Chattogram',23.1193,91.9847),
    ('Rajshahi','',24.3745,88.6042),
    ('Shaheb Bazar','Rajshahi',24.3670,88.6030),
    ('Boalia','Rajshahi',24.3700,88.6000),
    ('Motihar','Rajshahi',24.3600,88.6400),
    ('Rajpara','Rajshahi',24.3800,88.5900),
    ('Bogura','Rajshahi',24.8465,89.3773),
    ('Bogra','Rajshahi',24.8465,89.3773),
    ('Satmatha','Rajshahi',24.8500,89.3700),
    ('Pabna','Rajshahi',24.0064,89.2372),
    ('Sirajganj','Rajshahi',24.4533,89.7006),
    ('Natore','Rajshahi',24.4206,89.0003),
    ('Naogaon','Rajshahi',24.7936,88.9318),
    ('Joypurhat','Rajshahi',25.0968,89.0227),
    ('Chapainawabganj','Rajshahi',24.5965,88.2775),
    ('Khulna','',22.8456,89.5403),
    ('Sonadanga','Khulna',22.8100,89.5400),
    ('Khalishpur','Khulna',22.8500,89.5300),
    ('Daulatpur','Khulna',22.8800,89.5300),
    ('Boyra','Khulna',22.8200,89.5300),
    ('Jashore','Khulna',23.1664,89.2081),
    ('Jessore','Khulna',23.1664,89.2081),
    ('Kushtia','Khulna',23.9013,89.1206),
    ('Satkhira','Khulna',22.7185,89.0705),
    ('Bagerhat','Khulna',22.6516,89.7856),
    ('Jhenaidah','Khulna',23.5450,89.1726),
    ('Magura','Khulna',23.4855,89.4198),
    ('Narail','Khulna',23.1725,89.5122),
    ('Chuadanga','Khulna',23.6402,88.8412),
    ('Meherpur','Khulna',23.7622,88.6318),
    ('Mongla','Khulna',22.4900,89.6000),
    ('Barishal','',22.7010,90.3535),
    ('Barisal','Barishal',22.7010,90.3535),
    ('Sadar Road','Barishal',22.7020,90.3520),
    ('Nathullabad','Barishal',22.7180,90.3550),
    ('Patuakhali','Barishal',22.3596,90.3299),
    ('Kuakata','Barishal',21.8200,90.1200),
    ('Bhola','Barishal',22.6859,90.6482),
    ('Pirojpur','Barishal',22.5841,89.9720),
    ('Jhalokathi','Barishal',22.6406,90.1987),
    ('Barguna','Barishal',22.1550,90.1266),
    ('Sylhet','',24.8949,91.8687),
    ('Zindabazar','Sylhet',24.8950,91.8680),
    ('Ambarkhana','Sylhet',24.9050,91.8700),
    ('Uposhohor','Sylhet',24.8880,91.8770),
    ('Tilagor','Sylhet',24.9000,91.9000),
    ('Subid Bazar','Sylhet',24.9060,91.8760),
    ('Moulvibazar','Sylhet',24.4829,91.7774),
    ('Sreemangal','Sylhet',24.3065,91.7296),
    ('Habiganj','Sylhet',24.3745,91.4155),
    ('Sunamganj','Sylhet',25.0658,91.3950),
    ('Rangpur','',25.7439,89.2752),
    ('Dhap','Rangpur',25.7480,89.2500),
    ('Dinajpur','Rangpur',25.6217,88.6354),
    ('Gaibandha','Rangpur',25.3288,89.5281),
    ('Kurigram','Rangpur',25.8072,89.6362),
    ('Lalmonirhat','Rangpur',25.9923,89.2847),
    ('Nilphamari','Rangpur',25.9317,88.8560),
    ('Saidpur','Rangpur',25.7770,88.8920),
    ('Panchagarh','Rangpur',26.3411,88.5542),
    ('Thakurgaon','Rangpur',26.0337,88.4616),
    ('Mymensingh','',24.7471,90.4203),
    ('Ganginar Par','Mymensingh',24.7500,90.4050),
    ('Trishal','Mymensingh',24.5800,90.3900),
    ('Bhaluka','Mymensingh',24.3800,90.4000),
    ('Jamalpur','Mymensingh',24.9375,89.9372),
    ('Netrokona','Mymensingh',24.8830,90.7270),
    ('Sherpur','Mymensingh',25.0205,90.0153)
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
  'A comfortable rental in ' || a.area ||
    case when a.city <> '' then ', ' || a.city else '' end ||
    '. Close to local markets, transport and schools - ideal for anyone who wants to live around '
    || a.area || '.',
  (7 + floor(random() * 34)) * 1000,
  'Monthly',
  (array['Apartment','Sublet','Family','Studio'])[1 + floor(random() * 4)::int],
  a.area,
  'Block ' || chr(65 + floor(random() * 6)::int) || ', Road ' ||
    (1 + floor(random() * 20))::text || ', ' || a.area ||
    case when a.city <> '' then ', ' || a.city else '' end,
  -- Jitter ~±100 m so the pin sits on the area the address names without every
  -- listing stacking on one identical point.
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

-- ===== Part 3: check ======================================================
select count(*) as total_listings, count(distinct area) as areas from public.properties;

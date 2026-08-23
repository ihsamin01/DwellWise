-- ───────────────────────────────────────────────────────────────────────
-- Gives every listing an owner who is a real account, spread across the
-- demo owners from 0018 by a hash of the listing id so the mapping is
-- stable.
-- ───────────────────────────────────────────────────────────────────────

update public.properties p
   set owner_id = owners.id::text
  from (
    select id, row_number() over (order by email) - 1 as slot
      from public.profiles
     where email like '%@dwellwise.demo'
  ) as owners
 where owners.slot = abs(hashtext(p.id::text)) % 4
   and not exists (
     select 1 from public.profiles pr where pr.id::text = p.owner_id::text
   );

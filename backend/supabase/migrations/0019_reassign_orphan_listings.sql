-- ─────────────────────────────────────────────────────────────────────────
-- Gives every listing an owner who is a real account.
--
-- The seeded catalogue carries owner ids like 'o10' — placeholders, not
-- users. A conversation needs a profile on the other side, so "Message owner"
-- could not work on any of them, and the name shown on the listing came from
-- a lookup table in the app rather than from anybody's account.
--
-- Listings are spread across the four demo owners from 0018 by a hash of
-- their id, so the assignment is stable: re-running maps each listing to the
-- same owner rather than shuffling them.
--
-- Only touches rows whose owner is not already an account, so real listings
-- posted through the app are left alone. owner_id holds text (the seed put
-- 'o10' in it), hence the cast.
-- ─────────────────────────────────────────────────────────────────────────

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

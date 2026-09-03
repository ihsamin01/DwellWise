-- ───────────────────────────────────────────────────────────────────────
-- Let the demo owner accounts sign in.
--
-- 0018 inserted the four demo owners straight into auth.users with only
-- the columns it cared about. The token columns it left out stayed NULL,
-- and the auth server reads them as plain strings — so signing in as one
-- of them failed with "Database error querying schema" rather than a
-- wrong-password error. Every account made through the app's own sign-up
-- has these set to an empty string, which is what this restores.
--
-- Only the demo accounts are touched, and only where a value is missing,
-- so a real account is never rewritten.
--
-- Run in Supabase Dashboard -> SQL Editor. Safe to re-run.
-- ───────────────────────────────────────────────────────────────────────

update auth.users
   set confirmation_token         = coalesce(confirmation_token, ''),
       recovery_token             = coalesce(recovery_token, ''),
       email_change               = coalesce(email_change, ''),
       email_change_token_new     = coalesce(email_change_token_new, ''),
       email_change_token_current = coalesce(email_change_token_current, ''),
       phone_change               = coalesce(phone_change, ''),
       phone_change_token         = coalesce(phone_change_token, ''),
       reauthentication_token     = coalesce(reauthentication_token, ''),
       email_confirmed_at         = coalesce(email_confirmed_at, now())
 where email like '%@dwellwise.demo';

-- Check: every column below should read 0.
select count(*) filter (where confirmation_token is null)         as confirmation_null,
       count(*) filter (where recovery_token is null)             as recovery_null,
       count(*) filter (where email_change is null)               as email_change_null,
       count(*) filter (where email_change_token_new is null)     as change_new_null,
       count(*) filter (where email_change_token_current is null) as change_current_null,
       count(*) filter (where phone_change is null)               as phone_change_null,
       count(*) filter (where phone_change_token is null)         as phone_token_null,
       count(*) filter (where reauthentication_token is null)     as reauth_null
  from auth.users
 where email like '%@dwellwise.demo';

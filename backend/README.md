# DwellWise — Backend (Supabase)

This folder holds the **Supabase backend** for the DwellWise property-rental app.
Nothing is wired up yet — these are scaffolds/stubs so the whole structure is ready
before implementation begins.

## Stack
- **Auth**: Supabase Auth (email/password + OTP)
- **Database**: Postgres (schema in `supabase/migrations/`)
- **Storage**: buckets for property images, avatars, verification docs
- **Edge Functions**: Deno functions for payments, notifications, AI assistant
- **RLS**: Row Level Security policies per table (currently `TODO` stubs)

## Folder layout
```
backend/
├── README.md                  ← this file
├── .env.example               ← env vars needed by the app + functions
├── supabase/
│   ├── config.toml            ← Supabase CLI project config
│   ├── seed.sql               ← demo/seed data for local dev
│   ├── migrations/            ← one SQL file per table (schema + RLS)
│   └── functions/             ← Edge Functions (Deno) per feature
└── docs/
    └── schema.md              ← table reference & page→table mapping
```

## Page → backend mapping
| App screen(s)                                             | Table / Function                     |
|-----------------------------------------------------------|--------------------------------------|
| login, registration, otp                                  | Supabase Auth + `profiles`           |
| profile, edit_profile, account_security, change_password  | `profiles`                           |
| account_verification                                      | `verification_requests` + payment fn |
| home, listings, search, search_results, map_view, details | `properties`                         |
| create_listing, add_property, my_listings, my_properties  | `properties`                         |
| saved                                                     | `saved_properties`                   |
| recently_viewed                                           | `recently_viewed`                    |
| inquiries, owner_inquiries                                | `rental_requests`                    |
| purchase_history                                          | `rental_requests` / `transactions`   |
| chats, chat                                               | `chats`, `messages`                  |
| property reviews (details screen)                         | `reviews`                            |
| rate_app                                                  | `app_reviews`                        |
| admin_dashboard                                           | aggregate reads across tables        |
| pending_listings                                          | `properties.status`                  |
| reported_listings                                         | `reports`                            |
| notification_settings                                     | `notification_settings`              |

## Getting started (later, when implementation begins)
```bash
# install CLI: https://supabase.com/docs/guides/cli
supabase init          # already scaffolded here
supabase start         # spin up local stack
supabase db reset      # apply migrations + seed
supabase functions serve
```

# DwellWise

A rental marketplace for Bangladesh — tenants find and message property owners,
owners list and manage properties, all in English or Bangla.

Built with **Flutter** on the front end and **Supabase** (Postgres, Auth,
Storage, Realtime, Edge Functions) as the backend, with **Google Gemini** for
listing recommendations.

---

## What it does

**For tenants**
- Search the full Bangladesh location hierarchy — division → district → thana →
  neighbourhood — with filters for price, property type, bedrooms, bathrooms
  and verified owners
- AI-assisted recommendations that rank listings against the user's own address
- Save listings, browse recently viewed, and view properties on a map
- Message an owner directly, with photos, documents, voice notes and location
  sharing

**For owners**
- Post listings with photo upload, map-marked location and utility breakdown
- Manage listings, respond to inquiries, and track rentals
- Rental analytics — income, average rent and monthly trends, drawn as charts

**Shared**
- Phone-number login, plus "Continue with Google"
- Identity verification with NID photo upload
- A one-tap English ⇄ Bangla switch that translates the whole interface,
  including every place name in the search filters
- Light and dark themes, both remembered across restarts

---

## Tech stack

| Layer | Technology |
|---|---|
| App | Flutter, Dart |
| State management | Provider (`ChangeNotifier`) |
| Routing | go_router, with deep links / Android App Links |
| Backend | Supabase — Postgres, Auth, Storage, Realtime, Edge Functions (Deno) |
| Auth | Supabase Auth, Google Sign-In via ID token |
| AI | Google Gemini (`google_generative_ai`) |
| Maps & location | flutter_map, google_maps_flutter, geolocator |
| Media | image_picker, file_picker, record, audioplayers |
| Charts | fl_chart |
| Local storage | shared_preferences |

---

## Architecture

```
lib/
├── config/       routes, colours, translation table
├── models/       plain data classes with JSON mapping
├── providers/    ChangeNotifier state, one per domain (15)
├── services/     Supabase, chat, auth, payments, Gemini, maps (10)
├── screens/      43 screens, grouped by role: tenant / owner / admin / profile
├── widgets/      shared UI components
└── data/         Bangladesh location hierarchy + Bangla name tables

backend/supabase/
├── migrations/   17 SQL migrations — schema, row-level security, triggers
└── functions/    Deno edge functions
```

Screens read state from providers; providers own the app's state and delegate
all I/O to services; services are the only layer that talks to Supabase. Models
stay free of framework types, so they are the same objects in the UI and on the
wire.

---

## Engineering highlights

**Row-level security on every table.** A conversation is readable only by its
two participants, a notification only by its owner, and a message can only be
inserted by its own sender — enforced in Postgres, not in the client, so a
tampered client cannot read another user's data.

**Realtime messaging.** Chat runs on a single Realtime subscription for the
whole inbox rather than one per thread — RLS already limits the stream to the
user's own conversations. Sends are optimistic: the message appears instantly
and is reconciled with the stored row, and a failed send removes the bubble
rather than leaving a message nobody received.

**Account deletion that actually deletes.** Removing a row from `auth.users`
needs the service-role key, which must never ship inside an app, so deletion
runs in an edge function that identifies the caller from their own access
token — a user can only ever delete themselves. Related rows cascade from the
profile, and the account's uploaded files are swept from storage afterwards.

**Bilingual down to the place names.** Over a thousand divisions, districts,
thanas and neighbourhoods have Bangla names. Rather than one entry per
combination, names are composed: qualifiers in brackets, common suffixes and
trailing numbers resolve recursively, so `Sector 18 (Rajuk Uttara)` becomes
`সেক্টর ১৮ (রাজউক উত্তরা)` without its own entry. A test walks every name in the
dataset and fails if any comes back untranslated. Translation happens only at
render time — filters and queries keep passing English, so switching language
never changes which listings match.

**One signing key for the whole team.** Google Sign-In validates the app's
signing certificate, and Flutter's default debug key differs on every machine,
so builds from any laptop but one were rejected. A shared debug key is committed
so every teammate's build carries the same fingerprint.

**Graceful failure.** The app starts and reaches the login screen with no
network. Duplicate emails and phone numbers are refused before an account is
created, and the warning names the field that clashed.

---

## Data model

17 migrations covering profiles, properties, chats, messages, notifications,
saved properties, recently viewed, rental requests, reviews, reports,
verification requests and transactions — each with its RLS policies. Triggers
keep derived data honest: a new message updates its conversation's preview in
the database rather than in the client.

---

## Running it

```bash
flutter pub get
flutter run
```

Requires a Supabase project with the migrations in `backend/supabase/migrations`
applied. The Gemini API key is read at runtime from a gitignored local asset, so
no build flags are needed — see `assets/secrets/README.md`.

---

## Project status

Built as a university software development project. The core — auth, listings,
search, chat, notifications, verification — runs against a live Supabase
backend. Payments are mocked (no real charge), and the admin moderation queue is
partially implemented.

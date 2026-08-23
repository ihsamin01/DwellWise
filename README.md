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

## Try it in a browser

A web build is published from `docs/app`:

**https://dwell-wise.vercel.app**

Enough to walk through the app without installing anything — browsing and
searching listings, the bilingual interface, saved properties and the
conversation screens all work.

Some things are Android-only by nature and are not available in the browser
build: the camera, voice notes, dictation into the assistant, and Google
Sign-In. The AI assistant also needs an API key, which is deliberately not
shipped in a public build, so it is quiet on the web — run the Android app to
see it answer.


## Project status

Built as a university software development project. The core — auth, listings,
search, chat, notifications, verification — runs against a live Supabase
backend. Payments are mocked (no real charge), and the admin moderation queue is
partially implemented.

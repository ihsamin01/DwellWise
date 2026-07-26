# DwellWise — Database Schema Reference

All tables live in the `public` schema. Migrations are in `../supabase/migrations/`.

## Tables

| Table                   | Backing model (`lib/models/`) | Key columns                                        |
|-------------------------|-------------------------------|----------------------------------------------------|
| `profiles`              | `user_model.dart`             | id (=auth.users), role, verification_status        |
| `properties`            | `property_model.dart`         | owner_id, price, status, is_verified, location     |
| `verification_requests` | —                             | user_id, fee_paid, status                          |
| `saved_properties`      | —                             | (user_id, property_id)                             |
| `recently_viewed`       | —                             | (user_id, property_id), viewed_at                  |
| `rental_requests`       | `rental_request_model.dart`   | property_id, tenant_id, owner_id, status           |
| `reviews`               | `review_model.dart`           | property_id, tenant_id, rating                     |
| `app_reviews`           | `app_review_model.dart`       | user_id, rating, review_text                       |
| `chats`                 | `chat_model.dart`             | participant_a/b, property_id, last_message         |
| `messages`              | `chat_message_model.dart`     | chat_id, sender_id, is_read                        |
| `reports`               | —                             | property_id, reporter_id, status                   |
| `notification_settings` | —                             | user_id (pk), per-channel toggles                  |
| `transactions`          | —                             | user_id, type, amount, status                      |

## Enums
- `user_role`: tenant | owner | admin
- `verification_status`: unverified | pending | verified
- `property_status`: pending | approved | rejected
- `rental_request_status`: pending | approved | rejected | cancelled
- `report_status`: open | reviewed | dismissed | removed
- `transaction_type`: verification_fee | rent | other
- `transaction_status`: pending | success | failed | refunded

## Storage buckets
- `property-images` (public) — listing photos
- `avatars` (public) — profile pictures
- `verification-docs` (private) — ID uploads

## Roles & access (high level — RLS still TODO)
- **tenant**: browse approved properties, save/view, send rental requests, review, chat.
- **owner**: CRUD own properties, respond to rental requests, chat.
- **admin**: moderate properties (pending/reported), approve verifications.

# Bundled sticker GIFs (offline)

Drop `.gif` files here to ship them as offline stickers in chat. They are
auto-discovered at runtime via `AssetManifest` — no code change needed; just
add the file and rebuild.

If this folder has no `.gif` files, the sticker tab falls back to the built-in
animated emoji stickers (drawn in Flutter, fully offline).

Recommended: square GIFs, <= 512x512, small file size.

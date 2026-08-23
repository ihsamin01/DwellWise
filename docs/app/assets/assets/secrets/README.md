# Local secrets (not committed)

Put a `gemini.json` file in this folder to enable the Gemini-powered AI
Recommended feed:

```json
{ "GEMINI_API_KEY": "your-key-from-aistudio.google.com" }
```

The file is gitignored. Without it the app still runs — the AI Recommended feed
falls back to the offline location-based ranking.

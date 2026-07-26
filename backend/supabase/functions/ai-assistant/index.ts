// ai-assistant  →  lib/services/gemini_service.dart
// Server-side proxy to Gemini so the API key never ships in the app.
//
// STUB — not implemented yet.

import { corsHeaders } from "../_shared/cors.ts";

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // TODO:
  //  1. Parse { prompt, context } from body.
  //  2. Call Gemini API using GEMINI_API_KEY (server-side secret).
  //  3. Return the model response.

  return new Response(
    JSON.stringify({ error: "not_implemented" }),
    { status: 501, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});

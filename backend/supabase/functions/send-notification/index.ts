// send-notification
// Screens: notification_settings, chat (new message), inquiries (status change).
// Sends a push/email notification respecting the user's notification_settings.
//
// STUB — not implemented yet.

import { corsHeaders } from "../_shared/cors.ts";

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // TODO:
  //  1. Parse { userId, type, title, body }.
  //  2. Look up public.notification_settings for userId; skip if disabled.
  //  3. Dispatch via push provider (FCM) and/or email.

  return new Response(
    JSON.stringify({ error: "not_implemented" }),
    { status: 501, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});

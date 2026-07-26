// verify-account
// Screens: admin/pending (approve) + account_verification.
// Admin-only: approve/reject a verification_request and flip the user's
// profiles.verification_status (green trust badge).
//
// STUB — not implemented yet.

import { corsHeaders } from "../_shared/cors.ts";

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // TODO:
  //  1. Auth: assert caller is admin (service_role or role check).
  //  2. Parse { requestId, decision: 'verified' | 'unverified' }.
  //  3. Update verification_requests.status + reviewed_by.
  //  4. Update profiles.verification_status accordingly.

  return new Response(
    JSON.stringify({ error: "not_implemented" }),
    { status: 501, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});

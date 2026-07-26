// process-payment  →  lib/services/payment_service.dart
// Screens: account_verification (fee), purchase_history / rent payments.
// Verifies a payment with the gateway and records a row in `transactions`.
//
// STUB — not implemented yet.

import { corsHeaders } from "../_shared/cors.ts";

Deno.serve((req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // TODO:
  //  1. Auth: read user from JWT.
  //  2. Parse { type, amount, propertyId } from body.
  //  3. Call payment provider (PAYMENT_PROVIDER_KEY) to charge / verify.
  //  4. Insert into public.transactions with status.
  //  5. If type === 'verification_fee' → mark verification_requests.fee_paid.

  return new Response(
    JSON.stringify({ error: "not_implemented" }),
    { status: 501, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
});

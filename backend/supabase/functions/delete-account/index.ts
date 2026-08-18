// delete-account
// Screens: profile → Account & Security → Delete Account.
//
// Deletes the *calling* user's account. This has to live in an edge function
// because removing a row from auth.users needs the service_role key, which
// must never ship inside the app. The caller is identified from their own
// access token, so a user can only ever delete themselves.

import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const BUCKETS = [
  "avatars",
  "verification-docs",
  "chat-attachments",
  "property-images",
];

const json = (body: unknown, status: number) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const accessToken = authHeader.replace(/^Bearer\s+/i, "");
  if (!accessToken) {
    return json({ error: "missing_token" }, 401);
  }

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const admin = createClient(url, serviceKey);

  // Resolve the caller from their own token rather than trusting a user id in
  // the request body — otherwise any signed-in user could delete anyone.
  const { data: caller, error: callerError } = await admin.auth.getUser(
    accessToken,
  );
  if (callerError || !caller?.user) {
    return json({ error: "invalid_token" }, 401);
  }

  const userId = caller.user.id;

  // The profile row goes first: everything else references it with
  // `on delete cascade`, and deleting the auth user takes it too, but doing it
  // explicitly means a failure here stops the whole thing before the account
  // becomes unrecoverable.
  const { error: profileError } = await admin
    .from("profiles")
    .delete()
    .eq("id", userId);
  if (profileError) {
    return json({ error: "profile_delete_failed", detail: profileError.message }, 500);
  }

  const { error: authError } = await admin.auth.admin.deleteUser(userId);
  if (authError) {
    return json({ error: "auth_delete_failed", detail: authError.message }, 500);
  }

  // Uploaded files are not reached by the cascade from profiles, so they would
  // outlive the account. Every bucket stores objects under a folder named
  // after the uploader, which is what makes this sweep possible.
  //
  // Best effort on purpose: the account is already gone by this point, and
  // failing the request now would tell the user their deletion did not work.
  for (const bucket of BUCKETS) {
    try {
      const { data: files } = await admin.storage.from(bucket).list(userId);
      if (files && files.length > 0) {
        await admin.storage
          .from(bucket)
          .remove(files.map((f) => `${userId}/${f.name}`));
      }
    } catch (_) {
      // Leave the orphaned objects rather than report a failed deletion.
    }
  }

  return json({ deleted: true }, 200);
});

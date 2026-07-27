/// Supabase connection settings for DwellWise.
///
/// The publishable (anon) key is client-safe — it is designed to ship inside
/// the app and is protected by Row Level Security on the database. NEVER put
/// the service_role / secret key or the database password here.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://hjzczdhnslbdqvehpsza.supabase.co';
  static const String anonKey =
      'sb_publishable_rOaigWZkOc_JTkpDIf6qkQ_-puzFzap';
}

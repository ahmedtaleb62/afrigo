import { createClient, type SupabaseClient, type User } from 'npm:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;

/**
 * Full-access client, bypasses RLS and every `..._guard` trigger's
 * `auth.role() = 'service_role'` check. Use for the actual privileged
 * write every function exists to perform — never expose this client or its
 * key to the browser.
 */
export function serviceClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

/**
 * Scoped to the calling user's own JWT — reads/writes through this client
 * are subject to the same RLS policies the caller's app already has. Useful
 * when a function should simply do "what the user themselves could already
 * do" but with extra validation, rather than a privileged bypass.
 */
export function callerClient(req: Request): SupabaseClient {
  const authHeader = req.headers.get('Authorization') ?? '';
  return createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  });
}

/** Resolves + validates the caller's JWT. Throws `HttpError(401, ...)` if missing/invalid. */
export async function requireUser(req: Request): Promise<User> {
  const client = callerClient(req);
  const { data, error } = await client.auth.getUser();
  if (error || !data.user) throw new HttpError(401, 'يجب تسجيل الدخول');
  return data.user;
}

/** Resolves the caller and asserts `profiles.role = 'admin'`. */
export async function requireAdmin(req: Request): Promise<User> {
  const user = await requireUser(req);
  const admin = serviceClient();
  const { data } = await admin.from('profiles').select('role').eq('id', user.id).maybeSingle();
  if (data?.role !== 'admin') throw new HttpError(403, 'هذه العملية متاحة للمشرفين فقط');
  return user;
}

export class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

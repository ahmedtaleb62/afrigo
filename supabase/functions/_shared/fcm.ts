// Real push delivery via Firebase Cloud Messaging (HTTP v1 API). Needs the
// `FCM_SERVICE_ACCOUNT` secret (the full service-account JSON downloaded
// from Firebase Console → Project Settings → Service Accounts → Generate
// new private key) — see supabase/README.md. Deliberately dependency-free:
// RS256 JWT signing uses Deno's built-in Web Crypto (`crypto.subtle`)
// instead of pulling in a JWT library for one call site.
import type { SupabaseClient } from 'npm:@supabase/supabase-js@2';

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
  token_uri: string;
}

let cachedAccessToken: { token: string; expiresAt: number } | null = null;

function getServiceAccount(): ServiceAccount | null {
  const raw = Deno.env.get('FCM_SERVICE_ACCOUNT');
  if (!raw) return null;
  try {
    return JSON.parse(raw) as ServiceAccount;
  } catch {
    console.error('FCM_SERVICE_ACCOUNT is not valid JSON');
    return null;
  }
}

function base64UrlFromBytes(bytes: Uint8Array): string {
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function base64UrlFromString(input: string): string {
  return base64UrlFromBytes(new TextEncoder().encode(input));
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pkcs8 = pem
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s+/g, '');
  const der = Uint8Array.from(atob(pkcs8), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey('pkcs8', der, { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
}

async function getAccessToken(account: ServiceAccount): Promise<string> {
  if (cachedAccessToken && cachedAccessToken.expiresAt > Date.now() + 60_000) {
    return cachedAccessToken.token;
  }

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const claims = {
    iss: account.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: account.token_uri,
    exp: now + 3600,
    iat: now,
  };
  const unsigned = `${base64UrlFromString(JSON.stringify(header))}.${base64UrlFromString(JSON.stringify(claims))}`;
  const key = await importPrivateKey(account.private_key);
  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(unsigned));
  const jwt = `${unsigned}.${base64UrlFromBytes(new Uint8Array(signature))}`;

  const res = await fetch(account.token_uri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=${encodeURIComponent('urn:ietf:params:oauth:grant-type:jwt-bearer')}&assertion=${jwt}`,
  });
  if (!res.ok) throw new Error(`FCM token exchange failed: ${res.status} ${await res.text()}`);
  const data = (await res.json()) as { access_token: string; expires_in: number };
  cachedAccessToken = { token: data.access_token, expiresAt: Date.now() + data.expires_in * 1000 };
  return data.access_token;
}

/**
 * Sends a push notification to every device token registered for
 * [userId]. Best-effort per token — one failure doesn't stop the others.
 * Silently no-ops if `FCM_SERVICE_ACCOUNT` isn't configured yet, so
 * `createNotification` (the one caller) never has to know or care whether
 * push is set up — same "real, not a placeholder, but degrades gracefully"
 * approach used throughout this project (see fetchCurrentLocation etc.).
 */
export async function sendPushToUser(
  admin: SupabaseClient,
  userId: string,
  title: string,
  body: string,
  data?: Record<string, unknown>,
): Promise<void> {
  const account = getServiceAccount();
  if (!account) return;

  const { data: tokens } = await admin.from('device_tokens').select('id, token').eq('user_id', userId);
  if (!tokens || tokens.length === 0) return;

  const accessToken = await getAccessToken(account);
  const stringData = data
    ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)]))
    : undefined;

  await Promise.all(
    tokens.map(async (row: { id: string; token: string }) => {
      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: {
            token: row.token,
            notification: { title, body },
            data: stringData,
            android: { priority: 'high' },
            apns: { headers: { 'apns-priority': '10' }, payload: { aps: { sound: 'default' } } },
          },
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        // NOT_FOUND/UNREGISTERED/INVALID_ARGUMENT — the token is dead
        // (uninstalled, reset, or malformed); stop trying it.
        if (res.status === 404 || text.includes('UNREGISTERED') || text.includes('INVALID_ARGUMENT')) {
          await admin.from('device_tokens').delete().eq('id', row.id);
        } else {
          console.error(`FCM send to ${row.id} failed: ${res.status} ${text}`);
        }
      }
    }),
  );
}

import type { SupabaseClient } from 'npm:@supabase/supabase-js@2';
import { sendPushToUser } from './fcm.ts';

/**
 * Creates the `notifications` row (real — every app's Notifications screen
 * reads this table) and, best-effort, a real FCM push alongside it — see
 * `fcm.ts`. This is the single choke point every caller already goes
 * through (respond-to-order, update-order-status, admin-topup-wallet,
 * admin-deduct-wallet, admin-suspend-user, review-verification), so wiring
 * push in here gives all of them real push delivery with no per-call-site
 * changes.
 */
export async function createNotification(
  admin: SupabaseClient,
  params: { userId: string; title: string; body: string; data?: Record<string, unknown> },
): Promise<void> {
  const { error } = await admin.from('notifications').insert({
    user_id: params.userId,
    title: params.title,
    body: params.body,
    data: params.data ?? {},
  });
  if (error) console.error('createNotification failed:', error.message);

  try {
    await sendPushToUser(admin, params.userId, params.title, params.body, params.data);
  } catch (err) {
    // Non-fatal — the in-app notifications row above already landed, and
    // every caller's own primary action (order accepted, wallet topped up,
    // etc.) already succeeded regardless of push delivery.
    console.error('sendPushToUser failed:', err);
  }
}

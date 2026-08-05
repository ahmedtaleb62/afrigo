const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

/**
 * One-shot server-side Realtime Broadcast via the REST endpoint (no
 * websocket connection needed, unlike the JS client's `.channel().send()`)
 * — the right tool for "fire this event from an Edge Function and move on".
 *
 * Used to fan a new order out to every qualified nearby provider at once —
 * see request-ride/index.ts for why "broadcast to all, first accept wins"
 * was chosen over sequential per-driver offers with server-side timers.
 */
export async function broadcast(topic: string, event: string, payload: Record<string, unknown>): Promise<void> {
  try {
    const res = await fetch(`${SUPABASE_URL}/realtime/v1/api/broadcast`, {
      method: 'POST',
      headers: {
        apikey: SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ messages: [{ topic, event, payload }] }),
    });
    if (!res.ok) console.error(`broadcast to ${topic} failed: ${res.status} ${await res.text()}`);
  } catch (err) {
    console.error(`broadcast to ${topic} threw:`, err);
  }
}

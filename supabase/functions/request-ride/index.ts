// request-ride
// Used by the Client app's ride-confirm screen (14) once the user taps
// "اطلب الآن". Creates the `rides` row (the only inserter — `rides` has no
// client-side INSERT policy on purpose, see
// supabase/migrations/20260731230007_rides.sql) and matches nearby drivers.
//
// Matching strategy — broadcast to all qualified drivers, first accept wins:
// Edge Functions are short-lived and stateless, so they cannot hold open a
// 15s-per-driver sequential-offer timer server-side. Instead this fans the
// request out to every verified/online/sufficiently-funded driver within
// 3 km (see `find_nearby_vehicles`) via one Realtime Broadcast on each
// driver's own `driver:{owner_id}:incoming_orders` channel; whichever
// driver calls `respond-to-order` first wins via `respond-to-order`'s
// optimistic-locking UPDATE (`.eq('status', 'searching')`). Each driver's
// own app still runs its own 20s local countdown UI (screen 54).
//
// The actual insert/match/broadcast logic lives in `_shared/orders.ts` so
// voice-order-confirm (voice ordering flow) can create the exact same kind
// of ride without duplicating this.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient } from '../_shared/clients.ts';
import { createRide, type RideBody } from '../_shared/orders.ts';

Deno.serve(
  withHandler<RideBody>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();
    const result = await createRide(admin, user.id, body);
    return { ride_id: result.order_id, ...result };
  }),
);

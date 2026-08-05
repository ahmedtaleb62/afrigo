// request-delivery
// Used by the Client app's parcel-confirm screen (34). Same matching
// strategy as request-ride (see that file's header comment for why
// "broadcast to all, first accept wins") but targets livreurs
// (`vehicles.service_type = 'delivery'`) via `delivery:{owner_id}:incoming_orders`.
//
// The actual insert/match/broadcast logic lives in `_shared/orders.ts` so
// voice-order-confirm (voice ordering flow) can create the exact same kind
// of delivery request without duplicating this.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient } from '../_shared/clients.ts';
import { createDelivery, type DeliveryBody } from '../_shared/orders.ts';

Deno.serve(
  withHandler<DeliveryBody>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();
    const result = await createDelivery(admin, user.id, body);
    return { delivery_id: result.order_id, ...result };
  }),
);

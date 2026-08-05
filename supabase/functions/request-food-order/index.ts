// request-food-order
// Used by the Client app's food checkout screen (26). Unlike request-ride/
// request-delivery there is no PostGIS matching here — the client already
// picked a specific restaurant while building their cart; the livreur match
// happens later, inside update-order-status, when the restaurant marks the
// order 'ready' (see that function).
//
// Dish prices are re-read from `restaurant_dishes` server-side (never
// trusted from the request body) so a tampered client can't set its own
// total.
//
// The actual validation/insert/broadcast logic lives in `_shared/orders.ts`
// so voice-order-confirm (voice ordering flow) can create the exact same
// kind of food order without duplicating this.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient } from '../_shared/clients.ts';
import { createFoodOrder, type FoodOrderBody } from '../_shared/orders.ts';

Deno.serve(
  withHandler<FoodOrderBody>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();
    const result = await createFoodOrder(admin, user.id, body);
    return { order_id: result.order_id, ...result };
  }),
);

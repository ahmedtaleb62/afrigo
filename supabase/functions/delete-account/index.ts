// delete-account
// Called from the Settings screen's "حذف الحساب" action (any role). Blocks
// deletion while the caller has an order still in flight (same reasoning as
// blocking a suspended/low-balance provider from going online elsewhere —
// don't let a destructive action orphan an order the other side is relying
// on), then tries to delete the `auth.users` row outright.
//
// `rides`/`food_orders`/`delivery_requests`/`ratings` reference `profiles`
// WITHOUT `on delete cascade` on purpose (they're financial/audit records —
// same reasoning as commission deduction being a trigger nothing can skip,
// see supabase/README.md) — so a user with any order history at all makes
// the hard delete fail with a foreign-key violation. When that happens this
// falls back to disabling + anonymizing the account instead: the login is
// permanently banned and personally-identifying fields are scrubbed, but
// the order/rating rows (and whatever they feed into commission/admin
// reporting) survive.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';

const ACTIVE_RIDE_STATUSES = ['searching', 'accepted', 'driver_arriving', 'in_progress'];
const ACTIVE_FOOD_STATUSES = ['pending_restaurant', 'accepted', 'preparing', 'ready', 'searching_livreur', 'out_for_delivery'];
const ACTIVE_DELIVERY_STATUSES = ['searching', 'accepted', 'picked_up'];

Deno.serve(
  withHandler(async (req) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    // Checked both as the client AND as the provider (driver/livreur/
    // restaurant owner) — the original version only checked client_id, so a
    // driver with a ride genuinely in_progress could delete their account
    // mid-trip and orphan the client with no driver, no notification, and
    // no way to ever find out what happened.
    const { data: restaurant } = await admin.from('restaurants').select('id').eq('owner_id', user.id).maybeSingle();
    const [rides, foodOrders, deliveries] = await Promise.all([
      admin.from('rides').select('id').or(`client_id.eq.${user.id},driver_id.eq.${user.id}`).in('status', ACTIVE_RIDE_STATUSES),
      restaurant
        ? admin.from('food_orders').select('id').or(`client_id.eq.${user.id},restaurant_id.eq.${restaurant.id},livreur_id.eq.${user.id}`).in('status', ACTIVE_FOOD_STATUSES)
        : admin.from('food_orders').select('id').or(`client_id.eq.${user.id},livreur_id.eq.${user.id}`).in('status', ACTIVE_FOOD_STATUSES),
      admin.from('delivery_requests').select('id').or(`client_id.eq.${user.id},livreur_id.eq.${user.id}`).in('status', ACTIVE_DELIVERY_STATUSES),
    ]);
    if ((rides.data?.length ?? 0) > 0 || (foodOrders.data?.length ?? 0) > 0 || (deliveries.data?.length ?? 0) > 0) {
      throw new HttpError(400, 'لا يمكن حذف الحساب أثناء وجود طلب جارٍ، أكمله أو ألغه أولًا');
    }

    const { error } = await admin.auth.admin.deleteUser(user.id);
    if (!error) return { deleted: true };

    const { error: banError } = await admin.auth.admin.updateUserById(user.id, { ban_duration: '876000h' });
    if (banError) throw new HttpError(500, banError.message);
    await admin.from('profiles').update({ full_name: 'مستخدم محذوف', phone: null, email: null, is_suspended: true }).eq('id', user.id);

    // Same reasoning as admin-suspend-user: a banned login can never come
    // back to toggle itself offline, so a driver/restaurant that was online
    // at the moment of deletion would otherwise keep matching new orders
    // forever on an account nobody can ever respond from.
    await admin.from('vehicles').update({ is_online: false }).eq('owner_id', user.id);
    await admin.from('restaurants').update({ is_open: false }).eq('owner_id', user.id);

    return { deleted: true, anonymized: true };
  }),
);

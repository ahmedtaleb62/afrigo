// update-order-status
// Forward state-machine transitions for the 3 order types, called by the
// assigned provider (Taxi/Food/Livreur apps) as they move an order along,
// or by either side to cancel. Every transition is checked against a fixed
// {current status -> allowed next statuses} map — a client trying to skip a
// step (e.g. rides: accepted -> completed) gets a 400, never silently
// accepted. Optimistic locking (`.eq('status', <current>)` on the UPDATE)
// guards against a double-submit race the same way respond-to-order does.
//
// Food orders: 'preparing' -> 'ready' is special. Instead of leaving the
// order sitting at 'ready' waiting for someone to separately dispatch a
// livreur, this immediately runs the same nearby-vehicle search
// request-delivery uses (service_type='delivery', 3km) and moves the order
// to 'searching_livreur' (broadcasting to matched livreurs) or
// 'no_livreur_found'. A livreur then claims it via respond-to-order (see
// respondFoodDelivery there), same optimistic-locking pattern as every
// other broadcast order.
//
// Final-step semantics (rides: in_progress -> completed; food_orders/
// delivery_requests: -> delivered): commission deduction is NOT done here —
// see supabase/migrations/20260802110001_order_completion_and_commission.sql.
// A DB trigger fires on the write this function makes (food_orders/
// delivery_requests auto-promote delivered -> completed in the same write),
// so it can't be skipped or double-fired by a buggy/malicious client.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';
import { createNotification } from '../_shared/notify.ts';
import { broadcast } from '../_shared/broadcast.ts';

type OrderType = 'ride' | 'food_order' | 'delivery_request';

interface Body {
  order_type: OrderType;
  order_id: string;
  next_status: string;
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    if (!['ride', 'food_order', 'delivery_request'].includes(body.order_type)) throw new HttpError(400, 'نوع الطلب غير صالح');
    if (!body.order_id || !body.next_status) throw new HttpError(400, 'بيانات ناقصة');

    if (body.order_type === 'ride') return advanceRide(admin, user.id, body);
    if (body.order_type === 'delivery_request') return advanceDelivery(admin, user.id, body);
    return advanceFoodOrder(admin, user.id, body);
  }),
);

const RIDE_MESSAGES: Record<string, string> = {
  driver_arriving: 'السائق في طريقه إليك',
  in_progress: 'بدأت رحلتك',
  completed: 'انتهت رحلتك، نتمنى لك رحلة سعيدة',
  cancelled_by_driver: 'ألغى السائق الرحلة',
  cancelled_by_client: 'ألغى العميل الرحلة',
};

async function advanceRide(admin: ReturnType<typeof serviceClient>, userId: string, body: Body) {
  const { data: ride } = await admin.from('rides').select('id, client_id, driver_id, status').eq('id', body.order_id).maybeSingle();
  if (!ride) throw new HttpError(404, 'الرحلة غير موجودة');

  const isDriver = ride.driver_id === userId;
  const isClient = ride.client_id === userId;
  if (!isDriver && !isClient) throw new HttpError(403, 'لا يمكنك تعديل هذه الرحلة');

  const ALLOWED: Record<string, string[]> = {
    searching: ['cancelled_by_client'],
    accepted: ['driver_arriving', 'cancelled_by_driver', 'cancelled_by_client'],
    driver_arriving: ['in_progress', 'cancelled_by_driver', 'cancelled_by_client'],
    in_progress: ['completed'],
  };
  const allowedNext = ALLOWED[ride.status] ?? [];
  if (!allowedNext.includes(body.next_status)) throw new HttpError(400, `لا يمكن الانتقال من "${ride.status}" إلى "${body.next_status}"`);

  if (body.next_status === 'cancelled_by_driver' && !isDriver) throw new HttpError(403, 'فقط السائق يمكنه هذا الإلغاء');
  if (body.next_status === 'cancelled_by_client' && !isClient) throw new HttpError(403, 'فقط العميل يمكنه هذا الإلغاء');
  if (['driver_arriving', 'in_progress', 'completed'].includes(body.next_status) && !isDriver) {
    throw new HttpError(403, 'فقط السائق يمكنه تحديث حالة الرحلة');
  }

  const patch: Record<string, unknown> = { status: body.next_status };
  if (body.next_status === 'in_progress') patch.started_at = new Date().toISOString();
  if (body.next_status === 'completed') patch.completed_at = new Date().toISOString();
  if (body.next_status.startsWith('cancelled')) patch.cancelled_at = new Date().toISOString();

  const { data: updated, error } = await admin
    .from('rides')
    .update(patch)
    .eq('id', body.order_id)
    .eq('status', ride.status)
    .select('id, status')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!updated) throw new HttpError(409, 'تم تعديل حالة الرحلة بالفعل، أعد المحاولة');

  const notifyUserId = isDriver ? ride.client_id : ride.driver_id;
  if (notifyUserId) {
    await createNotification(admin, {
      userId: notifyUserId,
      title: 'تحديث حالة الرحلة',
      body: RIDE_MESSAGES[body.next_status] ?? body.next_status,
      data: { ride_id: ride.id, status: updated.status },
    });
  }

  return { ok: true, ride_id: ride.id, status: updated.status };
}

const FOOD_MESSAGES: Record<string, string> = {
  preparing: 'المطعم يحضّر طلبك الآن',
  ready: 'طلبك جاهز، جارٍ البحث عن مندوب توصيل',
  delivered: 'تم تسليم طلبك، بالهناء والشفاء',
  cancelled: 'ألغى المطعم طلبك',
};

async function advanceFoodOrder(admin: ReturnType<typeof serviceClient>, userId: string, body: Body) {
  const { data: order } = await admin
    .from('food_orders')
    .select('id, client_id, restaurant_id, livreur_id, status, delivery_location')
    .eq('id', body.order_id)
    .maybeSingle();
  if (!order) throw new HttpError(404, 'الطلب غير موجود');

  const { data: restaurant } = await admin.from('restaurants').select('id, owner_id').eq('id', order.restaurant_id).maybeSingle();
  const isRestaurant = restaurant?.owner_id === userId;
  const isLivreur = order.livreur_id === userId;
  if (!isRestaurant && !isLivreur) throw new HttpError(403, 'لا يمكنك تعديل هذا الطلب');

  const ALLOWED: Record<string, string[]> = {
    accepted: ['preparing', 'cancelled'],
    preparing: ['ready', 'cancelled'],
    out_for_delivery: ['delivered'],
  };
  const allowedNext = ALLOWED[order.status] ?? [];
  if (!allowedNext.includes(body.next_status)) throw new HttpError(400, `لا يمكن الانتقال من "${order.status}" إلى "${body.next_status}"`);

  if (['preparing', 'ready', 'cancelled'].includes(body.next_status) && !isRestaurant) {
    throw new HttpError(403, 'فقط المطعم يمكنه تحديث هذه الحالة');
  }
  if (body.next_status === 'delivered' && !isLivreur) throw new HttpError(403, 'فقط مندوب التوصيل يمكنه تحديث هذه الحالة');

  if (body.next_status === 'ready') return markFoodOrderReadyAndSearchLivreur(admin, order);

  const patch: Record<string, unknown> = { status: body.next_status };
  if (body.next_status === 'preparing') patch.preparing_at = new Date().toISOString();
  if (body.next_status === 'delivered') patch.delivered_at = new Date().toISOString();
  if (body.next_status === 'cancelled') patch.cancelled_at = new Date().toISOString();

  const { data: updated, error } = await admin
    .from('food_orders')
    .update(patch)
    .eq('id', order.id)
    .eq('status', order.status)
    .select('id, status')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!updated) throw new HttpError(409, 'تم تعديل حالة الطلب بالفعل، أعد المحاولة');

  await createNotification(admin, {
    userId: order.client_id,
    title: 'تحديث حالة الطلب',
    body: FOOD_MESSAGES[body.next_status] ?? body.next_status,
    data: { order_id: order.id, status: updated.status },
  });

  return { ok: true, order_id: order.id, status: updated.status };
}

async function markFoodOrderReadyAndSearchLivreur(
  admin: ReturnType<typeof serviceClient>,
  order: { id: string; client_id: string; delivery_location: unknown },
) {
  const { data: readyOrder, error: readyError } = await admin
    .from('food_orders')
    .update({ status: 'ready', ready_at: new Date().toISOString() })
    .eq('id', order.id)
    .eq('status', 'preparing')
    .select('id')
    .maybeSingle();
  if (readyError) throw new HttpError(500, readyError.message);
  if (!readyOrder) throw new HttpError(409, 'تم تعديل حالة الطلب بالفعل، أعد المحاولة');

  const { data: couriers } = await admin.rpc('find_nearby_vehicles', {
    p_pickup: order.delivery_location,
    p_service_type: 'delivery',
    p_radius_m: 3000,
  });

  if (!couriers || couriers.length === 0) {
    await admin.from('food_orders').update({ status: 'no_livreur_found' }).eq('id', order.id);
    await createNotification(admin, {
      userId: order.client_id,
      title: 'تعذّر العثور على مندوب توصيل',
      body: 'سنحاول مجددًا قريبًا.',
      data: { order_id: order.id, status: 'no_livreur_found' },
    });
    return { ok: true, order_id: order.id, status: 'no_livreur_found' };
  }

  await admin.from('food_orders').update({ status: 'searching_livreur' }).eq('id', order.id);
  await Promise.all(
    couriers.map((c: { owner_id: string }) =>
      broadcast(`delivery:${c.owner_id}:incoming_orders`, 'incoming_food_delivery', { order_id: order.id }),
    ),
  );
  await createNotification(admin, {
    userId: order.client_id,
    title: 'طلبك جاهز',
    body: 'جارٍ البحث عن مندوب توصيل.',
    data: { order_id: order.id, status: 'searching_livreur' },
  });

  return { ok: true, order_id: order.id, status: 'searching_livreur', matched_couriers: couriers.length };
}

const DELIVERY_MESSAGES: Record<string, string> = {
  picked_up: 'استلم المندوب طردك وهو في طريقه',
  delivered: 'تم تسليم الطرد بنجاح',
  cancelled_by_client: 'ألغى العميل طلب التوصيل',
};

async function advanceDelivery(admin: ReturnType<typeof serviceClient>, userId: string, body: Body) {
  const { data: delivery } = await admin.from('delivery_requests').select('id, client_id, livreur_id, status').eq('id', body.order_id).maybeSingle();
  if (!delivery) throw new HttpError(404, 'طلب التوصيل غير موجود');

  const isLivreur = delivery.livreur_id === userId;
  const isClient = delivery.client_id === userId;
  if (!isLivreur && !isClient) throw new HttpError(403, 'لا يمكنك تعديل هذا الطلب');

  const ALLOWED: Record<string, string[]> = {
    searching: ['cancelled_by_client'],
    accepted: ['picked_up', 'cancelled', 'cancelled_by_client'],
    picked_up: ['delivered'],
  };
  const allowedNext = ALLOWED[delivery.status] ?? [];
  if (!allowedNext.includes(body.next_status)) throw new HttpError(400, `لا يمكن الانتقال من "${delivery.status}" إلى "${body.next_status}"`);

  if (body.next_status === 'cancelled_by_client' && !isClient) throw new HttpError(403, 'فقط العميل يمكنه هذا الإلغاء');
  if (['picked_up', 'delivered', 'cancelled'].includes(body.next_status) && !isLivreur) {
    throw new HttpError(403, 'فقط مندوب التوصيل يمكنه تحديث حالة الطلب');
  }

  const patch: Record<string, unknown> = { status: body.next_status };
  if (body.next_status === 'picked_up') patch.picked_up_at = new Date().toISOString();
  if (body.next_status === 'delivered') patch.delivered_at = new Date().toISOString();
  if (body.next_status.startsWith('cancelled')) patch.cancelled_at = new Date().toISOString();

  const { data: updated, error } = await admin
    .from('delivery_requests')
    .update(patch)
    .eq('id', delivery.id)
    .eq('status', delivery.status)
    .select('id, status')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!updated) throw new HttpError(409, 'تم تعديل حالة الطلب بالفعل، أعد المحاولة');

  await createNotification(admin, {
    userId: delivery.client_id,
    title: 'تحديث حالة التوصيل',
    body: DELIVERY_MESSAGES[body.next_status] ?? body.next_status,
    data: { delivery_id: delivery.id, status: updated.status },
  });

  return { ok: true, delivery_id: delivery.id, status: updated.status };
}

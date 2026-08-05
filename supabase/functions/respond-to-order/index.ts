// respond-to-order
// Accept/reject for all 3 order types, called by the provider (Taxi/Food/
// Livreur apps' incoming-order sheets). Optimistic locking via
// `.eq('status', <awaiting-status>)` on the UPDATE is what actually
// prevents two drivers from both accepting the same broadcast ride — only
// the first UPDATE that still matches the expected status succeeds; a
// second one affects 0 rows and gets a 409.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';
import { createNotification } from '../_shared/notify.ts';

type OrderType = 'ride' | 'food_order' | 'delivery_request';

interface Body {
  order_type: OrderType;
  order_id: string;
  decision: 'accept' | 'reject';
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    if (!['ride', 'food_order', 'delivery_request'].includes(body.order_type)) throw new HttpError(400, 'نوع الطلب غير صالح');
    if (!body.order_id) throw new HttpError(400, 'معرّف الطلب مطلوب');

    if (body.decision === 'accept') {
      const { data: profile } = await admin.from('profiles').select('is_suspended').eq('id', user.id).maybeSingle();
      if (profile?.is_suspended) throw new HttpError(403, 'تم تعليق حسابك، يرجى التواصل مع الدعم');
    }

    if (body.order_type === 'ride') return respondRide(admin, user.id, body);
    if (body.order_type === 'delivery_request') return respondDelivery(admin, user.id, body);
    return respondFoodOrder(admin, user.id, body);
  }),
);

async function respondRide(admin: ReturnType<typeof serviceClient>, userId: string, body: Body) {
  if (body.decision === 'reject') return { ok: true };

  const { data: vehicle } = await admin
    .from('vehicles')
    .select('id, status, is_online')
    .eq('owner_id', userId)
    .eq('service_type', 'taxi')
    .maybeSingle();
  if (!vehicle || vehicle.status !== 'verified' || !vehicle.is_online) {
    throw new HttpError(403, 'يجب أن تكون متصلًا وموثّقًا لقبول الطلبات');
  }

  const { data: ride, error } = await admin
    .from('rides')
    .update({ driver_id: userId, status: 'accepted', accepted_at: new Date().toISOString() })
    .eq('id', body.order_id)
    .eq('status', 'searching')
    .select('id, client_id')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!ride) throw new HttpError(409, 'تم قبول هذه الرحلة من طرف سائق آخر');

  await createNotification(admin, { userId: ride.client_id, title: 'تم العثور على سائق', body: 'وافق سائق على رحلتك.', data: { ride_id: ride.id } });
  return { ok: true, ride_id: ride.id };
}

async function respondDelivery(admin: ReturnType<typeof serviceClient>, userId: string, body: Body) {
  if (body.decision === 'reject') return { ok: true };

  const { data: vehicle } = await admin
    .from('vehicles')
    .select('id, status, is_online')
    .eq('owner_id', userId)
    .eq('service_type', 'delivery')
    .maybeSingle();
  if (!vehicle || vehicle.status !== 'verified' || !vehicle.is_online) {
    throw new HttpError(403, 'يجب أن تكون متصلًا وموثّقًا لقبول الطلبات');
  }

  const { data: delivery, error } = await admin
    .from('delivery_requests')
    .update({ livreur_id: userId, status: 'accepted', accepted_at: new Date().toISOString() })
    .eq('id', body.order_id)
    .eq('status', 'searching')
    .select('id, client_id')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!delivery) throw new HttpError(409, 'تم قبول طلب التوصيل هذا من طرف مندوب آخر');

  await createNotification(admin, { userId: delivery.client_id, title: 'تم العثور على مندوب توصيل', body: 'وافق مندوب على استلام طردك.', data: { delivery_id: delivery.id } });
  return { ok: true, delivery_id: delivery.id };
}

// Handles two unrelated "claims" against the same food_orders row,
// distinguished by its current status: the restaurant accepting/rejecting
// the order (pending_restaurant), and — once the restaurant later marks it
// 'ready' and update-order-status has dispatched a livreur search
// (searching_livreur) — a livreur claiming the delivery leg. Both use the
// same optimistic-locking shape as respondRide/respondDelivery above.
async function respondFoodOrder(admin: ReturnType<typeof serviceClient>, userId: string, body: Body) {
  const { data: order } = await admin.from('food_orders').select('id, client_id, restaurant_id, status').eq('id', body.order_id).maybeSingle();
  if (!order) throw new HttpError(404, 'الطلب غير موجود');

  if (order.status === 'searching_livreur') return respondFoodDelivery(admin, userId, order, body);

  const { data: restaurant } = await admin.from('restaurants').select('id').eq('id', order.restaurant_id).eq('owner_id', userId).maybeSingle();
  if (!restaurant) throw new HttpError(403, 'هذا الطلب ليس لمطعمك');

  const nextStatus = body.decision === 'accept' ? 'accepted' : 'rejected_by_restaurant';
  const patch: Record<string, unknown> = { status: nextStatus };
  patch[body.decision === 'accept' ? 'accepted_at' : 'rejected_at'] = new Date().toISOString();

  const { data: updated, error } = await admin
    .from('food_orders')
    .update(patch)
    .eq('id', body.order_id)
    .eq('status', 'pending_restaurant')
    .select('id')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!updated) throw new HttpError(409, 'تمت معالجة هذا الطلب مسبقًا');

  await createNotification(admin, {
    userId: order.client_id,
    title: body.decision === 'accept' ? 'تم قبول طلبك' : 'اعتذر المطعم عن قبول طلبك',
    body: body.decision === 'accept' ? 'المطعم يحضّر طلبك الآن.' : 'لن يتم خصم أي مبلغ منك.',
    data: { order_id: order.id, status: nextStatus },
  });

  return { ok: true, order_id: order.id, status: nextStatus };
}

async function respondFoodDelivery(
  admin: ReturnType<typeof serviceClient>,
  userId: string,
  order: { id: string; client_id: string },
  body: Body,
) {
  if (body.decision === 'reject') return { ok: true };

  const { data: vehicle } = await admin
    .from('vehicles')
    .select('id, status, is_online')
    .eq('owner_id', userId)
    .eq('service_type', 'delivery')
    .maybeSingle();
  if (!vehicle || vehicle.status !== 'verified' || !vehicle.is_online) {
    throw new HttpError(403, 'يجب أن تكون متصلًا وموثّقًا لقبول الطلبات');
  }

  const { data: updated, error } = await admin
    .from('food_orders')
    .update({ livreur_id: userId, status: 'out_for_delivery', out_for_delivery_at: new Date().toISOString() })
    .eq('id', order.id)
    .eq('status', 'searching_livreur')
    .select('id')
    .maybeSingle();
  if (error) throw new HttpError(500, error.message);
  if (!updated) throw new HttpError(409, 'تم قبول توصيل هذا الطلب من طرف مندوب آخر');

  await createNotification(admin, {
    userId: order.client_id,
    title: 'في الطريق إليك',
    body: 'انطلق مندوب التوصيل لإحضار طلبك.',
    data: { order_id: order.id, status: 'out_for_delivery' },
  });

  return { ok: true, order_id: order.id, status: 'out_for_delivery' };
}

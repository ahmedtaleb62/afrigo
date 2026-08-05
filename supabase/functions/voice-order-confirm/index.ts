// voice-order-confirm
// Step 3 (final) of the voice-order pipeline. The Client app shows the
// parsed intent from voice-order-parse-intent on a confirmation screen —
// the user can edit any field there (e.g. pick the exact pickup point on
// the map, or the exact restaurant/dishes) before confirming. This
// function does NOT re-run geocoding or fuzzy restaurant matching itself:
// by the time the user taps "confirm", the app has already resolved
// addresses to coordinates (via its own map picker) and dish names to
// `dish_id`s (via its own menu browse), the same way a manually-built
// order would. So `payload` here is exactly the body request-ride /
// request-food-order / request-delivery already expect — this function's
// only job is to (a) verify it matches the voice order's own classified
// service_type, so the confirm screen can't be tricked into creating an
// unrelated order type, and (b) forward the call, reusing that function's
// full validation/matching logic rather than duplicating it.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';

type OrderType = 'ride' | 'food_order' | 'delivery_request';

interface Body {
  voice_order_id: string;
  order_type: OrderType;
  payload: Record<string, unknown>;
}

const SERVICE_TO_ORDER_TYPE: Record<string, OrderType> = {
  ride: 'ride',
  food: 'food_order',
  delivery: 'delivery_request',
};

const ORDER_TYPE_TO_FUNCTION: Record<OrderType, string> = {
  ride: 'request-ride',
  food_order: 'request-food-order',
  delivery_request: 'request-delivery',
};

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    if (!body.voice_order_id || !body.order_type || !body.payload) throw new HttpError(400, 'بيانات ناقصة');

    const { data: voiceOrder } = await admin
      .from('voice_orders')
      .select('id, client_id, service_type, status')
      .eq('id', body.voice_order_id)
      .maybeSingle();
    if (!voiceOrder) throw new HttpError(404, 'الطلب الصوتي غير موجود');
    if (voiceOrder.client_id !== user.id) throw new HttpError(403, 'هذا الطلب الصوتي ليس لك');
    if (voiceOrder.status !== 'pending_confirmation') throw new HttpError(400, 'هذا الطلب الصوتي ليس بانتظار التأكيد');

    const expectedOrderType = SERVICE_TO_ORDER_TYPE[voiceOrder.service_type ?? ''];
    if (body.order_type !== expectedOrderType) throw new HttpError(400, 'نوع الطلب لا يطابق ما تم فهمه من التسجيل الصوتي');

    const functionName = ORDER_TYPE_TO_FUNCTION[body.order_type];
    const forwardResp = await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/${functionName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: req.headers.get('Authorization') ?? '',
        apikey: Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      },
      body: JSON.stringify(body.payload),
    });
    const forwardJson = await forwardResp.json();

    if (!forwardResp.ok) {
      await admin
        .from('voice_orders')
        .update({ status: 'failed', failure_reason: forwardJson.error ?? 'تعذّر إنشاء الطلب' })
        .eq('id', voiceOrder.id);
      throw new HttpError(forwardResp.status, forwardJson.error ?? 'تعذّر إنشاء الطلب');
    }

    const resultingOrderId = forwardJson.ride_id ?? forwardJson.order_id ?? forwardJson.delivery_id;
    await admin
      .from('voice_orders')
      .update({ status: 'confirmed', resulting_order_id: resultingOrderId, resulting_order_type: body.order_type })
      .eq('id', voiceOrder.id);

    return { voice_order_id: voiceOrder.id, status: 'confirmed', ...forwardJson };
  }),
);

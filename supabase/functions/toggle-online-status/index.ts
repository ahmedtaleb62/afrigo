// toggle-online-status
// The only path that may ever flip `vehicles.is_online` / `restaurants.is_open`
// (both are guarded against direct client writes — see
// `vehicles_guard()`/`restaurants_guard()`). Rejects with a clear message
// unless the caller's provider record is `verified` AND their wallet
// balance is above `low_balance_threshold` — this is what actually
// prevents "online" from ever being reachable in the forbidden states
// (screens 52/66/77 in the design).
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';

interface Body {
  online: boolean;
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    const { data: profile } = await admin.from('profiles').select('role').eq('id', user.id).maybeSingle();
    if (!profile) throw new HttpError(404, 'الملف الشخصي غير موجود');

    const { data: wallet } = await admin
      .from('wallets')
      .select('balance, low_balance_threshold')
      .eq('owner_id', user.id)
      .maybeSingle();
    const hasBalance = !!wallet && wallet.balance > wallet.low_balance_threshold;

    if (profile.role === 'restaurant_owner') {
      const { data: restaurant } = await admin
        .from('restaurants')
        .select('id, status')
        .eq('owner_id', user.id)
        .maybeSingle();
      if (!restaurant) throw new HttpError(404, 'لا يوجد مطعم مرتبط بهذا الحساب');
      if (body.online && (restaurant.status !== 'verified' || !hasBalance)) {
        throw new HttpError(
          400,
          restaurant.status !== 'verified' ? 'يجب أن يكون المطعم موثّقًا أولًا' : 'رصيدك غير كافٍ، يرجى شحن رصيدك',
        );
      }
      const { error } = await admin.from('restaurants').update({ is_open: body.online }).eq('id', restaurant.id);
      if (error) throw new HttpError(500, error.message);
      return { online: body.online };
    }

    if (profile.role === 'taxi_driver' || profile.role === 'livreur') {
      const serviceType = profile.role === 'taxi_driver' ? 'taxi' : 'delivery';
      const { data: vehicle } = await admin
        .from('vehicles')
        .select('id, status')
        .eq('owner_id', user.id)
        .eq('service_type', serviceType)
        .maybeSingle();
      if (!vehicle) throw new HttpError(404, 'لا توجد مركبة مرتبطة بهذا الحساب');
      if (body.online && (vehicle.status !== 'verified' || !hasBalance)) {
        throw new HttpError(
          400,
          vehicle.status !== 'verified' ? 'يجب أن تكون المركبة موثّقة أولًا' : 'رصيدك غير كافٍ، يرجى شحن رصيدك',
        );
      }
      const { error } = await admin.from('vehicles').update({ is_online: body.online }).eq('id', vehicle.id);
      if (error) throw new HttpError(500, error.message);
      return { online: body.online };
    }

    throw new HttpError(400, 'هذا الحساب لا يملك خدمة يمكن تفعيلها');
  }),
);

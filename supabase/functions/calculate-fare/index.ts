// calculate-fare
// Used by the ride/food/delivery confirm screens (Client app 14/26/34) to
// show a real price before the user commits. See _shared/fare.ts for the
// Google Distance Matrix / haversine-fallback logic.
import { withHandler } from '../_shared/handler.ts';
import { serviceClient, HttpError } from '../_shared/clients.ts';
import { calculateFare, type LatLng } from '../_shared/fare.ts';

interface Body {
  service_type: 'taxi' | 'food' | 'delivery';
  pickup: LatLng;
  dropoff: LatLng;
}

Deno.serve(
  withHandler<Body>(async (_req, body) => {
    if (!['taxi', 'food', 'delivery'].includes(body.service_type)) throw new HttpError(400, 'نوع خدمة غير صالح');
    if (!body.pickup || !body.dropoff) throw new HttpError(400, 'إحداثيات الانطلاق والوجهة مطلوبة');

    const admin = serviceClient();
    const { distanceKm, durationMin, price } = await calculateFare(admin, body.service_type, body.pickup, body.dropoff);

    return { distance_km: distanceKm, duration_min: durationMin, price };
  }),
);

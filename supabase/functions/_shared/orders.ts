// Order-creation logic shared between the 3 request-* functions (called
// directly from each app's checkout screen) and voice-order-confirm (called
// after a voice order's parsed intent has been reviewed/edited by the
// client). Keeping this in one place means the PostGIS matching / fare /
// broadcast behavior can't drift between the two entry points.
import type { serviceClient } from './clients.ts';
import { HttpError } from './clients.ts';
import { calculateFare, toWkt, type LatLng } from './fare.ts';
import { broadcast } from './broadcast.ts';
import { createNotification } from './notify.ts';

const SEARCH_RADIUS_M = 3000;

type Admin = ReturnType<typeof serviceClient>;

async function assertNotSuspended(admin: Admin, clientId: string) {
  const { data: profile } = await admin.from('profiles').select('is_suspended').eq('id', clientId).maybeSingle();
  if (!profile) throw new HttpError(404, 'الملف الشخصي غير موجود');
  if (profile.is_suspended) throw new HttpError(403, 'حسابك موقوف، لا يمكنك إرسال طلبات');
}

export type PaymentMethod = 'cash' | 'baridimob' | 'bank_transfer';

export interface RideBody {
  pickup: LatLng;
  pickup_address: string;
  dropoff: LatLng;
  dropoff_address: string;
  client_note?: string;
  payment_method?: PaymentMethod;
  vehicle_class?: string;
}

export async function createRide(admin: Admin, clientId: string, body: RideBody) {
  if (!body.pickup || !body.dropoff || !body.pickup_address || !body.dropoff_address) {
    throw new HttpError(400, 'بيانات الرحلة غير مكتملة');
  }
  await assertNotSuspended(admin, clientId);

  const { distanceKm, durationMin, price } = await calculateFare(admin, 'taxi', body.pickup, body.dropoff);

  const { data: ride, error: insertError } = await admin
    .from('rides')
    .insert({
      client_id: clientId,
      pickup_location: toWkt(body.pickup),
      pickup_address: body.pickup_address,
      pickup_lat: body.pickup.lat,
      pickup_lng: body.pickup.lng,
      dropoff_location: toWkt(body.dropoff),
      dropoff_address: body.dropoff_address,
      dropoff_lat: body.dropoff.lat,
      dropoff_lng: body.dropoff.lng,
      distance_km: distanceKm,
      duration_min: durationMin,
      price,
      status: 'searching',
      client_note: body.client_note ?? null,
      payment_method: body.payment_method ?? 'cash',
      vehicle_class: body.vehicle_class ?? null,
    })
    .select('id')
    .single();
  if (insertError || !ride) throw new HttpError(500, insertError?.message ?? 'تعذّر إنشاء الرحلة');

  const { data: drivers } = await admin.rpc('find_nearby_vehicles', {
    p_pickup: toWkt(body.pickup),
    p_service_type: 'taxi',
    p_radius_m: SEARCH_RADIUS_M,
  });

  if (!drivers || drivers.length === 0) {
    await admin.from('rides').update({ status: 'no_driver_found' }).eq('id', ride.id);
    return { order_id: ride.id, status: 'no_driver_found', distance_km: distanceKm, duration_min: durationMin, price };
  }

  // Realtime Broadcast is the low-latency path for a driver who already has
  // the app open; it's lost the instant Android suspends a backgrounded
  // app's socket. `createNotification` (real `notifications` row + FCM
  // push, see notify.ts) is what actually reaches a driver otherwise — the
  // exact gap that made every ride "بحث بلا توقف" until a driver happened
  // to be staring at the screen at the right moment.
  await Promise.all(
    drivers.map((d: { owner_id: string }) =>
      Promise.all([
        broadcast(`driver:${d.owner_id}:incoming_orders`, 'incoming_ride', {
          ride_id: ride.id,
          pickup_address: body.pickup_address,
          pickup_lat: body.pickup.lat,
          pickup_lng: body.pickup.lng,
          dropoff_address: body.dropoff_address,
          dropoff_lat: body.dropoff.lat,
          dropoff_lng: body.dropoff.lng,
          distance_km: distanceKm,
          price,
        }),
        createNotification(admin, {
          userId: d.owner_id,
          title: 'طلب رحلة جديد',
          body: `${body.pickup_address} · ${distanceKm.toFixed(1)} كم · ${price.toFixed(0)} أوقية تقديريًا`,
          data: { type: 'incoming_ride', ride_id: ride.id },
        }),
      ]),
    ),
  );

  return { order_id: ride.id, status: 'searching', distance_km: distanceKm, duration_min: durationMin, price, matched_drivers: drivers.length };
}

export interface DeliveryBody {
  pickup: LatLng;
  pickup_address: string;
  dropoff: LatLng;
  dropoff_address: string;
  recipient_name: string;
  recipient_phone: string;
  package_type: string;
  package_notes?: string;
  package_image_url?: string;
  payment_method?: PaymentMethod;
}

export async function createDelivery(admin: Admin, clientId: string, body: DeliveryBody) {
  if (!body.pickup || !body.dropoff || !body.recipient_name || !body.recipient_phone || !body.package_type) {
    throw new HttpError(400, 'بيانات الطرد غير مكتملة');
  }
  await assertNotSuspended(admin, clientId);

  const { distanceKm, price } = await calculateFare(admin, 'delivery', body.pickup, body.dropoff);

  const { data: delivery, error: insertError } = await admin
    .from('delivery_requests')
    .insert({
      client_id: clientId,
      pickup_location: toWkt(body.pickup),
      pickup_address: body.pickup_address,
      dropoff_location: toWkt(body.dropoff),
      dropoff_address: body.dropoff_address,
      recipient_name: body.recipient_name,
      recipient_phone: body.recipient_phone,
      package_type: body.package_type,
      package_notes: body.package_notes ?? null,
      package_image_url: body.package_image_url ?? null,
      distance_km: distanceKm,
      price,
      status: 'searching',
      payment_method: body.payment_method ?? 'cash',
    })
    .select('id')
    .single();
  if (insertError || !delivery) throw new HttpError(500, insertError?.message ?? 'تعذّر إنشاء طلب التوصيل');

  const { data: couriers } = await admin.rpc('find_nearby_vehicles', {
    p_pickup: toWkt(body.pickup),
    p_service_type: 'delivery',
    p_radius_m: SEARCH_RADIUS_M,
  });

  if (!couriers || couriers.length === 0) {
    await admin.from('delivery_requests').update({ status: 'no_livreur_found' }).eq('id', delivery.id);
    return { order_id: delivery.id, status: 'no_livreur_found', distance_km: distanceKm, price };
  }

  await Promise.all(
    couriers.map((c: { owner_id: string }) =>
      Promise.all([
        broadcast(`delivery:${c.owner_id}:incoming_orders`, 'incoming_delivery', {
          delivery_id: delivery.id,
          pickup_address: body.pickup_address,
          dropoff_address: body.dropoff_address,
          distance_km: distanceKm,
          price,
        }),
        createNotification(admin, {
          userId: c.owner_id,
          title: 'طلب توصيل جديد',
          body: `${body.pickup_address} · ${distanceKm.toFixed(1)} كم · ${price.toFixed(0)} أوقية تقديريًا`,
          data: { type: 'incoming_delivery', delivery_id: delivery.id },
        }),
      ]),
    ),
  );

  return { order_id: delivery.id, status: 'searching', distance_km: distanceKm, price, matched_couriers: couriers.length };
}

export interface FoodOrderBody {
  restaurant_id: string;
  items: { dish_id: string; qty: number }[];
  delivery_address?: string;
  delivery_location?: LatLng;
  client_note?: string;
  payment_method?: PaymentMethod;
  /// The client collects the order themselves — skips the delivery fee and
  /// the livreur-matching leg entirely (see `markFoodOrderReadyAndSearchLivreur`
  /// in update-order-status/index.ts).
  is_pickup?: boolean;
}

export async function createFoodOrder(admin: Admin, clientId: string, body: FoodOrderBody) {
  const isPickup = body.is_pickup === true;
  if (!body.restaurant_id || !body.items?.length || (!isPickup && (!body.delivery_address || !body.delivery_location))) {
    throw new HttpError(400, 'بيانات الطلب غير مكتملة');
  }
  await assertNotSuspended(admin, clientId);

  const { data: restaurant } = await admin
    .from('restaurants')
    .select('id, owner_id, status, is_open, delivery_fee, min_order')
    .eq('id', body.restaurant_id)
    .maybeSingle();
  if (!restaurant) throw new HttpError(404, 'المطعم غير موجود');
  if (restaurant.status !== 'verified' || !restaurant.is_open) throw new HttpError(400, 'المطعم غير متاح حاليًا لاستقبال الطلبات');

  // Merge duplicate dish_id entries before the lookup — `.in('id', dishIds)`
  // naturally dedupes against restaurant_dishes' primary key, so comparing
  // raw lengths against an un-deduped cart would wrongly reject a cart with
  // the same dish listed twice as separate line items ("dish not found")
  // instead of just summing the quantity.
  const qtyByDishId = new Map<string, number>();
  for (const item of body.items) qtyByDishId.set(item.dish_id, (qtyByDishId.get(item.dish_id) ?? 0) + item.qty);
  const dishIds = [...qtyByDishId.keys()];
  const { data: dishes } = await admin
    .from('restaurant_dishes')
    .select('id, name, price, is_available, available_for_delivery, stock_quantity')
    .eq('restaurant_id', body.restaurant_id)
    .in('id', dishIds);
  if (!dishes || dishes.length !== dishIds.length) throw new HttpError(400, 'أحد الأطباق غير موجود في هذا المطعم');

  const lineItems = dishIds.map((dishId) => {
    const dish = dishes.find((d) => d.id === dishId)!;
    const qty = qtyByDishId.get(dishId)!;
    // `available_for_delivery` only makes sense for a delivery leg — a dish
    // too fragile/hot to survive a moto ride can still be handed over fine
    // in person, so a pickup order only needs `is_available`.
    if (!dish.is_available || (!isPickup && !dish.available_for_delivery)) throw new HttpError(400, `الطبق "${dish.name}" غير متاح حاليًا`);
    if (!Number.isInteger(qty) || qty <= 0) throw new HttpError(400, 'الكمية غير صالحة');
    // Nothing checked this before — a client could order more of a dish
    // than the restaurant's own `stock_quantity` (real case that shipped:
    // 27 ordered against a stock of 20). `stock_quantity` isn't
    // auto-decremented on order (the restaurant manages it manually via
    // the +/- stepper in the app), so this is a per-order cap against
    // whatever the restaurant has currently set, not a running inventory
    // reservation system.
    if (dish.stock_quantity > 0 && qty > dish.stock_quantity) {
      throw new HttpError(400, `الكمية المطلوبة من "${dish.name}" تتجاوز المخزون المتاح (${dish.stock_quantity})`);
    }
    return { dish_id: dish.id, name: dish.name, price: dish.price, qty };
  });

  const subtotal = lineItems.reduce((sum, i) => sum + i.price * i.qty, 0);
  if (subtotal < restaurant.min_order) throw new HttpError(400, `الحد الأدنى للطلب هو ${restaurant.min_order} أوقية`);
  const deliveryFee = isPickup ? 0 : restaurant.delivery_fee;
  const total = subtotal + deliveryFee;

  const { data: order, error: insertError } = await admin
    .from('food_orders')
    .insert({
      client_id: clientId,
      restaurant_id: body.restaurant_id,
      items: lineItems,
      subtotal,
      delivery_fee: deliveryFee,
      total,
      is_pickup: isPickup,
      delivery_address: isPickup ? 'استلام من المطعم' : body.delivery_address,
      delivery_location: isPickup ? null : toWkt(body.delivery_location!),
      client_note: body.client_note ?? null,
      status: 'pending_restaurant',
      payment_method: body.payment_method ?? 'cash',
    })
    .select('id')
    .single();
  if (insertError || !order) throw new HttpError(500, insertError?.message ?? 'تعذّر إنشاء الطلب');

  // Same reasoning as createRide/createDelivery above this function: the
  // Broadcast alone is lost the instant the restaurant's app is
  // backgrounded (normal for kitchen staff) — createNotification's real
  // `notifications` row + FCM push is what actually reaches them otherwise.
  await Promise.all([
    broadcast(`restaurant:${body.restaurant_id}:incoming_orders`, 'incoming_food_order', {
      order_id: order.id,
      total,
      items_count: lineItems.length,
    }),
    createNotification(admin, {
      userId: restaurant.owner_id,
      title: 'طلب طعام جديد',
      body: `طلب جديد بقيمة ${total.toFixed(0)} أوقية (${lineItems.length} صنف)`,
      data: { type: 'incoming_food_order', order_id: order.id },
    }),
  ]);

  return { order_id: order.id, status: 'pending_restaurant', subtotal, delivery_fee: deliveryFee, total };
}

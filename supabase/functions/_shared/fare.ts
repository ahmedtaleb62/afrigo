import type { SupabaseClient } from 'npm:@supabase/supabase-js@2';

export interface LatLng {
  lat: number;
  lng: number;
}

const GOOGLE_MAPS_API_KEY = Deno.env.get('GOOGLE_MAPS_API_KEY');

function haversineKm(a: LatLng, b: LatLng): number {
  const R = 6371;
  const dLat = ((b.lat - a.lat) * Math.PI) / 180;
  const dLng = ((b.lng - a.lng) * Math.PI) / 180;
  const lat1 = (a.lat * Math.PI) / 180;
  const lat2 = (b.lat * Math.PI) / 180;
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

/**
 * Distance/duration from Google's Distance Matrix API when
 * `GOOGLE_MAPS_API_KEY` is set. Falls back to haversine distance + a 30 km/h
 * average speed estimate if the key is missing, the request fails, or it
 * times out, so fare calculation stays fully functional (just a rougher
 * estimate) rather than hard-failing.
 */
export async function distanceAndDuration(pickup: LatLng, dropoff: LatLng): Promise<{ distanceKm: number; durationMin: number }> {
  if (GOOGLE_MAPS_API_KEY) {
    try {
      const url = new URL('https://maps.googleapis.com/maps/api/distancematrix/json');
      url.searchParams.set('origins', `${pickup.lat},${pickup.lng}`);
      url.searchParams.set('destinations', `${dropoff.lat},${dropoff.lng}`);
      url.searchParams.set('key', GOOGLE_MAPS_API_KEY);
      // Without a timeout, a Google request that just hangs (rather than
      // erroring) would stall order creation until the platform's own
      // function wall-clock limit kills it — a hard failure instead of the
      // graceful haversine degrade this whole try/catch exists for.
      const res = await fetch(url, { signal: AbortSignal.timeout(5000) });
      const json = await res.json();
      const el = json?.rows?.[0]?.elements?.[0];
      if (el?.status === 'OK') {
        return { distanceKm: el.distance.value / 1000, durationMin: el.duration.value / 60 };
      }
    } catch (err) {
      console.error('Distance Matrix call failed, falling back to haversine:', err);
    }
  }
  const distanceKm = haversineKm(pickup, dropoff);
  return { distanceKm, durationMin: (distanceKm / 30) * 60 };
}

export async function calculateFare(
  admin: SupabaseClient,
  serviceType: 'taxi' | 'food' | 'delivery',
  pickup: LatLng,
  dropoff: LatLng,
): Promise<{ distanceKm: number; durationMin: number; price: number }> {
  const { data: pricing, error } = await admin
    .from('pricing_settings')
    .select('base_fare, price_per_km, price_per_min')
    .eq('service_type', serviceType)
    .single();
  if (error || !pricing) throw new Error('إعدادات التسعير غير متوفرة');

  const { distanceKm, durationMin } = await distanceAndDuration(pickup, dropoff);
  const price = pricing.base_fare + distanceKm * pricing.price_per_km + durationMin * pricing.price_per_min;

  return {
    distanceKm: Math.round(distanceKm * 10) / 10,
    durationMin: Math.round(durationMin),
    price: Math.round(price),
  };
}

export function toWkt(point: LatLng): string {
  return `POINT(${point.lng} ${point.lat})`;
}

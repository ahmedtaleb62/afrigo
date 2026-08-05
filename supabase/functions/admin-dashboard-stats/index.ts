// admin-dashboard-stats
// Backs the Admin panel's Overview page (screen 84). Admin-only. All the
// actual aggregation happens in a single SQL round trip via the
// `admin_dashboard_stats` RPC (see
// supabase/migrations/20260802120001_admin_dashboard_stats_rpc.sql) rather
// than assembling ~10 separate PostgREST queries here — a dashboard load
// should be one query, not ten.
//
// Does not cover the Overview page's geographic-density heatmap card — see
// that migration's header comment for why.
import { withHandler } from '../_shared/handler.ts';
import { requireAdmin, serviceClient, HttpError } from '../_shared/clients.ts';

interface Body {
  period?: 'day' | 'week' | 'month' | 'year';
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    await requireAdmin(req);
    const admin = serviceClient();

    const period = body?.period ?? 'week';
    if (!['day', 'week', 'month', 'year'].includes(period)) throw new HttpError(400, 'فترة غير صالحة');

    const { data, error } = await admin.rpc('admin_dashboard_stats', { p_period: period });
    if (error) throw new HttpError(500, error.message);

    return data;
  }),
);

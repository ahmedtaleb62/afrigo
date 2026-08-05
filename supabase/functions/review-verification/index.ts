// review-verification (admin only)
// The only path that may ever set `vehicles.status`/`restaurants.status` to
// verified/rejected (both guarded — see `vehicles_guard()`/`restaurants_guard()`).
// Used by the Admin panel's Verification screen (85).
import { withHandler } from '../_shared/handler.ts';
import { requireAdmin, serviceClient, HttpError } from '../_shared/clients.ts';
import { createNotification } from '../_shared/notify.ts';

interface Body {
  entity: 'vehicle' | 'restaurant';
  id: string;
  decision: 'approve' | 'reject';
  rejection_reason?: string;
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const admin_user = await requireAdmin(req);
    const admin = serviceClient();

    if (!['vehicle', 'restaurant'].includes(body.entity)) throw new HttpError(400, 'نوع الكيان غير صالح');
    if (!body.id) throw new HttpError(400, 'المعرّف مطلوب');
    if (body.decision === 'reject' && !body.rejection_reason?.trim()) {
      throw new HttpError(400, 'سبب الرفض إجباري');
    }

    const table = body.entity === 'vehicle' ? 'vehicles' : 'restaurants';
    const status = body.decision === 'approve' ? 'verified' : 'rejected';

    const { data: row, error: fetchError } = await admin
      .from(table)
      .select('id, owner_id, status')
      .eq('id', body.id)
      .maybeSingle();
    if (fetchError || !row) throw new HttpError(404, 'السجل غير موجود');
    if (row.status !== 'pending') throw new HttpError(400, 'تمت مراجعة هذا الطلب مسبقًا');

    const patch: Record<string, unknown> = {
      status,
      rejection_reason: body.decision === 'reject' ? body.rejection_reason!.trim() : null,
    };
    if (body.entity === 'vehicle') {
      patch.reviewed_by = admin_user.id;
      patch.reviewed_at = new Date().toISOString();
    }

    const { error: updateError } = await admin.from(table).update(patch).eq('id', body.id);
    if (updateError) throw new HttpError(500, updateError.message);

    await admin.from('admin_audit_log').insert({
      admin_id: admin_user.id,
      action: body.decision === 'approve' ? 'approve_verification' : 'reject_verification',
      target_table: table,
      target_id: body.id,
      details: body.decision === 'reject' ? { rejection_reason: body.rejection_reason } : {},
    });

    await createNotification(admin, {
      userId: row.owner_id,
      title: body.decision === 'approve' ? 'تم توثيق حسابك ✅' : 'تم رفض طلب التوثيق',
      body:
        body.decision === 'approve'
          ? 'يمكنك الآن استقبال الطلبات.'
          : `سبب الرفض: ${body.rejection_reason}`,
      data: { entity: body.entity, id: body.id, status },
    });

    return { status };
  }),
);

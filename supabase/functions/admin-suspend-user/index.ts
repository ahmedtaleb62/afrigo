// admin-suspend-user (admin only)
// Used by the Admin panel's Users screen (89). `profiles.is_suspended` is
// guarded (see `profiles_guard()`) specifically so every suspension is
// forced through here and lands in `admin_audit_log`.
import { withHandler } from '../_shared/handler.ts';
import { requireAdmin, serviceClient, HttpError } from '../_shared/clients.ts';
import { createNotification } from '../_shared/notify.ts';

interface Body {
  user_id: string;
  suspended: boolean;
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const admin_user = await requireAdmin(req);
    const admin = serviceClient();

    if (!body.user_id) throw new HttpError(400, 'معرّف المستخدم مطلوب');
    if (body.user_id === admin_user.id) throw new HttpError(400, 'لا يمكنك تعليق حسابك الخاص');

    const { data: target } = await admin.from('profiles').select('id, full_name').eq('id', body.user_id).maybeSingle();
    if (!target) throw new HttpError(404, 'المستخدم غير موجود');

    const { error } = await admin.from('profiles').update({ is_suspended: body.suspended }).eq('id', body.user_id);
    if (error) throw new HttpError(500, error.message);

    await admin.from('admin_audit_log').insert({
      admin_id: admin_user.id,
      action: body.suspended ? 'suspend_user' : 'activate_user',
      target_table: 'profiles',
      target_id: body.user_id,
      details: {},
    });

    await createNotification(admin, {
      userId: body.user_id,
      title: body.suspended ? 'تم تعليق حسابك' : 'تم إعادة تفعيل حسابك',
      body: body.suspended
        ? 'تم تعليق حسابك من طرف الإدارة. تواصل مع الدعم لمزيد من المعلومات.'
        : 'يمكنك الآن استخدام حسابك بشكل طبيعي.',
      data: { suspended: body.suspended },
    });

    return { suspended: body.suspended };
  }),
);

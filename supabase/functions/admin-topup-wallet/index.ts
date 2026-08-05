// admin-topup-wallet (admin only)
// Used by the Admin panel's Wallets screen (86). `wallets.balance` has no
// UPDATE policy for anyone (see 20260731230005_wallets.sql) — this is the
// only path a balance can ever increase from an admin action.
import { withHandler } from '../_shared/handler.ts';
import { requireAdmin, serviceClient, HttpError } from '../_shared/clients.ts';
import { createNotification } from '../_shared/notify.ts';

interface Body {
  wallet_id: string;
  amount: number;
  note?: string;
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const admin_user = await requireAdmin(req);
    const admin = serviceClient();

    if (!body.wallet_id) throw new HttpError(400, 'معرّف المحفظة مطلوب');
    const amount = Number(body.amount);
    if (!Number.isFinite(amount) || amount <= 0) throw new HttpError(400, 'المبلغ يجب أن يكون رقمًا موجبًا');

    const { data: wallet } = await admin.from('wallets').select('id, owner_id').eq('id', body.wallet_id).maybeSingle();
    if (!wallet) throw new HttpError(404, 'المحفظة غير موجودة');

    const { data: newBalance, error: rpcError } = await admin.rpc('increment_wallet_balance', {
      p_wallet_id: wallet.id,
      p_delta: amount,
    });
    if (rpcError) throw new HttpError(500, rpcError.message);

    await admin.from('wallet_transactions').insert({
      wallet_id: wallet.id,
      amount,
      type: 'topup',
      note: body.note?.trim() || 'شحن رصيد يدوي',
      created_by: admin_user.id,
    });

    await admin.from('admin_audit_log').insert({
      admin_id: admin_user.id,
      action: 'topup_wallet',
      target_table: 'wallets',
      target_id: wallet.id,
      details: { amount, note: body.note ?? null },
    });

    await createNotification(admin, {
      userId: wallet.owner_id,
      title: 'تم شحن رصيدك',
      body: `تم إضافة ${amount} أوقية إلى محفظتك.`,
      data: { wallet_id: wallet.id, amount },
    });

    return { balance: newBalance };
  }),
);

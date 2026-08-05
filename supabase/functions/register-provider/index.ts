// register-provider
// Called by every app (Client/Taxi/Food/Livreur/Admin-created-accounts)
// immediately after `supabase.auth.signUp()` succeeds. Creates the
// `profiles` row (role assignment — the one thing a client can never do
// itself, see `profiles_guard()`) and a `wallets` row at balance 0.
// Idempotent: safe to call again for a user that already has a profile.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';

const VALID_ROLES = ['client', 'taxi_driver', 'restaurant_owner', 'livreur'] as const;
type Role = (typeof VALID_ROLES)[number];

interface Body {
  role: Role;
  full_name: string;
  phone?: string;
  language_pref?: 'ar' | 'fr';
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);

    if (!VALID_ROLES.includes(body.role)) {
      throw new HttpError(400, 'دور غير صالح');
    }
    if (!body.full_name?.trim()) {
      throw new HttpError(400, 'الاسم الكامل مطلوب');
    }

    const admin = serviceClient();

    const { data: existing } = await admin.from('profiles').select('id').eq('id', user.id).maybeSingle();
    if (existing) {
      return { profileId: user.id, alreadyExisted: true };
    }

    const { error: profileError } = await admin.from('profiles').insert({
      id: user.id,
      role: body.role,
      full_name: body.full_name.trim(),
      email: user.email,
      phone: body.phone ?? null,
      language_pref: body.language_pref ?? 'ar',
    });
    if (profileError) throw new HttpError(500, `تعذّر إنشاء الملف الشخصي: ${profileError.message}`);

    const { error: walletError } = await admin.from('wallets').insert({ owner_id: user.id, balance: 0 });
    if (walletError) throw new HttpError(500, `تعذّر إنشاء المحفظة: ${walletError.message}`);

    return { profileId: user.id, alreadyExisted: false };
  }),
);

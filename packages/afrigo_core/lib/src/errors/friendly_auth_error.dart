/// Supabase Auth (`AuthException`) surfaces raw, English, sometimes
/// security-vague messages ("Invalid login credentials", "User already
/// registered") — every app in the family was showing these straight to
/// the user instead of a real Arabic message. Takes plain strings rather
/// than `AuthException` itself so this package doesn't need a
/// `supabase_flutter` dependency; callers pass `e.code`/`e.message`.
///
/// `code` (when present — see
/// https://supabase.com/docs/guides/auth/debugging/error-codes) is checked
/// first since it's stable across Supabase copy changes; a substring match
/// on `message` covers the common cases that ship without a code (e.g. a
/// wrong-password login, which Supabase intentionally leaves generic for
/// security). Anything unrecognized falls back to the caller-supplied
/// default rather than ever leaking the raw text.
String friendlyAuthError({required String? code, required String message, required String fallback}) {
  switch (code) {
    case 'user_already_exists':
    case 'email_exists':
    case 'phone_exists':
    case 'identity_already_exists':
      return 'هذا الحساب مسجل بالفعل';
    case 'weak_password':
      return 'كلمة المرور ضعيفة جدًا، اختر كلمة مرور أقوى';
    case 'email_not_confirmed':
      return 'يرجى تأكيد البريد الإلكتروني أولًا';
    case 'phone_not_confirmed':
      return 'يرجى تأكيد رقم الهاتف أولًا';
    case 'user_banned':
      return 'تم تعليق هذا الحساب، تواصل مع الدعم';
    case 'user_not_found':
      return 'لا يوجد حساب بهذه البيانات';
    case 'session_expired':
    case 'session_not_found':
    case 'session_missing':
      return 'انتهت صلاحية الجلسة، سجّل الدخول مجددًا';
    case 'over_email_send_rate_limit':
    case 'over_sms_send_rate_limit':
    case 'over_request_rate_limit':
      return 'محاولات كثيرة جدًا، حاول مرة أخرى بعد قليل';
    case 'signup_disabled':
    case 'email_provider_disabled':
      return 'التسجيل غير متاح حاليًا';
    case 'same_password':
      return 'كلمة المرور الجديدة مطابقة للقديمة';
    case 'otp_expired':
      return 'انتهت صلاحية الرمز، اطلب رمزًا جديدًا';
  }

  final m = message.toLowerCase();
  if (m.contains('invalid login credentials')) return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
  if (m.contains('already registered') || m.contains('already exists')) return 'هذا البريد الإلكتروني مسجل بالفعل';
  if (m.contains('password should be at least') || m.contains('password is too short')) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  if (m.contains('email') && m.contains('invalid')) return 'صيغة البريد الإلكتروني غير صحيحة';
  if (m.contains('network') || m.contains('socket') || m.contains('timeout')) return 'تعذّر الاتصال، تحقق من الإنترنت وحاول مجددًا';

  return fallback;
}

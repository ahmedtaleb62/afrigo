// Supabase Auth "Send SMS" hook — GoTrue calls this directly (not through
// the normal client SDK) whenever phone signup/signInWithOtp/resend needs an
// OTP delivered, and expects an empty 200 response on success. This project
// has no Twilio/MessageBird/Vonage account (none of Supabase's built-in SMS
// providers), so this hook is the integration point for Chinguisoft
// (https://chinguisoft.com/sms/validation), a Mauritania-focused SMS OTP
// vendor: GoTrue still owns OTP generation/expiry/matching, this function's
// only job is relaying the code GoTrue already generated to Chinguisoft so
// it reaches the phone over SMS.
//
// Must be deployed with `--no-verify-jwt` — GoTrue does not send a project
// JWT here, it signs the request per the Standard Webhooks spec instead
// (verified below using the same secret configured as `hook_send_sms_secrets`
// in the project's auth config).
import { Webhook } from 'npm:standardwebhooks@1.0.0';

const hookSecret = Deno.env.get('SEND_SMS_HOOK_SECRET') ?? '';
const chinguisoftKey = Deno.env.get('CHINGUISOFT_VALIDATION_KEY') ?? '';
const chinguisoftToken = Deno.env.get('CHINGUISOFT_VALIDATION_TOKEN') ?? '';

interface SendSmsPayload {
  user: { phone?: string };
  sms: { otp: string };
}

function errorResponse(httpCode: number, message: string): Response {
  return new Response(JSON.stringify({ error: { http_code: httpCode, message } }), {
    status: httpCode,
    headers: { 'Content-Type': 'application/json' },
  });
}

// Mauritanian mobile numbers are 8 digits starting with 2, 3, or 4;
// Supabase stores/sends the E.164 form (`+222XXXXXXXX`) as `user.phone` —
// Chinguisoft's API wants just the local 8-digit number.
function toLocalMauritanianNumber(e164Phone: string): string | null {
  const match = /^\+?222(\d{8})$/.exec(e164Phone);
  return match ? match[1] : null;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return errorResponse(405, 'Method not allowed');
  if (!hookSecret) return errorResponse(500, 'SEND_SMS_HOOK_SECRET is not configured');
  if (!chinguisoftKey || !chinguisoftToken) {
    return errorResponse(500, 'Chinguisoft credentials are not configured yet');
  }

  const payload = await req.text();
  const headers = Object.fromEntries(req.headers);

  let data: SendSmsPayload;
  try {
    data = new Webhook(hookSecret).verify(payload, headers) as SendSmsPayload;
  } catch (_err) {
    return errorResponse(401, 'Invalid webhook signature');
  }

  const e164Phone = data.user?.phone;
  const otp = data.sms?.otp;
  if (!e164Phone || !otp) return errorResponse(400, 'Missing phone or otp in hook payload');

  const localPhone = toLocalMauritanianNumber(e164Phone);
  if (!localPhone) return errorResponse(400, `Unsupported phone format: ${e164Phone}`);

  let chinguisoftRes: Response;
  try {
    chinguisoftRes = await fetch(`https://chinguisoft.com/api/sms/validation/${chinguisoftKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Validation-token': chinguisoftToken },
      body: JSON.stringify({ phone: localPhone, lang: 'ar', code: otp }),
    });
  } catch (_err) {
    return errorResponse(503, 'Could not reach Chinguisoft');
  }

  if (!chinguisoftRes.ok) {
    const detail = await chinguisoftRes.text().catch(() => '');
    console.error('Chinguisoft send failed', chinguisoftRes.status, detail);
    return errorResponse(503, 'تعذّر إرسال رمز التحقق عبر الرسائل القصيرة');
  }

  return new Response(JSON.stringify({}), { status: 200, headers: { 'Content-Type': 'application/json' } });
});

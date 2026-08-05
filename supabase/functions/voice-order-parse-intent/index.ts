// voice-order-parse-intent
// Step 2 of the voice-order pipeline. Takes the transcript
// voice-order-transcribe produced and asks Claude to extract a structured
// order intent (which service, and its key fields) so the Client app can
// show a confirmation screen before anything real is created.
//
// No ANTHROPIC_API_KEY is available in this environment — same "fail
// loudly, mark the row, keep the contract real" approach as
// voice-order-transcribe. Once a key is supplied via
// `supabase secrets set ANTHROPIC_API_KEY=...`, this works unchanged.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';

interface Body {
  voice_order_id: string;
}

interface ParsedIntent {
  service_type: 'ride' | 'food' | 'delivery' | 'unclear';
  confidence: number;
  pickup_address: string | null;
  dropoff_address: string | null;
  restaurant_name: string | null;
  dish_names: string[];
  package_description: string | null;
  recipient_name: string | null;
  recipient_phone: string | null;
}

const INTENT_SCHEMA = {
  type: 'object',
  properties: {
    service_type: { type: 'string', enum: ['ride', 'food', 'delivery', 'unclear'] },
    confidence: { type: 'number' },
    pickup_address: { type: ['string', 'null'] },
    dropoff_address: { type: ['string', 'null'] },
    restaurant_name: { type: ['string', 'null'] },
    dish_names: { type: 'array', items: { type: 'string' } },
    package_description: { type: ['string', 'null'] },
    recipient_name: { type: ['string', 'null'] },
    recipient_phone: { type: ['string', 'null'] },
  },
  required: [
    'service_type',
    'confidence',
    'pickup_address',
    'dropoff_address',
    'restaurant_name',
    'dish_names',
    'package_description',
    'recipient_name',
    'recipient_phone',
  ],
  additionalProperties: false,
};

const SYSTEM_PROMPT = `أنت مساعد يحوّل طلبات صوتية بالعربية (لهجة جزائرية أو فصحى) إلى نية طلب منظّمة لتطبيق Afrigo (توصيل ركاب، طعام، أو طرود).
صنّف service_type إلى: "ride" (طلب رحلة تاكسي)، "food" (طلب طعام من مطعم)، "delivery" (توصيل طرد)، أو "unclear" إذا لم يتضح النوع.
استخرج فقط المعلومات المذكورة صراحةً في النص؛ اترك الحقول غير المذكورة null أو مصفوفة فارغة. لا تخترع عناوين أو أسماء.`;

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    if (!body.voice_order_id) throw new HttpError(400, 'معرّف الطلب الصوتي مطلوب');

    const { data: voiceOrder } = await admin
      .from('voice_orders')
      .select('id, client_id, transcribed_text, status')
      .eq('id', body.voice_order_id)
      .maybeSingle();
    if (!voiceOrder) throw new HttpError(404, 'الطلب الصوتي غير موجود');
    if (voiceOrder.client_id !== user.id) throw new HttpError(403, 'هذا الطلب الصوتي ليس لك');
    if (!voiceOrder.transcribed_text) throw new HttpError(400, 'لم يتم تحويل هذا الطلب إلى نص بعد');

    const apiKey = Deno.env.get('ANTHROPIC_API_KEY');
    if (!apiKey) {
      await admin
        .from('voice_orders')
        .update({ status: 'failed', failure_reason: 'ميزة فهم الطلب الصوتي غير مفعّلة حاليًا (لم يتم تهيئة Anthropic API)' })
        .eq('id', voiceOrder.id);
      throw new HttpError(503, 'ميزة الطلب الصوتي غير متاحة حاليًا، يرجى كتابة طلبك يدويًا');
    }

    const claudeResp = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: 'claude-opus-5',
        max_tokens: 1024,
        thinking: { type: 'disabled' },
        output_config: { effort: 'low', format: { type: 'json_schema', schema: INTENT_SCHEMA } },
        system: SYSTEM_PROMPT,
        messages: [{ role: 'user', content: voiceOrder.transcribed_text }],
      }),
    });

    if (!claudeResp.ok) {
      const errText = await claudeResp.text();
      await admin.from('voice_orders').update({ status: 'failed', failure_reason: 'تعذّر فهم الطلب الصوتي' }).eq('id', voiceOrder.id);
      throw new HttpError(502, `فشل تحليل النية: ${errText}`);
    }

    const claudeJson = await claudeResp.json();
    if (claudeJson.stop_reason === 'refusal') {
      await admin.from('voice_orders').update({ status: 'failed', failure_reason: 'تعذّر فهم الطلب الصوتي' }).eq('id', voiceOrder.id);
      throw new HttpError(422, 'تعذّر فهم الطلب الصوتي، حاول صياغته بشكل مختلف');
    }

    const textBlock = (claudeJson.content ?? []).find((b: { type: string }) => b.type === 'text');
    if (!textBlock) {
      await admin.from('voice_orders').update({ status: 'failed', failure_reason: 'تعذّر فهم الطلب الصوتي' }).eq('id', voiceOrder.id);
      throw new HttpError(502, 'استجابة غير متوقعة من محرك فهم اللغة');
    }

    const parsedIntent = JSON.parse(textBlock.text) as ParsedIntent;

    if (parsedIntent.service_type === 'unclear' || parsedIntent.confidence < 0.4) {
      await admin
        .from('voice_orders')
        .update({ parsed_intent: parsedIntent, status: 'failed', failure_reason: 'لم يتضح نوع الطلب من التسجيل الصوتي' })
        .eq('id', voiceOrder.id);
      throw new HttpError(422, 'لم يتضح نوع طلبك، يرجى إعادة المحاولة أو الكتابة يدويًا');
    }

    await admin
      .from('voice_orders')
      .update({ parsed_intent: parsedIntent, service_type: parsedIntent.service_type, status: 'pending_confirmation' })
      .eq('id', voiceOrder.id);

    return { voice_order_id: voiceOrder.id, status: 'pending_confirmation', parsed_intent: parsedIntent };
  }),
);

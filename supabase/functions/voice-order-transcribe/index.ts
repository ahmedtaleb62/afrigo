// voice-order-transcribe
// Step 1 of the voice-order pipeline (Client app's voice-order screen). The
// client has already uploaded the recording to Storage and inserted a
// `voice_orders` row (status: 'processing', per its own INSERT policy —
// see supabase/migrations/20260731230011_voice_orders.sql). This function
// downloads that recording and transcribes it with Google Cloud
// Speech-to-Text.
//
// No Google Cloud API key is available in this environment
// (GOOGLE_SPEECH_API_KEY unset). Rather than fake a transcript, this fails
// loudly and marks the row 'failed' with a clear Arabic reason — the
// contract (voice_orders.status/failure_reason) is real, only the external
// API call behind it isn't configured yet. Once a key is supplied via
// `supabase secrets set GOOGLE_SPEECH_API_KEY=...`, this function works
// with no code change.
import { withHandler } from '../_shared/handler.ts';
import { requireUser, serviceClient, HttpError } from '../_shared/clients.ts';

interface Body {
  voice_order_id: string;
  encoding: string;
  sample_rate_hertz?: number;
  language_code?: string;
}

Deno.serve(
  withHandler<Body>(async (req, body) => {
    const user = await requireUser(req);
    const admin = serviceClient();

    if (!body.voice_order_id || !body.encoding) throw new HttpError(400, 'بيانات ناقصة');

    const { data: voiceOrder } = await admin
      .from('voice_orders')
      .select('id, client_id, audio_url, status')
      .eq('id', body.voice_order_id)
      .maybeSingle();
    if (!voiceOrder) throw new HttpError(404, 'الطلب الصوتي غير موجود');
    if (voiceOrder.client_id !== user.id) throw new HttpError(403, 'هذا الطلب الصوتي ليس لك');
    if (voiceOrder.status !== 'processing') throw new HttpError(400, 'تمت معالجة هذا الطلب الصوتي بالفعل');

    const apiKey = Deno.env.get('GOOGLE_SPEECH_API_KEY');
    if (!apiKey) {
      await admin
        .from('voice_orders')
        .update({ status: 'failed', failure_reason: 'ميزة الطلب الصوتي غير مفعّلة حاليًا (لم يتم تهيئة Google Speech-to-Text)' })
        .eq('id', voiceOrder.id);
      throw new HttpError(503, 'ميزة الطلب الصوتي غير متاحة حاليًا، يرجى كتابة طلبك يدويًا');
    }

    const audioResp = await fetch(voiceOrder.audio_url);
    if (!audioResp.ok) {
      await admin.from('voice_orders').update({ status: 'failed', failure_reason: 'تعذّر تحميل التسجيل الصوتي' }).eq('id', voiceOrder.id);
      throw new HttpError(500, 'تعذّر تحميل التسجيل الصوتي');
    }
    const audioBytes = new Uint8Array(await audioResp.arrayBuffer());
    const audioBase64 = btoa(String.fromCharCode(...audioBytes));

    const sttResp = await fetch(`https://speech.googleapis.com/v1/speech:recognize?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        config: {
          encoding: body.encoding,
          sampleRateHertz: body.sample_rate_hertz,
          languageCode: body.language_code ?? 'ar-DZ',
        },
        audio: { content: audioBase64 },
      }),
    });

    if (!sttResp.ok) {
      const errText = await sttResp.text();
      await admin.from('voice_orders').update({ status: 'failed', failure_reason: 'تعذّر تحويل الصوت إلى نص' }).eq('id', voiceOrder.id);
      throw new HttpError(502, `فشل التعرف على الصوت: ${errText}`);
    }

    const sttJson = await sttResp.json();
    const transcript = (sttJson.results ?? [])
      .map((r: { alternatives: { transcript: string }[] }) => r.alternatives[0]?.transcript ?? '')
      .join(' ')
      .trim();

    if (!transcript) {
      await admin.from('voice_orders').update({ status: 'failed', failure_reason: 'لم نتمكن من فهم التسجيل الصوتي' }).eq('id', voiceOrder.id);
      throw new HttpError(422, 'لم نتمكن من فهم التسجيل الصوتي، حاول مجددًا');
    }

    await admin.from('voice_orders').update({ transcribed_text: transcript }).eq('id', voiceOrder.id);

    return { voice_order_id: voiceOrder.id, transcribed_text: transcript };
  }),
);

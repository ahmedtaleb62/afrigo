import { corsHeaders, handleOptions } from './cors.ts';
import { HttpError } from './clients.ts';

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

/**
 * Wraps a function body so every Edge Function only has to write its actual
 * logic: handles OPTIONS preflight, parses the JSON body, and turns thrown
 * `HttpError`s (or anything else) into a consistent `{ error }` JSON
 * response instead of an unhandled-exception 500 with no CORS headers.
 */
export function withHandler<TBody = Record<string, unknown>>(
  fn: (req: Request, body: TBody) => Promise<unknown>,
) {
  return async (req: Request): Promise<Response> => {
    if (req.method === 'OPTIONS') return handleOptions();
    try {
      const body = req.method === 'POST' ? ((await req.json().catch(() => ({}))) as TBody) : ({} as TBody);
      const result = await fn(req, body);
      return json(result ?? { ok: true });
    } catch (err) {
      if (err instanceof HttpError) return json({ error: err.message }, err.status);
      console.error(err);
      return json({ error: 'خطأ داخلي في الخادم' }, 500);
    }
  };
}

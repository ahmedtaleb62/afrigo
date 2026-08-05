export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

/** Every function starts with `if (req.method === 'OPTIONS') return handleOptions();` */
export function handleOptions(): Response {
  return new Response('ok', { headers: corsHeaders });
}

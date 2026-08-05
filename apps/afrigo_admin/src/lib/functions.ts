import { FunctionsHttpError } from '@supabase/supabase-js'
import { supabase } from './supabase'

/**
 * Thin wrapper around `supabase.functions.invoke` that unwraps the Edge
 * Functions' own `{"error": "..."}` JSON body into a plain `Error` message.
 * `functions.invoke` does NOT do this itself — a non-2xx response comes
 * back as `FunctionsHttpError` whose `.context` is the raw `Response`, so
 * without this, callers would only ever see a generic "Edge Function
 * returned a non-2xx status code" instead of the actual Arabic reason
 * (see supabase/functions/_shared/handler.ts on the server side).
 */
export async function invokeFunction<T = unknown>(name: string, body?: Record<string, unknown>): Promise<T> {
  const { data, error } = await supabase.functions.invoke(name, { body })
  if (error) {
    if (error instanceof FunctionsHttpError) {
      let message: string | null = null
      try {
        const parsed = await error.context.json()
        if (parsed && typeof parsed.error === 'string') message = parsed.error
      } catch {
        // response body wasn't JSON — fall through to the generic message
      }
      if (message) throw new Error(message)
    }
    throw new Error('حدث خطأ، حاول مجددًا')
  }
  return data as T
}

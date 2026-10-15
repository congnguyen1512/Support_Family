import { createClient, type SupabaseClient } from '@supabase/supabase-js';

const url = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const anonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

let client: SupabaseClient | null = null;

export const isSupabaseConfigured = url.startsWith('http') && anonKey.length > 20;

/**
 * Supabase client chỉ dùng ANON key cho 2 việc:
 *  1. Realtime (lắng nghe bảng notification) — giống bản mobile.
 *  2. Làm mới access token khi hết hạn (Backend không có endpoint refresh).
 * Mọi thao tác dữ liệu vẫn đi qua Backend REST API.
 */
export function getSupabase(): SupabaseClient | null {
  if (!isSupabaseConfigured) return null;
  if (!client) {
    client = createClient(url, anonKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
        detectSessionInUrl: false,
      },
      realtime: { params: { eventsPerSecond: 5 } },
    });
  }
  return client;
}

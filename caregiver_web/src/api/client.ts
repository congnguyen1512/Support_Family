import { getSession, useAuthStore } from '../store/auth';
import { useUiStore } from '../store/ui';
import { getSupabase } from '../lib/supabase';

const DEFAULT_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL || 'http://localhost:3000/api';

export function getApiBaseUrl(): string {
  const override = useUiStore.getState().apiBaseUrlOverride.trim();
  return (override || DEFAULT_BASE_URL).replace(/\/+$/, '');
}

export class ApiError extends Error {
  status: number;
  details?: unknown;
  constructor(message: string, status: number, details?: unknown) {
    super(message);
    this.status = status;
    this.details = details;
  }
}

type Query = Record<string, string | number | boolean | null | undefined>;

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: unknown;
  query?: Query;
  auth?: boolean;
  signal?: AbortSignal;
}

let refreshPromise: Promise<boolean> | null = null;

/** Làm mới access token qua Supabase (dùng refresh_token đã lưu). Gộp các lần gọi song song. */
async function refreshAccessToken(): Promise<boolean> {
  if (refreshPromise) return refreshPromise;
  refreshPromise = (async () => {
    try {
      const session = getSession();
      const supabase = getSupabase();
      if (!session?.refreshToken || !supabase) return false;
      const { data, error } = await supabase.auth.refreshSession({
        refresh_token: session.refreshToken,
      });
      if (error || !data.session) return false;
      useAuthStore
        .getState()
        .updateTokens(
          data.session.access_token,
          data.session.refresh_token,
          data.session.expires_at ?? null,
        );
      return true;
    } catch {
      return false;
    } finally {
      setTimeout(() => {
        refreshPromise = null;
      }, 0);
    }
  })();
  return refreshPromise;
}

function buildUrl(path: string, query?: Query) {
  const url = `${getApiBaseUrl()}${path.startsWith('/') ? path : `/${path}`}`;
  if (!query) return url;
  const params = new URLSearchParams();
  Object.entries(query).forEach(([key, value]) => {
    if (value === undefined || value === null || value === '') return;
    params.append(key, String(value));
  });
  const qs = params.toString();
  return qs ? `${url}?${qs}` : url;
}

function extractMessage(payload: any, fallback: string): string {
  if (!payload) return fallback;
  if (typeof payload.message === 'string' && payload.message.trim()) {
    const fieldErrors = payload.errors?.fieldErrors;
    if (fieldErrors && typeof fieldErrors === 'object') {
      const first = Object.values(fieldErrors).flat()[0];
      if (typeof first === 'string') return `${payload.message}: ${first}`;
    }
    return payload.message;
  }
  if (typeof payload.error === 'string') return payload.error;
  return fallback;
}

export async function apiRequest<T = unknown>(path: string, options: RequestOptions = {}): Promise<T> {
  const { method = 'GET', body, query, auth = true, signal } = options;

  const doFetch = async () => {
    const headers: Record<string, string> = { Accept: 'application/json' };
    if (body !== undefined) headers['Content-Type'] = 'application/json';
    if (auth) {
      const token = getSession()?.accessToken;
      if (token) headers.Authorization = `Bearer ${token}`;
    }
    return fetch(buildUrl(path, query), {
      method,
      headers,
      body: body !== undefined ? JSON.stringify(body) : undefined,
      signal,
    });
  };

  let response: Response;
  try {
    response = await doFetch();
  } catch (error: any) {
    if (error?.name === 'AbortError') throw error;
    throw new ApiError(
      'Không kết nối được máy chủ. Hãy kiểm tra Backend đã chạy và địa chỉ API trong Cài đặt.',
      0,
    );
  }

  if (response.status === 401 && auth) {
    const refreshed = await refreshAccessToken();
    if (refreshed) {
      response = await doFetch();
    }
    if (response.status === 401) {
      useAuthStore.getState().logout();
      throw new ApiError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.', 401);
    }
  }

  const text = await response.text();
  let payload: any = null;
  if (text) {
    try {
      payload = JSON.parse(text);
    } catch {
      payload = { message: text };
    }
  }

  if (!response.ok) {
    throw new ApiError(
      extractMessage(payload, `Yêu cầu thất bại (mã ${response.status})`),
      response.status,
      payload,
    );
  }

  return (payload && 'data' in payload ? payload.data : payload) as T;
}

export const api = {
  get: <T>(path: string, query?: Query) => apiRequest<T>(path, { query }),
  post: <T>(path: string, body?: unknown) => apiRequest<T>(path, { method: 'POST', body: body ?? {} }),
  put: <T>(path: string, body?: unknown) => apiRequest<T>(path, { method: 'PUT', body: body ?? {} }),
  patch: <T>(path: string, body?: unknown) => apiRequest<T>(path, { method: 'PATCH', body: body ?? {} }),
  delete: <T>(path: string) => apiRequest<T>(path, { method: 'DELETE' }),
};

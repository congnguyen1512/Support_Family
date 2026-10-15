import { useMemo } from 'react';
import {
  QueryClient,
  useMutation,
  useQuery,
  useQueryClient,
  type QueryKey,
} from '@tanstack/react-query';
import {
  activityApi,
  appointmentApi,
  chatApi,
  healthApi,
  kidReminderApi,
  locationApi,
  notificationApi,
  profileApi,
  quickContactApi,
  relationshipApi,
  reminderApi,
  safeZoneApi,
} from './endpoints';
import type { FamilyMember, MemberKind, Relationship } from './types';
import { calcAge } from '../utils/format';
import { toast } from '../store/toast';
import { ApiError } from './client';
import { useAuthStore } from '../store/auth';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 20_000,
      gcTime: 10 * 60_000,
      retry: (count, error) => {
        if (error instanceof ApiError && [400, 401, 403, 404].includes(error.status)) return false;
        return count < 2;
      },
      refetchOnWindowFocus: true,
    },
    mutations: { retry: 0 },
  },
});

export const qk = {
  profile: ['profile'] as const,
  relationships: ['relationships'] as const,
  familyLocations: ['familyLocations'] as const,
  notifications: ['notifications'] as const,
  safeZones: ['safeZones'] as const,
  reminders: (memberUid?: string) => ['reminders', memberUid ?? 'all'] as const,
  kidReminders: (memberUid: string) => ['kidReminders', memberUid] as const,
  appointments: (memberUid?: string) => ['appointments', memberUid ?? 'all'] as const,
  activities: (memberUid?: string) => ['activities', memberUid ?? 'all'] as const,
  metrics: (memberUid?: string, date?: string) => ['metrics', memberUid ?? 'me', date ?? 'today'] as const,
  healthReport: (memberUid?: string, period?: string) => ['healthReport', memberUid ?? 'me', period ?? 'week'] as const,
  healthLogs: (memberUid?: string) => ['healthLogs', memberUid ?? 'me'] as const,
  threads: ['threads'] as const,
  messages: (peer: string) => ['messages', peer] as const,
  quickContact: ['quickContact'] as const,
  history: (uid: string, from: string, to: string) => ['history', uid, from, to] as const,
};

const useEnabled = () => Boolean(useAuthStore((s) => s.session?.accessToken));

/* ── Queries ───────────────────────────────────────────────── */
export const useRelationships = () =>
  useQuery({ queryKey: qk.relationships, queryFn: relationshipApi.list, enabled: useEnabled(), refetchInterval: 30_000 });

export const useFamilyLocations = () =>
  useQuery({ queryKey: qk.familyLocations, queryFn: locationApi.family, enabled: useEnabled(), refetchInterval: 15_000 });

export const useNotifications = () =>
  useQuery({ queryKey: qk.notifications, queryFn: notificationApi.list, enabled: useEnabled(), refetchInterval: 20_000 });

export const useSafeZones = () =>
  useQuery({ queryKey: qk.safeZones, queryFn: safeZoneApi.list, enabled: useEnabled() });

export const useReminders = (memberUid?: string) =>
  useQuery({ queryKey: qk.reminders(memberUid), queryFn: () => reminderApi.list(memberUid), enabled: useEnabled() });

export const useKidReminders = (memberUid?: string) =>
  useQuery({
    queryKey: qk.kidReminders(memberUid ?? ''),
    queryFn: () => kidReminderApi.list(memberUid!),
    enabled: useEnabled() && Boolean(memberUid),
  });

export const useAppointments = (memberUid?: string) =>
  useQuery({ queryKey: qk.appointments(memberUid), queryFn: () => appointmentApi.list(memberUid), enabled: useEnabled() });

export const useActivities = (memberUid?: string) =>
  useQuery({ queryKey: qk.activities(memberUid), queryFn: () => activityApi.list(memberUid), enabled: useEnabled() });

export const useMetrics = (memberUid?: string, date?: string) =>
  useQuery({
    queryKey: qk.metrics(memberUid, date),
    queryFn: () => activityApi.metrics(memberUid, date),
    enabled: useEnabled() && Boolean(memberUid),
  });

export const useHealthReport = (memberUid?: string, period: 'today' | 'week' | 'month' = 'week') =>
  useQuery({
    queryKey: qk.healthReport(memberUid, period),
    queryFn: () => healthApi.report(memberUid, period),
    enabled: useEnabled() && Boolean(memberUid),
  });

export const useHealthLogs = (memberUid?: string) =>
  useQuery({
    queryKey: qk.healthLogs(memberUid),
    queryFn: () => healthApi.logs(memberUid),
    enabled: useEnabled() && Boolean(memberUid),
  });

export const useThreads = () =>
  useQuery({ queryKey: qk.threads, queryFn: chatApi.threads, enabled: useEnabled(), refetchInterval: 10_000 });

export const useMessages = (peerUid?: string) =>
  useQuery({
    queryKey: qk.messages(peerUid ?? ''),
    queryFn: () => chatApi.messages(peerUid!),
    enabled: useEnabled() && Boolean(peerUid),
    refetchInterval: 3_500,
  });

export const useQuickContact = () =>
  useQuery({ queryKey: qk.quickContact, queryFn: quickContactApi.get, enabled: useEnabled() });

export const useProfile = () =>
  useQuery({ queryKey: qk.profile, queryFn: profileApi.get, enabled: useEnabled() });

export const useLocationHistory = (uid?: string, from?: string, to?: string) =>
  useQuery({
    queryKey: qk.history(uid ?? '', from ?? '', to ?? ''),
    queryFn: () => locationApi.history(uid!, from, to),
    enabled: useEnabled() && Boolean(uid && from && to),
  });

/* ── Thành viên gộp ────────────────────────────────────────── */
function classify(age: number | null, role?: string | null): MemberKind {
  if (role === 'nguoiduocchamsoc') {
    if (age !== null && age < 16) return 'child';
    if (age !== null && age >= 60) return 'senior';
  }
  if (age !== null && age < 16) return 'child';
  if (age !== null && age >= 60) return 'senior';
  return 'adult';
}

/**
 * Danh sách thành viên đã xác nhận, gộp hồ sơ (relationships) và vị trí (locations/family).
 * Đây là nguồn dữ liệu trung tâm cho dashboard, bản đồ, bộ chọn thành viên...
 */
export function useFamilyMembers() {
  const relationships = useRelationships();
  const locations = useFamilyLocations();

  const members = useMemo<FamilyMember[]>(() => {
    const rels = (relationships.data ?? []).filter((r) => r.processing === 'xacnhan' && r.relation_user);
    const locMap = new Map((locations.data ?? []).map((l) => [l.uid, l]));
    const seen = new Set<string>();
    const list: FamilyMember[] = [];
    for (const r of rels) {
      const u = r.relation_user!;
      if (seen.has(u.uid)) continue;
      seen.add(u.uid);
      const age = calcAge(u.birthday);
      list.push({
        uid: u.uid,
        relationshipId: r.id,
        name: u.name?.trim() || u.email || u.phone || 'Thành viên',
        relation: r.relation_type?.trim() || 'Người thân',
        reverseRelation: r.reverse_relation_type?.trim() || 'Người thân',
        avatar: u.avata,
        phone: u.phone,
        email: u.email,
        birthday: u.birthday,
        sex: u.sex,
        address: u.address,
        role: u.role,
        age,
        kind: classify(age, u.role),
        location: locMap.get(u.uid) ?? null,
      });
    }
    return list.sort((a, b) => a.name.localeCompare(b.name, 'vi'));
  }, [relationships.data, locations.data]);

  const pending = useMemo<Relationship[]>(
    () => (relationships.data ?? []).filter((r) => r.processing === 'chuachapnhan'),
    [relationships.data],
  );

  return {
    members,
    pending,
    isLoading: relationships.isLoading,
    isFetching: relationships.isFetching || locations.isFetching,
    error: relationships.error,
    refetch: () => {
      relationships.refetch();
      locations.refetch();
    },
  };
}

/* ── Mutation tiện dụng với toast + invalidate ─────────────── */
interface MutationOptions<TVars, TData> {
  invalidate?: (QueryKey | ((vars: TVars) => QueryKey))[];
  success?: string | ((data: TData, vars: TVars) => string | null);
  errorTitle?: string;
  onSuccess?: (data: TData, vars: TVars) => void;
}

export function useApiMutation<TVars = void, TData = unknown>(
  fn: (vars: TVars) => Promise<TData>,
  options: MutationOptions<TVars, TData> = {},
) {
  const client = useQueryClient();
  return useMutation<TData, Error, TVars>({
    mutationFn: fn,
    onSuccess: (data, vars) => {
      (options.invalidate ?? []).forEach((key) => {
        const resolved = typeof key === 'function' ? key(vars) : key;
        client.invalidateQueries({ queryKey: resolved });
      });
      const message = typeof options.success === 'function' ? options.success(data, vars) : options.success;
      if (message) toast.success(message);
      options.onSuccess?.(data, vars);
    },
    onError: (error) => {
      toast.error(options.errorTitle ?? 'Thao tác thất bại', error.message);
    },
  });
}

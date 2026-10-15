import React, { useMemo, useState } from 'react';
import { Pressable, View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { transition, web, type WebPressState } from '../../theme/web';
import { Badge, Button, Card, EmptyState, Icon, Modal, SearchInput, Segmented, SkeletonList, Switch, T } from '../../components/ui';
import { Page } from '../../components/layout/Page';
import { LazyFamilyMap } from '../../components/map/LazyMap';
import { notificationApi } from '../../api/endpoints';
import { qk, useApiMutation, useNotifications } from '../../api/hooks';
import { useUiStore } from '../../store/ui';
import { formatDateLong, formatDateTime, formatTime, normalizeSearch, relativeTime, toISODate } from '../../utils/format';
import { NOTIFICATION_META, classifyNotification, prettifyNotificationText, type NotificationKind } from '../../utils/constants';
import type { AppNotification } from '../../api/types';

type Filter = 'all' | NotificationKind | 'safezone';

export default function NotificationsScreen() {
  const c = useTheme();
  const { data, isLoading, refetch, isFetching } = useNotifications();
  const seen = useUiStore((s) => s.seenNotificationIds);
  const markSeen = useUiStore((s) => s.markNotificationsSeen);
  const acknowledge = useUiStore((s) => s.acknowledgeAlert);
  const [filter, setFilter] = useState<Filter>('all');
  const [unreadOnly, setUnreadOnly] = useState(false);
  const [query, setQuery] = useState('');
  const [mapFor, setMapFor] = useState<AppNotification | null>(null);

  const respond = useApiMutation((p: { id: number; action: 'xacnhan' | 'huy' }) => notificationApi.respond(p.id, p.action), {
    invalidate: [qk.notifications, qk.relationships, qk.familyLocations],
    success: (_, p) => (p.action === 'xacnhan' ? 'Đã chấp nhận lời mời — thành viên mới đã được thêm' : 'Đã từ chối lời mời'),
    onSuccess: (_, p) => markSeen([p.id]),
  });

  const seenSet = useMemo(() => new Set(seen), [seen]);
  const all = data ?? [];
  const kinds = useMemo(() => new Map(all.map((n) => [n.id, classifyNotification(n)])), [all]);
  const count = (k: Filter) =>
    all.filter((n) => {
      const kind = kinds.get(n.id)!;
      return k === 'all' || kind === k || (k === 'safezone' && (kind === 'safezone_in' || kind === 'safezone_out'));
    }).length;

  const groups = useMemo(() => {
    const q = normalizeSearch(query);
    const filtered = all.filter((n) => {
      const kind = kinds.get(n.id)!;
      if (filter !== 'all' && !(kind === filter || (filter === 'safezone' && (kind === 'safezone_in' || kind === 'safezone_out')))) return false;
      if (unreadOnly && seenSet.has(n.id)) return false;
      if (q && !normalizeSearch(`${prettifyNotificationText(n.title)} ${prettifyNotificationText(n.content)} ${n.sender_name ?? ''}`).includes(q)) return false;
      return true;
    });
    const map = new Map<string, AppNotification[]>();
    filtered.forEach((n) => {
      const key = toISODate(new Date(n.created_at));
      map.set(key, [...(map.get(key) ?? []), n]);
    });
    return Array.from(map.entries());
  }, [all, kinds, filter, unreadOnly, query, seenSet]);

  const unread = all.filter((n) => !seenSet.has(n.id)).length;
  const today = toISODate();
  const yesterday = toISODate(new Date(Date.now() - 86400000));

  return (
    <Page
      title="Thông báo"
      subtitle={unread ? `${unread} thông báo chưa đọc` : 'Bạn đã xem hết thông báo'}
      onRefresh={refetch}
      refreshing={isFetching && !isLoading}
      actions={
        <>
          <Button nativeID="notifications-refresh" label="Làm mới" icon="refresh" variant="secondary" onPress={refetch} />
          <Button nativeID="notifications-mark-all" label="Đánh dấu tất cả đã đọc" icon="checkmark-done" disabled={!unread} onPress={() => markSeen(all.map((n) => n.id))} />
        </>
      }
      maxWidth={1100}
    >
      <Card padding={14} anim="rise" style={{ gap: 12 }}>
        <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap', alignItems: 'center' }}>
          <SearchInput nativeID="notifications-search" value={query} onChangeText={setQuery} placeholder="Tìm thông báo..." style={{ flex: 1, minWidth: 220 }} />
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Switch value={unreadOnly} onChange={setUnreadOnly} label="Chỉ chưa đọc" />
            <T variant="small" color="textSoft">
              Chỉ chưa đọc
            </T>
          </View>
        </View>
        <Segmented<Filter>
          size="sm"
          value={filter}
          onChange={setFilter}
          options={[
            { value: 'all', label: 'Tất cả', count: count('all') },
            { value: 'fall', label: 'Té ngã', icon: 'warning-outline', count: count('fall') },
            { value: 'safezone', label: 'Vùng an toàn', icon: 'shield-outline', count: count('safezone') },
            { value: 'invite', label: 'Lời mời', icon: 'person-add-outline', count: count('invite') },
            { value: 'relationship', label: 'Gia đình', icon: 'people-outline', count: count('relationship') },
            { value: 'other', label: 'Khác', count: count('other') },
          ]}
        />
      </Card>

      {isLoading ? (
        <SkeletonList rows={6} height={84} />
      ) : groups.length === 0 ? (
        <Card>
          <EmptyState icon="notifications-off-outline" title="Không có thông báo" description="Cảnh báo té ngã, ra/vào vùng an toàn và lời mời sẽ xuất hiện tại đây theo thời gian thực." />
        </Card>
      ) : (
        groups.map(([date, items], gi) => (
          <View key={date} style={{ gap: 10 }} dataSet={{ anim: 'rise', delay: String(Math.min(6, gi + 1)) }}>
            <T variant="label" color="textMuted" style={{ textTransform: 'uppercase' }}>
              {date === today ? 'Hôm nay' : date === yesterday ? 'Hôm qua' : formatDateLong(date)}
            </T>
            <Card padding={0} style={{ overflow: 'hidden' }}>
              {items.map((n, i) => {
                const kind = kinds.get(n.id)!;
                const meta = NOTIFICATION_META[kind];
                const isUnread = !seenSet.has(n.id);
                const isInvitePending = kind === 'invite' && n.processing === 'dagui';
                const hasPoint = n.fall_latitude != null && n.fall_longitude != null;
                return (
                  <Pressable
                    key={n.id}
                    nativeID={`notification-${n.id}`}
                    onPress={() => markSeen([n.id])}
                    style={(state) => {
                      const { hovered } = state as WebPressState;
                      return [
                        { flexDirection: 'row', gap: 14, padding: 16, borderTopWidth: i ? 1 : 0, borderTopColor: c.border },
                        { backgroundColor: kind === 'fall' && isUnread ? c.dangerSoft : hovered ? c.surfaceHover : isUnread ? c.primarySoft : 'transparent' },
                        transition('background-color', 120),
                        web({ cursor: 'pointer' }),
                      ];
                    }}
                  >
                    <View style={{ width: 44, height: 44, borderRadius: 14, alignItems: 'center', justifyContent: 'center', backgroundColor: c[meta.soft] as string }}>
                      <Icon name={meta.icon} size={21} color={meta.color} />
                    </View>
                    <View style={{ flex: 1, minWidth: 0, gap: 3 }}>
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, flexWrap: 'wrap' }}>
                        <T variant="bodyStrong" style={{ flexShrink: 1 }}>
                          {prettifyNotificationText(n.title)}
                        </T>
                        <Badge label={meta.label} color={meta.color} size="sm" />
                        {isUnread ? <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: c.primary }} /> : null}
                      </View>
                      <T variant="body" color="textSoft">
                        {prettifyNotificationText(n.content)}
                      </T>
                      <T variant="caption" color="textMuted">
                        {formatTime(n.created_at)} · {relativeTime(n.created_at)}
                        {n.sender_name ? ` · ${n.sender_name}${n.sender_relation ? ` (${n.sender_relation})` : ''}` : ''}
                      </T>
                      {isInvitePending || (kind === 'fall' && hasPoint) ? (
                        <View style={{ flexDirection: 'row', gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
                          {isInvitePending ? (
                            <>
                              <Button nativeID={`invite-accept-${n.id}`} label="Chấp nhận" icon="checkmark" size="sm" loading={respond.isPending && respond.variables?.id === n.id && respond.variables?.action === 'xacnhan'} onPress={() => respond.mutate({ id: n.id, action: 'xacnhan' })} />
                              <Button nativeID={`invite-decline-${n.id}`} label="Từ chối" icon="close" size="sm" variant="secondary" onPress={() => respond.mutate({ id: n.id, action: 'huy' })} />
                            </>
                          ) : null}
                          {kind === 'fall' && hasPoint ? (
                            <>
                              <Button label="Xem vị trí té ngã" icon="map" size="sm" variant="danger" onPress={() => { markSeen([n.id]); acknowledge(n.id); setMapFor(n); }} />
                              <Button label="Chỉ đường" icon="navigate-outline" size="sm" variant="secondary" onPress={() => window.open(`https://www.google.com/maps/dir/?api=1&destination=${n.fall_latitude},${n.fall_longitude}`, '_blank')} />
                            </>
                          ) : null}
                        </View>
                      ) : null}
                    </View>
                  </Pressable>
                );
              })}
            </Card>
          </View>
        ))
      )}

      <Modal visible={Boolean(mapFor)} onClose={() => setMapFor(null)} title="Vị trí té ngã" subtitle={mapFor ? formatDateTime(mapFor.created_at) : undefined} icon="warning" width={760}>
        {mapFor ? (
          <View style={{ height: 420, borderRadius: 16, overflow: 'hidden' }}>
            <LazyFamilyMap alerts={[{ id: mapFor.id, lat: mapFor.fall_latitude!, lng: mapFor.fall_longitude!, label: mapFor.sender_name ?? 'Té ngã' }]} fitKey={`n-${mapFor.id}`} />
          </View>
        ) : null}
      </Modal>
    </Page>
  );
}

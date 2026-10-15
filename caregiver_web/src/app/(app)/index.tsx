import React, { useMemo, useState } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { transition, web, type WebPressState } from '../../theme/web';
import { Avatar, Badge, Button, Card, CardHeader, EmptyState, HeroGradient, Icon, IconButton, SkeletonList, StatCard, StatusDot, T } from '../../components/ui';
import { Col, Grid, Page } from '../../components/layout/Page';
import { LazyFamilyMap } from '../../components/map/LazyMap';
import { presenceColor, presenceLabel } from '../../components/map/presence';
import { QUICK_ACTIONS } from '../../components/layout/Topbar';
import { useAppointments, useFamilyMembers, useNotifications, useReminders, useSafeZones } from '../../api/hooks';
import { useAuthStore } from '../../store/auth';
import { useBreakpoint, useNow } from '../../hooks/common';
import { daysUntil, formatDate, formatDateLong, greeting, relativeTime, shortTime } from '../../utils/format';
import {
  APPOINTMENT_STATUS_META,
  MEMBER_KIND_META,
  NOTIFICATION_META,
  REMINDER_CATEGORY_META,
  classifyNotification,
  prettifyNotificationText,
} from '../../utils/constants';
import { slotState, todaysReminders } from '../../utils/schedule';
import type { FamilyMember } from '../../api/types';

function MemberRow({ m, onPress, selected }: { m: FamilyMember; onPress: () => void; selected?: boolean }) {
  const c = useTheme();
  const status = presenceColor(m.location?.updated_at);
  const kind = MEMBER_KIND_META[m.kind];
  const place = m.location?.place_name || m.location?.address || m.location?.district || null;
  return (
    <Pressable
      nativeID={`dash-member-${m.uid}`}
      onPress={onPress}
      style={(state) => {
        const { hovered } = state as WebPressState;
        return [
          styles.memberRow,
          { backgroundColor: selected ? c.primarySoft : hovered ? c.surfaceHover : 'transparent', borderColor: selected ? c.primary : 'transparent' },
          transition('background-color, border-color', 140),
          web({ cursor: 'pointer' }),
        ];
      }}
    >
      <Avatar name={m.name} uri={m.avatar} size={42} status={status} />
      <View style={{ flex: 1, minWidth: 0 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
          <T variant="bodyStrong" numberOfLines={1} style={{ flexShrink: 1 }}>
            {m.name}
          </T>
          <Badge label={m.relation} color={kind.color} size="sm" />
        </View>
        <T variant="caption" color="textMuted" numberOfLines={1}>
          {place ?? presenceLabel(m.location?.updated_at)}
        </T>
      </View>
      <View style={{ alignItems: 'flex-end', gap: 2 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
          <StatusDot color={status} size={7} pulse={status === '#12B76A'} />
          <T variant="caption" color="textMuted">
            {m.location?.updated_at ? relativeTime(m.location.updated_at) : '—'}
          </T>
        </View>
        {m.location?.speed != null && m.location.speed > 0.8 ? (
          <T variant="caption" color="info">
            {(m.location.speed * 3.6).toFixed(0)} km/h
          </T>
        ) : null}
      </View>
    </Pressable>
  );
}

export default function Dashboard() {
  const c = useTheme();
  const router = useRouter();
  const now = useNow(60_000);
  const { isMobile } = useBreakpoint();
  const profile = useAuthStore((s) => s.session?.profile);
  const { members, isLoading, refetch, isFetching } = useFamilyMembers();
  const notifications = useNotifications();
  const reminders = useReminders();
  const appointments = useAppointments();
  const zones = useSafeZones();
  const [selected, setSelected] = useState<string | null>(null);

  const online = members.filter((m) => presenceColor(m.location?.updated_at) === '#12B76A').length;
  const today = useMemo(() => todaysReminders(reminders.data, now), [reminders.data, now]);
  const remaining = today.filter((r) => slotState(r.reminder_time, now) !== 'done').length;

  const upcoming = useMemo(
    () =>
      (appointments.data ?? [])
        .filter((a) => a.status === 'upcoming' && (daysUntil(a.appointment_date) ?? -1) >= 0)
        .sort((a, b) => `${a.appointment_date} ${a.appointment_time}`.localeCompare(`${b.appointment_date} ${b.appointment_time}`)),
    [appointments.data],
  );
  const weekAppointments = upcoming.filter((a) => (daysUntil(a.appointment_date) ?? 99) <= 7).length;

  const recent = (notifications.data ?? []).slice(0, 6);
  const alerts24h = (notifications.data ?? []).filter((n) => {
    const k = classifyNotification(n);
    return (k === 'fall' || k === 'safezone_out') && Date.now() - new Date(n.created_at).getTime() < 86400000;
  }).length;

  const memberName = (uid: string) => members.find((m) => m.uid === uid)?.name ?? 'Thành viên';
  const selectedMember = members.find((m) => m.uid === selected);

  return (
    <Page onRefresh={refetch} refreshing={isFetching && !isLoading}>
      <HeroGradient>
        <View style={[styles.heroRow, isMobile ? { flexDirection: 'column', alignItems: 'flex-start' } : null]}>
          <View style={{ flex: 1, gap: 6 }}>
            <T variant="small" style={{ color: 'rgba(255,255,255,0.8)', textTransform: 'capitalize' }}>
              {formatDateLong(now)}
            </T>
            <T variant="hero" style={{ color: '#fff' }}>
              {greeting(now)}, {profile?.name?.split(' ').slice(-1)[0] || 'bạn'} 👋
            </T>
            <T variant="body" style={{ color: 'rgba(255,255,255,0.85)', maxWidth: 560 }}>
              {members.length === 0
                ? 'Hãy mời người thân để bắt đầu theo dõi và chăm sóc gia đình.'
                : `${online}/${members.length} thành viên đang hoạt động · ${remaining} nhắc nhở còn lại hôm nay${alerts24h ? ` · ${alerts24h} cảnh báo trong 24 giờ` : ''}.`}
            </T>
          </View>
          <View style={styles.quickRow}>
            {QUICK_ACTIONS.slice(0, 4).map((a) => (
              <Pressable
                key={a.key}
                nativeID={`dash-quick-${a.key}`}
                onPress={() => router.push(a.href as any)}
                style={(state) => {
                  const { hovered } = state as WebPressState;
                  return [
                    styles.quick,
                    { backgroundColor: hovered ? 'rgba(255,255,255,0.26)' : 'rgba(255,255,255,0.14)' },
                    transition('background-color, transform', 150),
                    web({ cursor: 'pointer', backdropFilter: 'blur(8px)', transform: hovered ? 'translateY(-2px)' : 'none' }),
                  ];
                }}
              >
                <Icon name={a.icon} size={20} color="#fff" />
                <T variant="small" style={{ color: '#fff', fontWeight: '600' }} numberOfLines={1}>
                  {a.label}
                </T>
              </Pressable>
            ))}
          </View>
        </View>
      </HeroGradient>

      <Grid gap={16}>
        <StatCard delay={1} label="Thành viên đang hoạt động" value={`${online}/${members.length}`} icon="people" tone="primary" hint="Cập nhật vị trí trong 10 phút" onPress={() => router.push('/members')} />
        <StatCard delay={2} label="Nhắc nhở còn lại hôm nay" value={remaining} icon="alarm" tone="pink" hint={`Tổng ${today.length} nhắc nhở hôm nay`} onPress={() => router.push('/reminders')} />
        <StatCard delay={3} label="Lịch khám 7 ngày tới" value={weekAppointments} icon="medkit" tone="info" hint={upcoming[0] ? `Gần nhất: ${formatDate(upcoming[0].appointment_date)}` : 'Chưa có lịch hẹn'} onPress={() => router.push('/appointments')} />
        <StatCard delay={4} label="Cảnh báo 24 giờ qua" value={alerts24h} icon="warning" tone={alerts24h ? 'danger' : 'success'} hint={`${zones.data?.filter((z) => z.is_active).length ?? 0} vùng an toàn đang bật`} onPress={() => router.push('/notifications')} />
      </Grid>

      <Grid>
        <Col flex={2} minWidth={480}>
          <Card padding={0} anim="rise" delay={2} style={{ overflow: 'hidden' }}>
            <View style={{ padding: 18, paddingBottom: 0 }}>
              <CardHeader
                title="Bản đồ trực tiếp"
                subtitle={selectedMember ? `Đang xem: ${selectedMember.name}` : 'Vị trí mới nhất của cả gia đình'}
                icon="map"
                right={
                  <View style={{ flexDirection: 'row', gap: 6 }}>
                    <IconButton icon="refresh" label="Làm mới" variant="secondary" onPress={refetch} />
                    <Button nativeID="dash-open-map" label="Mở rộng" icon="expand-outline" size="sm" variant="soft" onPress={() => router.push((selected ? `/map?uid=${selected}` : '/map') as any)} />
                  </View>
                }
              />
            </View>
            <View style={{ height: 420 }}>
              <LazyFamilyMap
                members={members}
                safeZones={(zones.data ?? []).filter((z) => z.is_active)}
                selectedUid={selected}
                onSelectMember={setSelected}
                focus={selectedMember?.location?.latitude != null ? [selectedMember.location.latitude, selectedMember.location.longitude!] : null}
                scrollWheelZoom={false}
              />
            </View>
          </Card>
        </Col>
        <Col minWidth={320}>
          <Card anim="rise" delay={3} style={{ flex: 1 }}>
            <CardHeader
              title="Trạng thái thành viên"
              subtitle={`${members.length} người thân`}
              icon="people"
              iconColor="accent"
              right={<IconButton icon="person-add-outline" label="Mời thành viên" variant="soft" onPress={() => router.push('/members?invite=1' as any)} />}
            />
            {isLoading ? (
              <SkeletonList rows={4} />
            ) : members.length === 0 ? (
              <EmptyState compact icon="people-outline" title="Chưa có thành viên" description="Mời người thân để bắt đầu." action={<Button label="Mời ngay" icon="person-add" size="sm" onPress={() => router.push('/members?invite=1' as any)} />} />
            ) : (
              <View style={{ gap: 4 }}>
                {members.map((m) => (
                  <MemberRow key={m.uid} m={m} selected={m.uid === selected} onPress={() => setSelected(m.uid === selected ? null : m.uid)} />
                ))}
              </View>
            )}
          </Card>
        </Col>
      </Grid>

      <Grid>
        <Col minWidth={340}>
          <Card anim="rise" delay={4} style={{ flex: 1 }}>
            <CardHeader
              title="Lịch nhắc hôm nay"
              subtitle={`${today.length - remaining}/${today.length} đã qua`}
              icon="alarm"
              iconColor="pink"
              right={<IconButton icon="add" label="Tạo nhắc nhở" variant="soft" onPress={() => router.push('/reminders?new=1' as any)} />}
            />
            {reminders.isLoading ? (
              <SkeletonList rows={4} height={48} />
            ) : today.length === 0 ? (
              <EmptyState compact icon="alarm-outline" title="Không có nhắc nhở hôm nay" />
            ) : (
              <View>
                {today.slice(0, 8).map((r, i) => {
                  const st = slotState(r.reminder_time, now);
                  const meta = REMINDER_CATEGORY_META[r.category] ?? REMINDER_CATEGORY_META.other;
                  const tint = c[meta.color] as string;
                  return (
                    <View key={r.id} style={styles.timelineRow}>
                      <View style={{ width: 48 }}>
                        <T variant="bodyStrong" color={st === 'done' ? 'textMuted' : 'text'} style={st === 'done' ? { textDecorationLine: 'line-through' } : undefined}>
                          {shortTime(r.reminder_time)}
                        </T>
                      </View>
                      <View style={{ alignItems: 'center', alignSelf: 'stretch' }}>
                        <View style={[styles.tlDot, { backgroundColor: st === 'done' ? c.borderStrong : tint, borderColor: c.surface }]} />
                        {i < Math.min(today.length, 8) - 1 ? <View style={[styles.tlLine, { backgroundColor: c.border }]} /> : null}
                      </View>
                      <View style={{ flex: 1, paddingBottom: 14, opacity: st === 'done' ? 0.55 : 1 }}>
                        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                          <Icon name={meta.icon} size={14} color={tint} />
                          <T variant="bodyStrong" numberOfLines={1} style={{ flexShrink: 1 }}>
                            {r.title}
                          </T>
                          {st === 'now' ? <Badge label="Sắp đến giờ" color="warning" size="sm" dot /> : null}
                        </View>
                        <T variant="caption" color="textMuted" numberOfLines={1}>
                          {r.member_user?.name ?? memberName(r.member_uid)}
                          {r.subtitle ? ` · ${r.subtitle}` : ''}
                        </T>
                      </View>
                    </View>
                  );
                })}
                {today.length > 8 ? <Button label={`Xem tất cả ${today.length} nhắc nhở`} variant="ghost" size="sm" onPress={() => router.push('/reminders')} /> : null}
              </View>
            )}
          </Card>
        </Col>

        <Col minWidth={320}>
          <Card anim="rise" delay={5} style={{ flex: 1 }}>
            <CardHeader
              title="Lịch khám sắp tới"
              icon="medkit"
              iconColor="info"
              right={<IconButton icon="add" label="Đặt lịch khám" variant="soft" onPress={() => router.push('/appointments?new=1' as any)} />}
            />
            {appointments.isLoading ? (
              <SkeletonList rows={3} height={64} />
            ) : upcoming.length === 0 ? (
              <EmptyState compact icon="calendar-outline" title="Không có lịch khám sắp tới" />
            ) : (
              <View style={{ gap: 10 }}>
                {upcoming.slice(0, 4).map((a) => {
                  const d = daysUntil(a.appointment_date) ?? 0;
                  const date = new Date(`${a.appointment_date}T00:00:00`);
                  return (
                    <Pressable key={a.id} onPress={() => router.push('/appointments')} style={[styles.apptRow, { borderColor: c.border }, web({ cursor: 'pointer' })]}>
                      <View style={[styles.dateBox, { backgroundColor: d === 0 ? c.danger : c.infoSoft }]}>
                        <T variant="caption" style={{ color: d === 0 ? '#fff' : c.info, fontWeight: '700' }}>
                          TH {date.getMonth() + 1}
                        </T>
                        <T variant="h2" style={{ color: d === 0 ? '#fff' : c.info, lineHeight: 22 }}>
                          {date.getDate()}
                        </T>
                      </View>
                      <View style={{ flex: 1, minWidth: 0 }}>
                        <T variant="bodyStrong" numberOfLines={1}>
                          {a.clinic}
                        </T>
                        <T variant="caption" color="textMuted" numberOfLines={1}>
                          {a.doctor ? `BS. ${a.doctor} · ` : ''}
                          {shortTime(a.appointment_time)} · {a.member_user?.name ?? memberName(a.member_uid)}
                        </T>
                      </View>
                      <Badge label={d === 0 ? 'Hôm nay' : d === 1 ? 'Ngày mai' : `${d} ngày`} color={d <= 1 ? 'danger' : APPOINTMENT_STATUS_META.upcoming.color} size="sm" />
                    </Pressable>
                  );
                })}
              </View>
            )}
          </Card>
        </Col>

        <Col minWidth={320}>
          <Card anim="rise" delay={6} style={{ flex: 1 }}>
            <CardHeader
              title="Hoạt động gần đây"
              icon="notifications"
              iconColor="warning"
              right={<Button label="Tất cả" size="sm" variant="ghost" iconRight="chevron-forward" onPress={() => router.push('/notifications')} />}
            />
            {notifications.isLoading ? (
              <SkeletonList rows={4} height={52} />
            ) : recent.length === 0 ? (
              <EmptyState compact icon="notifications-off-outline" title="Chưa có thông báo" />
            ) : (
              <View style={{ gap: 12 }}>
                {recent.map((n) => {
                  const kind = classifyNotification(n);
                  const meta = NOTIFICATION_META[kind];
                  return (
                    <View key={n.id} style={{ flexDirection: 'row', gap: 12, alignItems: 'flex-start' }}>
                      <View style={[styles.notiIcon, { backgroundColor: c[meta.soft] as string }]}>
                        <Icon name={meta.icon} size={16} color={meta.color} />
                      </View>
                      <View style={{ flex: 1, minWidth: 0 }}>
                        <T variant="bodyStrong" numberOfLines={1}>
                          {prettifyNotificationText(n.title)}
                        </T>
                        <T variant="caption" color="textMuted" numberOfLines={2}>
                          {prettifyNotificationText(n.content)}
                        </T>
                      </View>
                      <T variant="caption" color="textMuted">
                        {relativeTime(n.created_at)}
                      </T>
                    </View>
                  );
                })}
              </View>
            )}
          </Card>
        </Col>
      </Grid>
    </Page>
  );
}

const styles = StyleSheet.create({
  heroRow: { flexDirection: 'row', alignItems: 'center', gap: 24 },
  quickRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, maxWidth: 460 },
  quick: { width: 104, height: 92, borderRadius: 18, padding: 12, justifyContent: 'space-between', borderWidth: 1, borderColor: 'rgba(255,255,255,0.2)' },
  memberRow: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 8, borderRadius: 14, borderWidth: 1 },
  timelineRow: { flexDirection: 'row', gap: 12 },
  tlDot: { width: 12, height: 12, borderRadius: 6, borderWidth: 2, marginTop: 4 },
  tlLine: { width: 2, flex: 1, marginTop: 2 },
  apptRow: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 10, borderRadius: 14, borderWidth: 1 },
  dateBox: { width: 50, height: 54, borderRadius: 13, alignItems: 'center', justifyContent: 'center' },
  notiIcon: { width: 34, height: 34, borderRadius: 11, alignItems: 'center', justifyContent: 'center' },
});

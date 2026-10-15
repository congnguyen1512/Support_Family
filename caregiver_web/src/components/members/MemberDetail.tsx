import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { gradient } from '../../theme/web';
import { Avatar, Badge, Button, EmptyState, Field, Icon, Modal, Segmented, SelectField, SkeletonList, T, TextField } from '../ui';
import { confirm } from '../ui/Overlay';
import { LazyFamilyMap } from '../map/LazyMap';
import { presenceColor, presenceLabel } from '../map/presence';
import { KidReminders } from './KidReminders';
import { relationshipApi } from '../../api/endpoints';
import { qk, useApiMutation, useAppointments, useReminders } from '../../api/hooks';
import { formatDate, relativeTime, shortTime } from '../../utils/format';
import { MEMBER_KIND_META, RELATION_OPTIONS, REMINDER_CATEGORY_META, SCHEDULE_LABEL, resolveReverseRelation, weekdaysLabel } from '../../utils/constants';
import type { FamilyMember } from '../../api/types';

type Tab = 'overview' | 'care' | 'kid' | 'location';

export function MemberDetail({ member, onClose }: { member: FamilyMember | null; onClose: () => void }) {
  const c = useTheme();
  const router = useRouter();
  const [tab, setTab] = useState<Tab>('overview');
  const [editRel, setEditRel] = useState(false);
  const [relation, setRelation] = useState('');
  const [reverse, setReverse] = useState('');
  const reminders = useReminders(member?.uid);
  const appointments = useAppointments(member?.uid);

  useEffect(() => {
    setTab('overview');
    setEditRel(false);
    if (member) {
      setRelation(member.relation);
      setReverse(member.reverseRelation);
    }
  }, [member?.uid]);

  const update = useApiMutation((p: { id: number; relation_type: string; reverse_relation_type: string }) => relationshipApi.update(p.id, p), {
    invalidate: [qk.relationships],
    success: 'Đã cập nhật quan hệ',
    onSuccess: () => setEditRel(false),
  });
  const remove = useApiMutation((id: number) => relationshipApi.remove(id), {
    invalidate: [qk.relationships, qk.familyLocations],
    success: 'Đã xóa thành viên khỏi gia đình',
    onSuccess: onClose,
  });

  if (!member) return null;
  const kind = MEMBER_KIND_META[member.kind];
  const loc = member.location;
  const go = (href: string) => {
    onClose();
    router.push(href as any);
  };

  const tabs: { value: Tab; label: string; icon: string }[] = [
    { value: 'overview', label: 'Hồ sơ', icon: 'person-outline' },
    { value: 'care', label: 'Chăm sóc', icon: 'heart-outline' },
    ...(member.kind === 'child' ? [{ value: 'kid' as Tab, label: 'Nhắc việc', icon: 'happy-outline' }] : []),
    { value: 'location', label: 'Vị trí', icon: 'location-outline' },
  ];

  const upcoming = (appointments.data ?? []).filter((a) => a.status === 'upcoming').sort((a, b) => a.appointment_date.localeCompare(b.appointment_date));

  return (
    <Modal visible onClose={onClose} side width={560}>
      <View style={{ marginHorizontal: -24, marginTop: -24, padding: 24, paddingTop: 28, gap: 14, ...gradient(c.mode === 'dark' ? '#0E3A40' : '#00ACB2', c.mode === 'dark' ? '#1B2B5A' : '#4F7CFF', 120) }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 14 }}>
          <Avatar name={member.name} uri={member.avatar} size={68} ring="rgba(255,255,255,0.6)" status={presenceColor(loc?.updated_at)} />
          <View style={{ flex: 1 }}>
            <T variant="h1" style={{ color: '#fff' }} numberOfLines={1}>
              {member.name}
            </T>
            <T variant="small" style={{ color: 'rgba(255,255,255,0.85)' }}>
              {member.relation} của bạn · {kind.label}
              {member.age != null ? ` · ${member.age} tuổi` : ''}
            </T>
            <T variant="caption" style={{ color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>
              {presenceLabel(loc?.updated_at)}
              {loc?.updated_at ? ` · ${relativeTime(loc.updated_at)}` : ''}
            </T>
          </View>
          <Button label="" icon="close" variant="ghost" onPress={onClose} style={{ backgroundColor: 'rgba(255,255,255,0.15)' }} />
        </View>
        <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
          <Button nativeID="member-message" label="Nhắn tin" icon="chatbubble-ellipses" size="sm" variant="secondary" onPress={() => go(`/messages?peer=${member.uid}`)} />
          <Button nativeID="member-map" label="Bản đồ" icon="map" size="sm" variant="secondary" onPress={() => go(`/map?uid=${member.uid}`)} />
          {member.phone ? <Button nativeID="member-call" label="Gọi" icon="call" size="sm" variant="secondary" onPress={() => window.open(`tel:${member.phone}`)} /> : null}
        </View>
      </View>

      <Segmented<Tab> value={tab} onChange={setTab} options={tabs} />

      {tab === 'overview' ? (
        <View style={{ gap: 14 }} dataSet={{ anim: 'fade' }}>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10 }}>
            <InfoTile icon="call-outline" label="Điện thoại" value={member.phone || '—'} />
            <InfoTile icon="mail-outline" label="Email" value={member.email || '—'} />
            <InfoTile icon="calendar-outline" label="Ngày sinh" value={member.birthday ? `${formatDate(member.birthday)}${member.age != null ? ` (${member.age} tuổi)` : ''}` : '—'} />
            <InfoTile icon="male-female-outline" label="Giới tính" value={member.sex || '—'} />
            <InfoTile icon="home-outline" label="Địa chỉ" value={member.address || '—'} wide />
          </View>

          <View style={{ padding: 14, borderRadius: 16, borderWidth: 1, borderColor: c.border, gap: 12 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <T variant="h3" style={{ flex: 1 }}>
                Quan hệ gia đình
              </T>
              {!editRel ? <Button nativeID="member-edit-relation" label="Sửa" icon="create-outline" size="sm" variant="ghost" onPress={() => setEditRel(true)} /> : null}
            </View>
            {editRel ? (
              <>
                <Field label={`${member.name} là gì của bạn?`}>
                  <SelectField
                    id="member-relation"
                    value={RELATION_OPTIONS.includes(relation) ? relation : ''}
                    placeholder={relation || 'Chọn quan hệ'}
                    options={RELATION_OPTIONS.map((r) => ({ value: r, label: r }))}
                    onChange={(v) => {
                      setRelation(v);
                      setReverse(resolveReverseRelation(v));
                    }}
                  />
                </Field>
                <Field label={`Bạn là gì của ${member.name}?`}>
                  <TextField value={reverse} onChangeText={setReverse} />
                </Field>
                <View style={{ flexDirection: 'row', gap: 8, justifyContent: 'flex-end' }}>
                  <Button label="Hủy" size="sm" variant="ghost" onPress={() => setEditRel(false)} />
                  <Button
                    nativeID="member-save-relation"
                    label="Lưu"
                    size="sm"
                    icon="checkmark"
                    loading={update.isPending}
                    onPress={() => update.mutate({ id: member.relationshipId, relation_type: relation, reverse_relation_type: reverse || resolveReverseRelation(relation) })}
                  />
                </View>
              </>
            ) : (
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                <Badge label={`${member.name}: ${member.relation}`} color="primary" />
                <Icon name="swap-horizontal" size={16} color="textMuted" />
                <Badge label={`Bạn: ${member.reverseRelation}`} color="accent" />
              </View>
            )}
          </View>

          <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
            <Button label="Tạo nhắc nhở" icon="alarm-outline" variant="soft" size="sm" onPress={() => go(`/reminders?new=1&member=${member.uid}`)} />
            <Button label="Đặt lịch khám" icon="medkit-outline" variant="soft" size="sm" onPress={() => go(`/appointments?new=1&member=${member.uid}`)} />
            <Button label="Vùng an toàn" icon="shield-checkmark-outline" variant="soft" size="sm" onPress={() => go(`/safe-zones?new=1&member=${member.uid}`)} />
            <Button label="Sức khỏe" icon="pulse-outline" variant="soft" size="sm" onPress={() => go(`/health?member=${member.uid}`)} />
          </View>

          <View style={{ padding: 14, borderRadius: 16, borderWidth: 1, borderColor: c.dangerSoft, backgroundColor: c.dangerSoft, flexDirection: 'row', alignItems: 'center', gap: 12 }}>
            <View style={{ flex: 1 }}>
              <T variant="bodyStrong" color="danger">
                Xóa khỏi gia đình
              </T>
              <T variant="caption" color="textMuted">
                Bạn sẽ không còn theo dõi vị trí và nhận cảnh báo từ thành viên này.
              </T>
            </View>
            <Button
              nativeID="member-remove"
              label="Xóa"
              icon="trash-outline"
              variant="danger"
              size="sm"
              loading={remove.isPending}
              onPress={async () => {
                if (await confirm({ title: `Xóa ${member.name}?`, message: 'Mối quan hệ sẽ bị xóa ở cả hai phía.', confirmLabel: 'Xóa thành viên' })) remove.mutate(member.relationshipId);
              }}
            />
          </View>
        </View>
      ) : null}

      {tab === 'care' ? (
        <View style={{ gap: 16 }} dataSet={{ anim: 'fade' }}>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <T variant="h3" style={{ flex: 1 }}>
              Nhắc nhở ({reminders.data?.length ?? 0})
            </T>
            <Button label="Thêm" icon="add" size="sm" variant="soft" onPress={() => go(`/reminders?new=1&member=${member.uid}`)} />
          </View>
          {reminders.isLoading ? (
            <SkeletonList rows={3} height={50} />
          ) : !reminders.data?.length ? (
            <EmptyState compact icon="alarm-outline" title="Chưa có nhắc nhở" />
          ) : (
            reminders.data
              .slice()
              .sort((a, b) => a.reminder_time.localeCompare(b.reminder_time))
              .map((r) => {
                const meta = REMINDER_CATEGORY_META[r.category] ?? REMINDER_CATEGORY_META.other;
                return (
                  <View key={r.id} style={{ flexDirection: 'row', alignItems: 'center', gap: 12, opacity: r.is_active ? 1 : 0.5 }}>
                    <View style={{ width: 38, height: 38, borderRadius: 12, backgroundColor: c[meta.soft] as string, alignItems: 'center', justifyContent: 'center' }}>
                      <Icon name={meta.icon} size={18} color={meta.color} />
                    </View>
                    <View style={{ flex: 1 }}>
                      <T variant="bodyStrong">{r.title}</T>
                      <T variant="caption" color="textMuted">
                        {SCHEDULE_LABEL[r.schedule_type]}
                        {r.schedule_type === 'weekly' || r.schedule_type === 'custom' ? ` · ${weekdaysLabel(r.weekdays)}` : ''}
                        {r.schedule_type === 'once' ? ` · ${formatDate(r.schedule_date)}` : ''}
                      </T>
                    </View>
                    <T variant="bodyStrong">{shortTime(r.reminder_time)}</T>
                  </View>
                );
              })
          )}

          <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 8 }}>
            <T variant="h3" style={{ flex: 1 }}>
              Lịch khám sắp tới ({upcoming.length})
            </T>
            <Button label="Đặt lịch" icon="add" size="sm" variant="soft" onPress={() => go(`/appointments?new=1&member=${member.uid}`)} />
          </View>
          {appointments.isLoading ? (
            <SkeletonList rows={2} height={50} />
          ) : upcoming.length === 0 ? (
            <EmptyState compact icon="calendar-outline" title="Không có lịch khám" />
          ) : (
            upcoming.map((a) => (
              <View key={a.id} style={{ flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: 14, borderWidth: 1, borderColor: c.border }}>
                <Icon name="medkit" size={18} color="info" />
                <View style={{ flex: 1 }}>
                  <T variant="bodyStrong">{a.clinic}</T>
                  <T variant="caption" color="textMuted">
                    {a.doctor ? `BS. ${a.doctor} · ` : ''}
                    {shortTime(a.appointment_time)} · {formatDate(a.appointment_date)}
                  </T>
                </View>
              </View>
            ))
          )}
        </View>
      ) : null}

      {tab === 'kid' ? <KidReminders memberUid={member.uid} /> : null}

      {tab === 'location' ? (
        <View style={{ gap: 12 }} dataSet={{ anim: 'fade' }}>
          <View style={{ height: 320, borderRadius: 18, overflow: 'hidden', borderWidth: 1, borderColor: c.border }}>
            {loc?.latitude != null ? (
              <LazyFamilyMap members={[member]} fitKey={`detail-${member.uid}`} />
            ) : (
              <EmptyState icon="location-outline" title="Chưa có vị trí" description="Thiết bị của thành viên chưa gửi vị trí." />
            )}
          </View>
          <InfoTile icon="location-outline" label="Địa chỉ hiện tại" value={loc?.address || loc?.place_name || '—'} wide />
          <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap' }}>
            <InfoTile icon="time-outline" label="Cập nhật" value={loc?.updated_at ? relativeTime(loc.updated_at) : '—'} />
            <InfoTile icon="locate-outline" label="Độ chính xác" value={loc?.accuracy != null ? `± ${Math.round(loc.accuracy)} m` : '—'} />
          </View>
          <Button label="Mở bản đồ & lộ trình" icon="map-outline" onPress={() => go(`/map?uid=${member.uid}`)} />
        </View>
      ) : null}
    </Modal>
  );
}

function InfoTile({ icon, label, value, wide }: { icon: string; label: string; value: string; wide?: boolean }) {
  const c = useTheme();
  return (
    <View style={{ flexBasis: wide ? '100%' : '47%', flexGrow: 1, flexDirection: 'row', gap: 10, padding: 12, borderRadius: 14, backgroundColor: c.surfaceAlt }}>
      <Icon name={icon} size={17} color="primary" style={{ marginTop: 2 }} />
      <View style={{ flex: 1 }}>
        <T variant="caption" color="textMuted">
          {label}
        </T>
        <T variant="bodyStrong" numberOfLines={2}>
          {value}
        </T>
      </View>
    </View>
  );
}

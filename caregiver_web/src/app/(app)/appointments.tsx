import React, { useEffect, useMemo, useState } from 'react';
import { View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import {
  Avatar,
  Badge,
  Button,
  Card,
  DateField,
  EmptyState,
  Field,
  Icon,
  IconButton,
  MemberChips,
  Modal,
  SearchInput,
  Segmented,
  SelectField,
  SkeletonList,
  StatCard,
  Switch,
  T,
  TextField,
} from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { Grid, Page } from '../../components/layout/Page';
import { appointmentApi } from '../../api/endpoints';
import { useApiMutation, useAppointments, useFamilyMembers } from '../../api/hooks';
import { usePageShortcuts } from '../../hooks/usePageShortcuts';
import { daysUntil, formatDateLong, normalizeSearch, shortTime, toISODate } from '../../utils/format';
import { APPOINTMENT_STATUS_META } from '../../utils/constants';
import type { AppointmentStatus, FamilyMember, MedicalAppointment, MedicalAppointmentInput } from '../../api/types';

type StatusFilter = 'all' | AppointmentStatus;

function AppointmentForm({ visible, onClose, editing, members, defaultMember }: { visible: boolean; onClose: () => void; editing: MedicalAppointment | null; members: FamilyMember[]; defaultMember?: string }) {
  const c = useTheme();
  const [member, setMember] = useState('');
  const [clinic, setClinic] = useState('');
  const [doctor, setDoctor] = useState('');
  const [date, setDate] = useState(toISODate());
  const [time, setTime] = useState('08:00');
  const [notes, setNotes] = useState('');
  const [status, setStatus] = useState<AppointmentStatus>('upcoming');
  const [r1d, setR1d] = useState(true);
  const [r2h, setR2h] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!visible) return;
    setError(null);
    if (editing) {
      setMember(editing.member_uid);
      setClinic(editing.clinic);
      setDoctor(editing.doctor ?? '');
      setDate(editing.appointment_date);
      setTime(shortTime(editing.appointment_time));
      setNotes(editing.notes ?? '');
      setStatus(editing.status);
      setR1d(editing.remind_before_1_day);
      setR2h(editing.remind_before_2_hours);
    } else {
      const d = new Date();
      d.setDate(d.getDate() + 1);
      setMember(defaultMember ?? members[0]?.uid ?? '');
      setClinic('');
      setDoctor('');
      setDate(toISODate(d));
      setTime('08:00');
      setNotes('');
      setStatus('upcoming');
      setR1d(true);
      setR2h(true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [visible, editing]);

  const save = useApiMutation((body: MedicalAppointmentInput) => (editing ? appointmentApi.update(editing.id, body) : appointmentApi.create(body)), {
    invalidate: [['appointments']],
    success: editing ? 'Đã cập nhật lịch khám' : 'Đã đặt lịch khám',
    onSuccess: onClose,
  });

  const submit = () => {
    if (!member) return setError('Vui lòng chọn thành viên.');
    if (!clinic.trim()) return setError('Vui lòng nhập nơi khám.');
    save.mutate({
      member_uid: member,
      clinic: clinic.trim(),
      doctor: doctor.trim(),
      appointment_date: date,
      appointment_time: time,
      notes: notes.trim(),
      status,
      remind_before_1_day: r1d,
      remind_before_2_hours: r2h,
    });
  };

  return (
    <Modal
      visible={visible}
      onClose={onClose}
      title={editing ? 'Sửa lịch khám' : 'Đặt lịch khám mới'}
      subtitle="Người thân sẽ được nhắc trước ngày và trước giờ khám"
      icon="medkit"
      width={620}
      footer={
        <>
          <Button label="Hủy" variant="secondary" onPress={onClose} />
          <Button nativeID="appointment-save" label={editing ? 'Lưu thay đổi' : 'Đặt lịch'} icon="checkmark" loading={save.isPending} onPress={submit} />
        </>
      }
    >
      {error ? (
        <View style={{ flexDirection: 'row', gap: 8, padding: 10, borderRadius: 12, backgroundColor: c.dangerSoft }}>
          <Icon name="alert-circle" size={16} color="danger" />
          <T variant="small" color="danger">
            {error}
          </T>
        </View>
      ) : null}
      <Field label="Người đi khám" required>
        {members.length <= 6 ? (
          <MemberChips members={members} value={member} onChange={(v) => setMember(v ?? '')} />
        ) : (
          <SelectField id="appointment-member" value={member} onChange={setMember} placeholder="Chọn thành viên" options={members.map((m) => ({ value: m.uid, label: m.name }))} />
        )}
      </Field>
      <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
        <Field label="Bệnh viện / Phòng khám" required style={{ flex: 1, minWidth: 220 }}>
          <TextField nativeID="appointment-clinic" value={clinic} onChangeText={setClinic} placeholder="vd: BV Chợ Rẫy" icon="business-outline" autoFocus />
        </Field>
        <Field label="Bác sĩ" style={{ flex: 1, minWidth: 200 }}>
          <TextField nativeID="appointment-doctor" value={doctor} onChangeText={setDoctor} placeholder="vd: Nguyễn Văn A" icon="person-outline" />
        </Field>
      </View>
      <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
        <Field label="Ngày khám" required style={{ flex: 1, minWidth: 180 }}>
          <DateField id="appointment-date" value={date} onChange={setDate} />
        </Field>
        <Field label="Giờ khám" required style={{ width: 160 }}>
          <DateField id="appointment-time" type="time" value={time} onChange={setTime} />
        </Field>
      </View>
      <Field label="Ghi chú" hint="Mang theo sổ khám, nhịn ăn sáng...">
        <TextField nativeID="appointment-notes" value={notes} onChangeText={setNotes} multiline placeholder="Ghi chú cho buổi khám" />
      </Field>
      {editing ? (
        <Field label="Trạng thái">
          <Segmented<AppointmentStatus>
            value={status}
            onChange={setStatus}
            options={(Object.keys(APPOINTMENT_STATUS_META) as AppointmentStatus[]).map((s) => ({ value: s, label: APPOINTMENT_STATUS_META[s].label, icon: APPOINTMENT_STATUS_META[s].icon }))}
          />
        </Field>
      ) : null}
      <View style={{ gap: 10, padding: 14, borderRadius: 14, backgroundColor: c.surfaceAlt }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
          <Switch value={r1d} onChange={setR1d} label="Nhắc trước 1 ngày" />
          <T variant="body">Nhắc trước 1 ngày</T>
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
          <Switch value={r2h} onChange={setR2h} label="Nhắc trước 2 giờ" />
          <T variant="body">Nhắc trước 2 giờ</T>
        </View>
      </View>
    </Modal>
  );
}

export default function AppointmentsScreen() {
  const c = useTheme();
  const { members } = useFamilyMembers();
  const { data, isLoading, refetch, isFetching } = useAppointments();
  const [memberFilter, setMemberFilter] = useState<string | undefined>();
  const [status, setStatus] = useState<StatusFilter>('upcoming');
  const [query, setQuery] = useState('');
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<MedicalAppointment | null>(null);
  const [defaultMember, setDefaultMember] = useState<string | undefined>();

  const openNew = (m?: string) => {
    setEditing(null);
    setDefaultMember(m ?? memberFilter);
    setFormOpen(true);
  };
  usePageShortcuts({ onNew: openNew, searchId: 'appointments-search' });

  const setStatusMut = useApiMutation((p: { a: MedicalAppointment; status: AppointmentStatus }) => appointmentApi.update(p.a.id, { status: p.status }), {
    invalidate: [['appointments']],
    success: (_, p) => (p.status === 'done' ? 'Đã đánh dấu đã khám' : p.status === 'cancelled' ? 'Đã hủy lịch khám' : 'Đã khôi phục lịch khám'),
  });
  const remove = useApiMutation((id: number) => appointmentApi.remove(id), { invalidate: [['appointments']], success: 'Đã xóa lịch khám' });

  const all = data ?? [];
  const groups = useMemo(() => {
    const q = normalizeSearch(query);
    const filtered = all
      .filter((a) => !memberFilter || a.member_uid === memberFilter)
      .filter((a) => status === 'all' || a.status === status)
      .filter((a) => !q || normalizeSearch(`${a.clinic} ${a.doctor} ${a.notes} ${a.member_user?.name ?? ''}`).includes(q))
      .sort((a, b) => {
        const k = `${a.appointment_date} ${a.appointment_time}`.localeCompare(`${b.appointment_date} ${b.appointment_time}`);
        return status === 'upcoming' ? k : -k;
      });
    const map = new Map<string, MedicalAppointment[]>();
    filtered.forEach((a) => map.set(a.appointment_date, [...(map.get(a.appointment_date) ?? []), a]));
    return Array.from(map.entries());
  }, [all, memberFilter, status, query]);

  const upcomingAll = all.filter((a) => a.status === 'upcoming');
  const overdue = upcomingAll.filter((a) => (daysUntil(a.appointment_date) ?? 0) < 0).length;
  const thisMonth = toISODate().slice(0, 7);

  const dayLabel = (iso: string) => {
    const d = daysUntil(iso);
    if (d === 0) return 'Hôm nay';
    if (d === 1) return 'Ngày mai';
    if (d === -1) return 'Hôm qua';
    return formatDateLong(iso);
  };

  return (
    <Page
      title="Lịch khám"
      subtitle="Quản lý lịch hẹn tái khám, bác sĩ và nhắc nhở trước giờ khám"
      onRefresh={refetch}
      refreshing={isFetching && !isLoading}
      actions={<Button nativeID="appointments-new" label="Đặt lịch khám" icon="add" hint="N" onPress={() => openNew()} />}
    >
      <Grid gap={16}>
        <StatCard delay={1} label="Sắp tới" value={upcomingAll.length - overdue} icon="calendar" tone="info" onPress={() => setStatus('upcoming')} />
        <StatCard delay={2} label="Trong 7 ngày" value={upcomingAll.filter((a) => { const d = daysUntil(a.appointment_date) ?? -1; return d >= 0 && d <= 7; }).length} icon="time" tone="primary" />
        <StatCard delay={3} label="Đã khám tháng này" value={all.filter((a) => a.status === 'done' && a.appointment_date.startsWith(thisMonth)).length} icon="checkmark-done" tone="success" onPress={() => setStatus('done')} />
        <StatCard delay={4} label="Quá hạn chưa cập nhật" value={overdue} icon="alert-circle" tone={overdue ? 'warning' : 'success'} hint={overdue ? 'Hãy đánh dấu đã khám hoặc hủy' : 'Mọi lịch đều được cập nhật'} />
      </Grid>

      <Card padding={16} anim="rise" delay={2} style={{ gap: 12 }}>
        <MemberChips members={members} value={memberFilter} onChange={setMemberFilter} allowAll allLabel="Tất cả thành viên" />
        <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
          <SearchInput nativeID="appointments-search" value={query} onChangeText={setQuery} placeholder="Tìm bệnh viện, bác sĩ... ( / )" style={{ flex: 1, minWidth: 220, maxWidth: 360 }} />
          <Segmented<StatusFilter>
            size="sm"
            value={status}
            onChange={setStatus}
            options={[
              { value: 'upcoming', label: 'Sắp tới', count: upcomingAll.length },
              { value: 'done', label: 'Đã khám' },
              { value: 'cancelled', label: 'Đã hủy' },
              { value: 'all', label: 'Tất cả' },
            ]}
          />
        </View>
      </Card>

      {isLoading ? (
        <SkeletonList rows={4} height={96} />
      ) : groups.length === 0 ? (
        <Card>
          <EmptyState icon="calendar-outline" title="Không có lịch khám" description="Đặt lịch tái khám để người thân được nhắc trước." action={<Button label="Đặt lịch khám" icon="add" onPress={() => openNew()} />} />
        </Card>
      ) : (
        groups.map(([date, items], gi) => {
          const d = daysUntil(date) ?? 0;
          return (
            <View key={date} style={{ gap: 10 }} dataSet={{ anim: 'rise', delay: String(Math.min(6, gi + 1)) }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: d === 0 ? c.danger : d > 0 ? c.info : c.borderStrong }} />
                <T variant="h3" style={{ textTransform: 'capitalize' }}>
                  {dayLabel(date)}
                </T>
                {d > 1 ? <Badge label={`Còn ${d} ngày`} color="info" size="sm" /> : null}
                {d < 0 && items.some((a) => a.status === 'upcoming') ? <Badge label="Quá hạn" color="warning" size="sm" /> : null}
              </View>
              {items.map((a) => {
                const meta = APPOINTMENT_STATUS_META[a.status];
                const m = members.find((x) => x.uid === a.member_uid);
                return (
                  <Card key={a.id} hoverable padding={16} style={{ flexDirection: 'row', gap: 16, alignItems: 'center', flexWrap: 'wrap', opacity: a.status === 'cancelled' ? 0.6 : 1 }}>
                    <View style={{ width: 76, alignItems: 'center', paddingVertical: 10, borderRadius: 14, backgroundColor: c[meta.soft] as string }}>
                      <T variant="h2" color={meta.color}>
                        {shortTime(a.appointment_time)}
                      </T>
                      <T variant="caption" color={meta.color} style={{ fontWeight: '700' }}>
                        {meta.label}
                      </T>
                    </View>
                    <View style={{ flex: 1, minWidth: 220, gap: 4 }}>
                      <T variant="h3" style={a.status === 'cancelled' ? { textDecorationLine: 'line-through' } : undefined}>
                        {a.clinic}
                      </T>
                      <View style={{ flexDirection: 'row', gap: 14, flexWrap: 'wrap' }}>
                        {a.doctor ? (
                          <View style={{ flexDirection: 'row', gap: 5, alignItems: 'center' }}>
                            <Icon name="person-outline" size={14} color="textMuted" />
                            <T variant="small" color="textSoft">
                              BS. {a.doctor}
                            </T>
                          </View>
                        ) : null}
                        <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
                          <Avatar name={m?.name ?? a.member_user?.name} uri={m?.avatar ?? a.member_user?.avata} size={20} />
                          <T variant="small" color="textSoft">
                            {m?.name ?? a.member_user?.name}
                          </T>
                        </View>
                        {a.remind_before_1_day || a.remind_before_2_hours ? (
                          <View style={{ flexDirection: 'row', gap: 5, alignItems: 'center' }}>
                            <Icon name="notifications-outline" size={14} color="textMuted" />
                            <T variant="small" color="textMuted">
                              {[a.remind_before_1_day && 'trước 1 ngày', a.remind_before_2_hours && 'trước 2 giờ'].filter(Boolean).join(', ')}
                            </T>
                          </View>
                        ) : null}
                      </View>
                      {a.notes ? (
                        <T variant="small" color="textMuted" numberOfLines={2}>
                          📝 {a.notes}
                        </T>
                      ) : null}
                    </View>
                    <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
                      {a.status === 'upcoming' ? (
                        <>
                          <Button label="Đã khám" icon="checkmark" size="sm" variant="soft" onPress={() => setStatusMut.mutate({ a, status: 'done' })} />
                          <IconButton icon="close-circle-outline" label="Hủy lịch" onPress={async () => { if (await confirm({ title: 'Hủy lịch khám?', confirmLabel: 'Hủy lịch', icon: 'close-circle-outline' })) setStatusMut.mutate({ a, status: 'cancelled' }); }} />
                        </>
                      ) : (
                        <Button label="Khôi phục" icon="refresh" size="sm" variant="ghost" onPress={() => setStatusMut.mutate({ a, status: 'upcoming' })} />
                      )}
                      <IconButton icon="create-outline" label="Sửa" onPress={() => { setEditing(a); setFormOpen(true); }} />
                      <IconButton icon="trash-outline" label="Xóa" color={c.danger} onPress={async () => { if (await confirm({ title: 'Xóa lịch khám?', message: `${a.clinic} · ${shortTime(a.appointment_time)}`, confirmLabel: 'Xóa' })) remove.mutate(a.id); }} />
                    </View>
                  </Card>
                );
              })}
            </View>
          );
        })
      )}

      <AppointmentForm visible={formOpen} onClose={() => setFormOpen(false)} editing={editing} members={members} defaultMember={defaultMember} />
    </Page>
  );
}

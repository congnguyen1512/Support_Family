import React, { useEffect, useMemo, useState } from 'react';
import { Pressable, View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { transition, web, type WebPressState } from '../../theme/web';
import {
  Avatar,
  Badge,
  Button,
  Card,
  ChoiceCards,
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
  WeekdayPicker,
} from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { Grid, Page } from '../../components/layout/Page';
import { reminderApi } from '../../api/endpoints';
import { useApiMutation, useFamilyMembers, useReminders } from '../../api/hooks';
import { usePageShortcuts } from '../../hooks/usePageShortcuts';
import { useBreakpoint, useNow } from '../../hooks/common';
import { formatDate, normalizeSearch, shortTime, timeToMinutes, toISODate } from '../../utils/format';
import { REMINDER_CATEGORY_META, SCHEDULE_LABEL, weekdaysLabel } from '../../utils/constants';
import { occursOn, slotState } from '../../utils/schedule';
import type { FamilyMember, Reminder, ReminderCategory, ReminderInput, ReminderSchedule } from '../../api/types';

type CatFilter = 'all' | ReminderCategory;
type View_ = 'all' | 'today' | 'inactive';

const TEMPLATES: { title: string; category: ReminderCategory; time: string; subtitle?: string }[] = [
  { title: 'Uống thuốc huyết áp', category: 'medicine', time: '08:00', subtitle: '1 viên sau ăn sáng' },
  { title: 'Uống thuốc tiểu đường', category: 'medicine', time: '19:00', subtitle: 'Sau ăn tối' },
  { title: 'Ăn sáng', category: 'food', time: '07:00' },
  { title: 'Uống nước', category: 'food', time: '10:00', subtitle: '1 ly nước ấm' },
  { title: 'Đo huyết áp', category: 'health', time: '07:30' },
  { title: 'Đo đường huyết', category: 'health', time: '06:30' },
  { title: 'Đi ngủ sớm', category: 'other', time: '21:30' },
];

const CATEGORY_OPTIONS = (Object.keys(REMINDER_CATEGORY_META) as ReminderCategory[]).map((k) => ({
  value: k,
  label: REMINDER_CATEGORY_META[k].label,
  icon: REMINDER_CATEGORY_META[k].icon,
}));

/* ── Form tạo / sửa ───────────────────────────────────────── */
function ReminderForm({
  visible,
  onClose,
  editing,
  members,
  defaultMember,
}: {
  visible: boolean;
  onClose: () => void;
  editing: Reminder | null;
  members: FamilyMember[];
  defaultMember?: string;
}) {
  const c = useTheme();
  const [member, setMember] = useState('');
  const [title, setTitle] = useState('');
  const [subtitle, setSubtitle] = useState('');
  const [category, setCategory] = useState<ReminderCategory>('medicine');
  const [time, setTime] = useState('08:00');
  const [schedule, setSchedule] = useState<ReminderSchedule>('daily');
  const [days, setDays] = useState<number[]>([1, 2, 3, 4, 5, 6, 7]);
  const [date, setDate] = useState(toISODate());
  const [active, setActive] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!visible) return;
    setError(null);
    if (editing) {
      setMember(editing.member_uid);
      setTitle(editing.title);
      setSubtitle(editing.subtitle ?? '');
      setCategory(editing.category);
      setTime(shortTime(editing.reminder_time));
      setSchedule(editing.schedule_type);
      setDays(editing.weekdays?.length ? editing.weekdays.map((d) => (d === 0 ? 7 : d)) : [1, 2, 3, 4, 5, 6, 7]);
      setDate(editing.schedule_date?.slice(0, 10) ?? toISODate());
      setActive(editing.is_active);
    } else {
      setMember(defaultMember ?? members[0]?.uid ?? '');
      setTitle('');
      setSubtitle('');
      setCategory('medicine');
      setTime('08:00');
      setSchedule('daily');
      setDays([1, 2, 3, 4, 5, 6, 7]);
      setDate(toISODate());
      setActive(true);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [visible, editing]);

  const save = useApiMutation(
    (body: ReminderInput) => (editing ? reminderApi.update(editing.id, body) : reminderApi.create(body)),
    { invalidate: [['reminders']], success: editing ? 'Đã cập nhật nhắc nhở' : 'Đã tạo nhắc nhở', onSuccess: onClose },
  );

  const submit = () => {
    if (!member) return setError('Vui lòng chọn thành viên.');
    if (!title.trim()) return setError('Vui lòng nhập tiêu đề nhắc nhở.');
    if ((schedule === 'weekly' || schedule === 'custom') && days.length === 0) return setError('Chọn ít nhất một ngày trong tuần.');
    save.mutate({
      member_uid: member,
      title: title.trim(),
      subtitle: subtitle.trim() || null,
      category,
      reminder_time: time,
      schedule_type: schedule,
      weekdays: schedule === 'weekly' || schedule === 'custom' ? days : [],
      schedule_date: schedule === 'once' ? date : null,
      is_active: active,
    });
  };

  return (
    <Modal
      visible={visible}
      onClose={onClose}
      title={editing ? 'Sửa nhắc nhở' : 'Tạo nhắc nhở mới'}
      subtitle="Thông báo sẽ được gửi đến điện thoại của người thân đúng giờ"
      icon="alarm"
      width={640}
      footer={
        <>
          <View style={{ flex: 1, flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Switch value={active} onChange={setActive} label="Kích hoạt" />
            <T variant="small" color="textSoft">
              {active ? 'Đang bật' : 'Tạm tắt'}
            </T>
          </View>
          <Button label="Hủy" variant="secondary" onPress={onClose} />
          <Button nativeID="reminder-save" label={editing ? 'Lưu thay đổi' : 'Tạo nhắc nhở'} icon="checkmark" loading={save.isPending} onPress={submit} hint="Ctrl ↵" />
        </>
      }
    >
      <View
        style={{ gap: 16 }}
        {...({
          onKeyDown: (e: KeyboardEvent) => {
            if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') submit();
          },
        } as object)}
      >
        {error ? (
          <View style={{ flexDirection: 'row', gap: 8, padding: 10, borderRadius: 12, backgroundColor: c.dangerSoft }}>
            <Icon name="alert-circle" size={16} color="danger" />
            <T variant="small" color="danger">
              {error}
            </T>
          </View>
        ) : null}

        <Field label="Dành cho" required>
          {members.length <= 6 ? <MemberChips members={members} value={member} onChange={(v) => setMember(v ?? '')} /> : <SelectField id="reminder-member" value={member} onChange={setMember} placeholder="Chọn thành viên" options={members.map((m) => ({ value: m.uid, label: `${m.name} (${m.relation})` }))} />}
        </Field>

        {!editing ? (
          <View style={{ gap: 6 }}>
            <T variant="small" color="textSoft" style={{ fontWeight: '600' }}>
              Mẫu nhanh
            </T>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
              {TEMPLATES.map((t) => (
                <Button
                  key={t.title}
                  label={t.title}
                  size="sm"
                  variant="secondary"
                  icon={REMINDER_CATEGORY_META[t.category].icon}
                  onPress={() => {
                    setTitle(t.title);
                    setCategory(t.category);
                    setTime(t.time);
                    setSubtitle(t.subtitle ?? '');
                  }}
                />
              ))}
            </View>
          </View>
        ) : null}

        <Field label="Loại nhắc nhở">
          <ChoiceCards options={CATEGORY_OPTIONS} value={category} onChange={setCategory} />
        </Field>

        <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
          <Field label="Tiêu đề" required style={{ flex: 2, minWidth: 240 }}>
            <TextField nativeID="reminder-title" value={title} onChangeText={setTitle} placeholder="vd: Uống thuốc huyết áp" autoFocus />
          </Field>
          <Field label="Giờ nhắc" required style={{ width: 150 }}>
            <DateField id="reminder-time" type="time" value={time} onChange={setTime} />
          </Field>
        </View>

        <Field label="Ghi chú" hint="Liều lượng, hướng dẫn... (không bắt buộc)">
          <TextField nativeID="reminder-subtitle" value={subtitle} onChangeText={setSubtitle} placeholder="vd: 1 viên sau ăn" icon="document-text-outline" />
        </Field>

        <Field label="Lặp lại">
          <Segmented<ReminderSchedule>
            value={schedule}
            onChange={setSchedule}
            options={[
              { value: 'daily', label: 'Mỗi ngày', icon: 'repeat' },
              { value: 'weekly', label: 'Theo thứ', icon: 'calendar-outline' },
              { value: 'once', label: 'Một lần', icon: 'radio-button-on-outline' },
              { value: 'custom', label: 'Tùy chỉnh', icon: 'options-outline' },
            ]}
          />
        </Field>
        {schedule === 'weekly' || schedule === 'custom' ? <WeekdayPicker value={days} onChange={setDays} /> : null}
        {schedule === 'once' ? (
          <Field label="Ngày nhắc" style={{ maxWidth: 240 }}>
            <DateField id="reminder-date" value={date} onChange={setDate} min={toISODate()} />
          </Field>
        ) : null}
      </View>
    </Modal>
  );
}

/* ── Trang ─────────────────────────────────────────────────── */
export default function RemindersScreen() {
  const c = useTheme();
  const now = useNow(60_000);
  const { isMobile } = useBreakpoint();
  const { members } = useFamilyMembers();
  const [memberFilter, setMemberFilter] = useState<string | undefined>(undefined);
  const [cat, setCat] = useState<CatFilter>('all');
  const [view, setView] = useState<View_>('all');
  const [query, setQuery] = useState('');
  const [selected, setSelected] = useState<number[]>([]);
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Reminder | null>(null);
  const [defaultMember, setDefaultMember] = useState<string | undefined>();
  const { data, isLoading, refetch, isFetching } = useReminders();

  const openNew = (m?: string) => {
    setEditing(null);
    setDefaultMember(m ?? memberFilter);
    setFormOpen(true);
  };
  usePageShortcuts({ onNew: openNew, searchId: 'reminders-search' });

  const toggle = useApiMutation((r: Reminder) => reminderApi.update(r.id, { is_active: !r.is_active }), {
    invalidate: [['reminders']],
    success: (_, r) => (r.is_active ? `Đã tắt "${r.title}"` : `Đã bật "${r.title}"`),
  });
  const remove = useApiMutation((id: number) => reminderApi.remove(id), { invalidate: [['reminders']], success: 'Đã xóa nhắc nhở' });
  const bulk = useApiMutation((ids: number[]) => reminderApi.bulkRemove(ids), {
    invalidate: [['reminders']],
    success: (_, ids) => `Đã xóa ${ids.length} nhắc nhở`,
    onSuccess: () => setSelected([]),
  });

  const memberOf = (uid: string) => members.find((m) => m.uid === uid);

  const list = useMemo(() => {
    const q = normalizeSearch(query);
    return (data ?? [])
      .filter((r) => !memberFilter || r.member_uid === memberFilter)
      .filter((r) => cat === 'all' || r.category === cat)
      .filter((r) => (view === 'today' ? r.is_active && occursOn(r, now) : view === 'inactive' ? !r.is_active : true))
      .filter((r) => !q || normalizeSearch(`${r.title} ${r.subtitle ?? ''} ${r.member_user?.name ?? ''}`).includes(q))
      .sort((a, b) => timeToMinutes(a.reminder_time) - timeToMinutes(b.reminder_time));
  }, [data, memberFilter, cat, view, query, now]);

  const all = data ?? [];
  const todayCount = all.filter((r) => r.is_active && occursOn(r, now)).length;
  const medicineCount = all.filter((r) => r.category === 'medicine' && r.is_active).length;
  const allSelected = list.length > 0 && list.every((r) => selected.includes(r.id));

  const toggleSelect = (id: number) => setSelected((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));

  return (
    <Page
      title="Nhắc nhở"
      subtitle="Lịch uống thuốc, ăn uống và sinh hoạt hằng ngày của người thân"
      onRefresh={refetch}
      refreshing={isFetching && !isLoading}
      actions={<Button nativeID="reminders-new" label="Tạo nhắc nhở" icon="add" hint="N" onPress={() => openNew()} />}
    >
      <Grid gap={16}>
        <StatCard delay={1} label="Tổng nhắc nhở" value={all.length} icon="alarm" tone="primary" hint={`${all.filter((r) => r.is_active).length} đang bật`} />
        <StatCard delay={2} label="Diễn ra hôm nay" value={todayCount} icon="today" tone="info" onPress={() => setView('today')} />
        <StatCard delay={3} label="Nhắc uống thuốc" value={medicineCount} icon="medkit" tone="pink" onPress={() => setCat('medicine')} />
        <StatCard delay={4} label="Đang tạm tắt" value={all.filter((r) => !r.is_active).length} icon="pause-circle" tone="warning" onPress={() => setView('inactive')} />
      </Grid>

      <Card padding={0} anim="rise" delay={2}>
        <View style={{ padding: 16, gap: 12 }}>
          <MemberChips members={members} value={memberFilter} onChange={setMemberFilter} allowAll allLabel="Tất cả thành viên" />
          <View style={{ flexDirection: 'row', gap: 10, flexWrap: 'wrap', alignItems: 'center' }}>
            <SearchInput nativeID="reminders-search" value={query} onChangeText={setQuery} placeholder="Tìm nhắc nhở... ( / )" style={{ flex: 1, minWidth: 220, maxWidth: 360 }} />
            <Segmented<CatFilter>
              size="sm"
              value={cat}
              onChange={setCat}
              options={[{ value: 'all', label: 'Tất cả' }, ...CATEGORY_OPTIONS.map((o) => ({ value: o.value, label: o.label, icon: o.icon }))]}
            />
            <Segmented<View_>
              size="sm"
              value={view}
              onChange={setView}
              options={[
                { value: 'all', label: 'Mọi lịch' },
                { value: 'today', label: 'Hôm nay', count: todayCount },
                { value: 'inactive', label: 'Đã tắt' },
              ]}
            />
          </View>
        </View>

        {selected.length > 0 ? (
          <View dataSet={{ anim: 'fade' }} style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingVertical: 10, backgroundColor: c.primarySoft }}>
            <T variant="bodyStrong" color="primary" style={{ flex: 1 }}>
              Đã chọn {selected.length} nhắc nhở
            </T>
            <Button label="Bỏ chọn" size="sm" variant="ghost" onPress={() => setSelected([])} />
            <Button
              nativeID="reminders-bulk-delete"
              label="Xóa đã chọn"
              size="sm"
              variant="danger"
              icon="trash-outline"
              loading={bulk.isPending}
              onPress={async () => {
                if (await confirm({ title: `Xóa ${selected.length} nhắc nhở?`, message: 'Thao tác này không thể hoàn tác.', confirmLabel: 'Xóa tất cả' })) bulk.mutate(selected);
              }}
            />
          </View>
        ) : null}

        {!isMobile ? (
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingVertical: 10, borderTopWidth: 1, borderBottomWidth: 1, borderColor: c.border, backgroundColor: c.surfaceAlt }}>
            <Checkbox checked={allSelected} onPress={() => setSelected(allSelected ? [] : list.map((r) => r.id))} />
            <T variant="label" color="textMuted" style={{ width: 70 }}>
              Giờ
            </T>
            <T variant="label" color="textMuted" style={{ flex: 2 }}>
              Nhắc nhở
            </T>
            <T variant="label" color="textMuted" style={{ flex: 1.2 }}>
              Thành viên
            </T>
            <T variant="label" color="textMuted" style={{ flex: 1.2 }}>
              Lịch lặp
            </T>
            <T variant="label" color="textMuted" style={{ width: 150, textAlign: 'right' }}>
              Thao tác
            </T>
          </View>
        ) : null}

        <View style={{ paddingBottom: 6 }}>
          {isLoading ? (
            <View style={{ padding: 16 }}>
              <SkeletonList rows={6} height={52} />
            </View>
          ) : list.length === 0 ? (
            <EmptyState
              icon="alarm-outline"
              title={all.length ? 'Không có nhắc nhở phù hợp' : 'Chưa có nhắc nhở nào'}
              description={all.length ? 'Thử đổi bộ lọc.' : 'Tạo nhắc nhở uống thuốc, ăn uống... cho người thân chỉ với vài thao tác.'}
              action={<Button label="Tạo nhắc nhở" icon="add" onPress={() => openNew()} />}
            />
          ) : (
            list.map((r) => {
              const meta = REMINDER_CATEGORY_META[r.category] ?? REMINDER_CATEGORY_META.other;
              const m = memberOf(r.member_uid);
              const isToday = r.is_active && occursOn(r, now);
              const st = isToday ? slotState(r.reminder_time, now) : null;
              const checked = selected.includes(r.id);
              return (
                <Pressable
                  key={r.id}
                  onPress={() => {
                    setEditing(r);
                    setFormOpen(true);
                  }}
                  style={(state) => {
                    const { hovered } = state as WebPressState;
                    return [
                      { flexDirection: 'row', alignItems: 'center', gap: 12, paddingHorizontal: 16, paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: c.border, flexWrap: isMobile ? 'wrap' : 'nowrap' },
                      { backgroundColor: checked ? c.primarySoft : hovered ? c.surfaceHover : 'transparent', opacity: r.is_active ? 1 : 0.6 },
                      transition('background-color', 120),
                      web({ cursor: 'pointer' }),
                    ];
                  }}
                >
                  <Checkbox checked={checked} onPress={() => toggleSelect(r.id)} />
                  <View style={{ width: 70 }}>
                    <T variant="h3" color={st === 'done' ? 'textMuted' : 'text'}>
                      {shortTime(r.reminder_time)}
                    </T>
                    {st === 'now' ? <Badge label="Sắp tới" color="warning" size="sm" /> : st === 'done' ? <T variant="caption" color="textMuted">Đã qua</T> : null}
                  </View>
                  <View style={{ flex: 2, flexDirection: 'row', alignItems: 'center', gap: 10, minWidth: 200 }}>
                    <View style={{ width: 38, height: 38, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: c[meta.soft] as string }}>
                      <Icon name={meta.icon} size={18} color={meta.color} />
                    </View>
                    <View style={{ flex: 1, minWidth: 0 }}>
                      <T variant="bodyStrong" numberOfLines={1}>
                        {r.title}
                      </T>
                      <T variant="caption" color="textMuted" numberOfLines={1}>
                        {r.subtitle || meta.label}
                      </T>
                    </View>
                  </View>
                  <View style={{ flex: 1.2, flexDirection: 'row', alignItems: 'center', gap: 8, minWidth: 140 }}>
                    <Avatar name={m?.name ?? r.member_user?.name} uri={m?.avatar ?? r.member_user?.avata} size={28} />
                    <T variant="small" numberOfLines={1} style={{ flex: 1 }}>
                      {m?.name ?? r.member_user?.name ?? '—'}
                    </T>
                  </View>
                  <View style={{ flex: 1.2, minWidth: 120 }}>
                    <T variant="small" color="textSoft">
                      {SCHEDULE_LABEL[r.schedule_type]}
                    </T>
                    <T variant="caption" color="textMuted" numberOfLines={1}>
                      {r.schedule_type === 'once' ? formatDate(r.schedule_date) : r.schedule_type === 'daily' ? 'Tất cả các ngày' : weekdaysLabel(r.weekdays)}
                    </T>
                  </View>
                  <View style={{ width: 150, flexDirection: 'row', alignItems: 'center', justifyContent: 'flex-end', gap: 4 }}>
                    <Switch size="sm" value={r.is_active} onChange={() => toggle.mutate(r)} label="Bật/tắt nhắc nhở" />
                    <IconButton icon="create-outline" label="Sửa" size={32} onPress={() => { setEditing(r); setFormOpen(true); }} />
                    <IconButton
                      icon="trash-outline"
                      label="Xóa"
                      size={32}
                      color={c.danger}
                      onPress={async () => {
                        if (await confirm({ title: 'Xóa nhắc nhở?', message: `"${r.title}" sẽ bị xóa vĩnh viễn.`, confirmLabel: 'Xóa' })) remove.mutate(r.id);
                      }}
                    />
                  </View>
                </Pressable>
              );
            })
          )}
        </View>
      </Card>

      <ReminderForm visible={formOpen} onClose={() => setFormOpen(false)} editing={editing} members={members} defaultMember={defaultMember} />
    </Page>
  );
}

function Checkbox({ checked, onPress }: { checked: boolean; onPress: () => void }) {
  const c = useTheme();
  return (
    <Pressable
      onPress={(e) => {
        e.stopPropagation?.();
        onPress();
      }}
      accessibilityRole="checkbox"
      accessibilityState={{ checked }}
      style={[
        { width: 20, height: 20, borderRadius: 6, borderWidth: 1.5, alignItems: 'center', justifyContent: 'center', borderColor: checked ? c.primary : c.borderStrong, backgroundColor: checked ? c.primary : 'transparent' },
        transition('background-color, border-color', 120),
        web({ cursor: 'pointer' }),
      ]}
    >
      {checked ? <Icon name="checkmark" size={14} color="#fff" /> : null}
    </Pressable>
  );
}

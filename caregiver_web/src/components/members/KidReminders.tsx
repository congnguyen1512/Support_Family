import React, { useState } from 'react';
import { View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { Badge, Button, DateField, EmptyState, Field, IconButton, Segmented, SkeletonList, Switch, T, TextField, WeekdayPicker } from '../ui';
import { confirm } from '../ui/Overlay';
import { kidReminderApi } from '../../api/endpoints';
import { qk, useApiMutation, useKidReminders } from '../../api/hooks';
import { formatDate, shortTime, toISODate } from '../../utils/format';
import { SCHEDULE_LABEL, weekdaysLabel } from '../../utils/constants';
import type { KidReminder } from '../../api/types';

type Sched = 'daily' | 'weekly' | 'once';

const TEMPLATES = ['Đi học', 'Làm bài tập', 'Đánh răng', 'Đi ngủ', 'Uống sữa', 'Tắm'];

/** Nhắc việc cho trẻ em (kid_reminders) — hiển thị trong hồ sơ thành viên trẻ em. */
export function KidReminders({ memberUid }: { memberUid: string }) {
  const c = useTheme();
  const { data, isLoading } = useKidReminders(memberUid);
  const [editing, setEditing] = useState<KidReminder | 'new' | null>(null);
  const [title, setTitle] = useState('');
  const [time, setTime] = useState('07:00');
  const [sched, setSched] = useState<Sched>('daily');
  const [days, setDays] = useState<number[]>([1, 2, 3, 4, 5]);
  const [date, setDate] = useState(toISODate());

  const invalidate = [qk.kidReminders(memberUid)];
  const save = useApiMutation(
    (payload: { id?: number; body: Parameters<typeof kidReminderApi.create>[0] }) =>
      payload.id ? kidReminderApi.update(payload.id, payload.body) : kidReminderApi.create(payload.body),
    { invalidate, success: (_, v) => (v.id ? 'Đã cập nhật nhắc việc' : 'Đã thêm nhắc việc'), onSuccess: () => setEditing(null) },
  );
  const toggle = useApiMutation((r: KidReminder) => kidReminderApi.update(r.id, { is_active: !r.is_active }), { invalidate });
  const remove = useApiMutation((id: number) => kidReminderApi.remove(id), { invalidate, success: 'Đã xóa nhắc việc' });

  const open = (r: KidReminder | 'new') => {
    setEditing(r);
    if (r === 'new') {
      setTitle('');
      setTime('07:00');
      setSched('daily');
      setDays([1, 2, 3, 4, 5]);
      setDate(toISODate());
    } else {
      setTitle(r.title);
      setTime(shortTime(r.reminder_time));
      setSched(r.schedule_type);
      setDays(r.weekdays?.length ? r.weekdays : [1, 2, 3, 4, 5]);
      setDate(r.schedule_date ?? toISODate());
    }
  };

  const submit = () => {
    if (!title.trim()) return;
    save.mutate({
      id: editing && editing !== 'new' ? editing.id : undefined,
      body: {
        member_uid: memberUid,
        title: title.trim(),
        reminder_time: time,
        schedule_type: sched,
        weekdays: sched === 'weekly' ? days : [],
        schedule_date: sched === 'once' ? date : null,
      },
    });
  };

  return (
    <View style={{ gap: 12 }}>
      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
        <T variant="h3" style={{ flex: 1 }}>
          Nhắc việc cho bé
        </T>
        {!editing ? <Button nativeID="kid-add" label="Thêm" icon="add" size="sm" variant="soft" onPress={() => open('new')} /> : null}
      </View>

      {editing ? (
        <View dataSet={{ anim: 'fade' }} style={{ gap: 12, padding: 14, borderRadius: 16, borderWidth: 1, borderColor: c.primary, backgroundColor: c.primarySoft }}>
          <Field label="Việc cần làm" required>
            <TextField nativeID="kid-title" value={title} onChangeText={setTitle} placeholder="vd: Làm bài tập" autoFocus onSubmitEditing={submit} />
          </Field>
          <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
            {TEMPLATES.map((t) => (
              <Button key={t} label={t} size="sm" variant="secondary" onPress={() => setTitle(t)} />
            ))}
          </View>
          <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
            <Field label="Giờ" style={{ width: 140 }}>
              <DateField id="kid-time" type="time" value={time} onChange={setTime} />
            </Field>
            <Field label="Lặp lại" style={{ flex: 1 }}>
              <Segmented<Sched>
                value={sched}
                onChange={setSched}
                options={[
                  { value: 'daily', label: 'Mỗi ngày' },
                  { value: 'weekly', label: 'Theo thứ' },
                  { value: 'once', label: 'Một lần' },
                ]}
              />
            </Field>
          </View>
          {sched === 'weekly' ? <WeekdayPicker value={days} onChange={setDays} /> : null}
          {sched === 'once' ? (
            <Field label="Ngày">
              <DateField id="kid-date" value={date} onChange={setDate} min={toISODate()} />
            </Field>
          ) : null}
          <View style={{ flexDirection: 'row', gap: 8, justifyContent: 'flex-end' }}>
            <Button label="Hủy" variant="ghost" size="sm" onPress={() => setEditing(null)} />
            <Button nativeID="kid-save" label="Lưu" icon="checkmark" size="sm" loading={save.isPending} disabled={!title.trim()} onPress={submit} />
          </View>
        </View>
      ) : null}

      {isLoading ? (
        <SkeletonList rows={3} height={52} />
      ) : !data?.length ? (
        <EmptyState compact icon="happy-outline" title="Chưa có nhắc việc" description="Tạo nhắc nhở đi học, làm bài tập, đi ngủ... cho bé." />
      ) : (
        data
          .slice()
          .sort((a, b) => a.reminder_time.localeCompare(b.reminder_time))
          .map((r) => (
            <View key={r.id} style={{ flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, borderRadius: 14, borderWidth: 1, borderColor: c.border, opacity: r.is_active ? 1 : 0.55 }}>
              <View style={{ width: 56, alignItems: 'center', paddingVertical: 6, borderRadius: 10, backgroundColor: c.infoSoft }}>
                <T variant="bodyStrong" color="info">
                  {shortTime(r.reminder_time)}
                </T>
              </View>
              <View style={{ flex: 1 }}>
                <T variant="bodyStrong">{r.title}</T>
                <View style={{ flexDirection: 'row', gap: 6, marginTop: 2 }}>
                  <Badge label={SCHEDULE_LABEL[r.schedule_type]} color="info" size="sm" />
                  <T variant="caption" color="textMuted">
                    {r.schedule_type === 'weekly' ? weekdaysLabel(r.weekdays) : r.schedule_type === 'once' ? formatDate(r.schedule_date) : ''}
                  </T>
                </View>
              </View>
              <Switch size="sm" value={r.is_active} onChange={() => toggle.mutate(r)} label="Bật/tắt" />
              <IconButton icon="create-outline" label="Sửa" size={32} onPress={() => open(r)} />
              <IconButton
                icon="trash-outline"
                label="Xóa"
                size={32}
                color={c.danger}
                onPress={async () => {
                  if (await confirm({ title: 'Xóa nhắc việc?', message: `"${r.title}" sẽ bị xóa vĩnh viễn.`, confirmLabel: 'Xóa' })) remove.mutate(r.id);
                }}
              />
            </View>
          ))
      )}
    </View>
  );
}

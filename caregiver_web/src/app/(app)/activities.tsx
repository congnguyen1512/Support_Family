import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import {
  Badge,
  Button,
  Card,
  CardHeader,
  ChoiceCards,
  DateField,
  EmptyState,
  Field,
  Icon,
  IconButton,
  MemberChips,
  Modal,
  ProgressBar,
  ProgressRing,
  SkeletonList,
  Switch,
  T,
  TextField,
  WeekdayPicker,
} from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { Col, Grid, Page } from '../../components/layout/Page';
import { activityApi } from '../../api/endpoints';
import { qk, useActivities, useApiMutation, useFamilyMembers, useMetrics } from '../../api/hooks';
import { usePageShortcuts } from '../../hooks/usePageShortcuts';
import { formatNumber, shortTime, timeToMinutes, toISODate } from '../../utils/format';
import { ACTIVITY_TYPE_META, weekdaysLabel } from '../../utils/constants';
import { activityOccursOn } from '../../utils/schedule';
import type { ActivityType, PhysicalActivity, PhysicalActivityInput, PhysicalMetrics } from '../../api/types';

const TYPE_OPTIONS = (Object.keys(ACTIVITY_TYPE_META) as ActivityType[]).map((k) => ({ value: k, label: ACTIVITY_TYPE_META[k].label, icon: ACTIVITY_TYPE_META[k].icon }));

function ActivityForm({ visible, onClose, editing, memberUid }: { visible: boolean; onClose: () => void; editing: PhysicalActivity | null; memberUid?: string }) {
  const [name, setName] = useState('');
  const [type, setType] = useState<ActivityType>('walking');
  const [duration, setDuration] = useState('30');
  const [time, setTime] = useState('06:30');
  const [days, setDays] = useState<number[]>([1, 2, 3, 4, 5, 6, 7]);
  const [enabled, setEnabled] = useState(true);

  useEffect(() => {
    if (!visible) return;
    setName(editing?.name ?? '');
    setType(editing?.activity_type ?? 'walking');
    setDuration(String(editing?.duration_min ?? 30));
    setTime(shortTime(editing?.activity_time ?? '06:30'));
    setDays(editing?.repeat_days?.length ? editing.repeat_days : [1, 2, 3, 4, 5, 6, 7]);
    setEnabled(editing?.enabled ?? true);
  }, [visible, editing]);

  const save = useApiMutation((body: PhysicalActivityInput) => (editing ? activityApi.update(editing.id, body) : activityApi.create(body)), {
    invalidate: [['activities']],
    success: editing ? 'Đã cập nhật bài vận động' : 'Đã thêm bài vận động',
    onSuccess: onClose,
  });

  const valid = name.trim() && Number(duration) > 0 && days.length > 0;

  return (
    <Modal
      visible={visible}
      onClose={onClose}
      title={editing ? 'Sửa bài vận động' : 'Thêm bài vận động'}
      icon="walk"
      width={600}
      footer={
        <>
          <View style={{ flex: 1, flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Switch value={enabled} onChange={setEnabled} label="Bật" />
            <T variant="small" color="textSoft">
              {enabled ? 'Đang bật nhắc' : 'Tạm tắt'}
            </T>
          </View>
          <Button label="Hủy" variant="secondary" onPress={onClose} />
          <Button
            nativeID="activity-save"
            label="Lưu"
            icon="checkmark"
            disabled={!valid}
            loading={save.isPending}
            onPress={() =>
              save.mutate({ member_uid: memberUid, name: name.trim(), activity_type: type, duration_min: Number(duration), activity_time: time, repeat_days: days, enabled })
            }
          />
        </>
      }
    >
      <Field label="Loại vận động">
        <ChoiceCards
          options={TYPE_OPTIONS}
          value={type}
          columns={3}
          onChange={(v) => {
            setType(v);
            if (!name.trim() || TYPE_OPTIONS.some((o) => o.label === name)) setName(ACTIVITY_TYPE_META[v].label);
          }}
        />
      </Field>
      <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
        <Field label="Tên bài tập" required style={{ flex: 1, minWidth: 200 }}>
          <TextField nativeID="activity-name" value={name} onChangeText={setName} placeholder="vd: Đi bộ công viên" />
        </Field>
        <Field label="Thời lượng (phút)" required style={{ width: 150 }}>
          <TextField nativeID="activity-duration" value={duration} onChangeText={(v) => setDuration(v.replace(/[^0-9]/g, ''))} keyboardType="numeric" icon="timer-outline" />
        </Field>
        <Field label="Giờ" required style={{ width: 140 }}>
          <DateField id="activity-time" type="time" value={time} onChange={setTime} />
        </Field>
      </View>
      <Field label="Lặp lại vào">
        <WeekdayPicker value={days} onChange={setDays} />
      </Field>
    </Modal>
  );
}

function MetricsForm({ visible, onClose, metrics, memberUid, date }: { visible: boolean; onClose: () => void; metrics?: PhysicalMetrics; memberUid?: string; date: string }) {
  const [v, setV] = useState({ steps: '0', steps_goal: '6000', calories: '0', calories_goal: '300', active_minutes: '0', minutes_goal: '30' });
  useEffect(() => {
    if (!visible) return;
    setV({
      steps: String(metrics?.steps ?? 0),
      steps_goal: String(metrics?.steps_goal ?? 6000),
      calories: String(metrics?.calories ?? 0),
      calories_goal: String(metrics?.calories_goal ?? 300),
      active_minutes: String(metrics?.active_minutes ?? 0),
      minutes_goal: String(metrics?.minutes_goal ?? 30),
    });
  }, [visible, metrics]);
  const save = useApiMutation(activityApi.saveMetrics, { invalidate: [qk.metrics(memberUid, date)], success: 'Đã lưu chỉ số vận động', onSuccess: onClose });
  const num = (s: string) => Number(s) || 0;
  const row = (label: string, a: keyof typeof v, b: keyof typeof v, icon: string) => (
    <View style={{ flexDirection: 'row', gap: 12 }}>
      <Field label={label} style={{ flex: 1 }}>
        <TextField value={v[a]} onChangeText={(t) => setV((s) => ({ ...s, [a]: t.replace(/[^0-9]/g, '') }))} keyboardType="numeric" icon={icon} />
      </Field>
      <Field label="Mục tiêu" style={{ flex: 1 }}>
        <TextField value={v[b]} onChangeText={(t) => setV((s) => ({ ...s, [b]: t.replace(/[^0-9]/g, '') }))} keyboardType="numeric" icon="flag-outline" />
      </Field>
    </View>
  );
  return (
    <Modal
      visible={visible}
      onClose={onClose}
      title="Cập nhật chỉ số vận động"
      subtitle={`Ngày ${date.split('-').reverse().join('/')}`}
      icon="stats-chart"
      width={520}
      footer={
        <>
          <Button label="Hủy" variant="secondary" onPress={onClose} />
          <Button
            nativeID="metrics-save"
            label="Lưu chỉ số"
            icon="checkmark"
            loading={save.isPending}
            onPress={() =>
              save.mutate({
                member_uid: memberUid,
                metric_date: date,
                steps: num(v.steps),
                steps_goal: num(v.steps_goal),
                calories: num(v.calories),
                calories_goal: num(v.calories_goal),
                active_minutes: num(v.active_minutes),
                minutes_goal: num(v.minutes_goal),
              })
            }
          />
        </>
      }
    >
      {row('Số bước', 'steps', 'steps_goal', 'footsteps-outline')}
      {row('Calo (kcal)', 'calories', 'calories_goal', 'flame-outline')}
      {row('Phút vận động', 'active_minutes', 'minutes_goal', 'timer-outline')}
    </Modal>
  );
}

export default function ActivitiesScreen() {
  const c = useTheme();
  const { members } = useFamilyMembers();
  const [member, setMember] = useState<string | undefined>();
  const [date, setDate] = useState(toISODate());
  const [formOpen, setFormOpen] = useState(false);
  const [metricsOpen, setMetricsOpen] = useState(false);
  const [editing, setEditing] = useState<PhysicalActivity | null>(null);

  useEffect(() => {
    if (!member && members[0]) setMember(members[0].uid);
  }, [members, member]);

  const { memberParam } = usePageShortcuts({
    onNew: (m) => {
      if (m) setMember(m);
      setEditing(null);
      setFormOpen(true);
    },
  });
  useEffect(() => {
    if (memberParam) setMember(memberParam);
  }, [memberParam]);

  const metrics = useMetrics(member, date);
  const activities = useActivities(member);
  const toggle = useApiMutation((a: PhysicalActivity) => activityApi.toggle(a.id, !a.enabled), { invalidate: [['activities']] });
  const remove = useApiMutation((id: number) => activityApi.remove(id), { invalidate: [['activities']], success: 'Đã xóa bài vận động' });

  const m = metrics.data;
  const rings = [
    { label: 'Bước chân', value: m?.steps ?? 0, goal: m?.steps_goal ?? 6000, unit: 'bước', color: c.primary, icon: 'footsteps' },
    { label: 'Calo tiêu hao', value: m?.calories ?? 0, goal: m?.calories_goal ?? 300, unit: 'kcal', color: c.warning, icon: 'flame' },
    { label: 'Phút vận động', value: m?.active_minutes ?? 0, goal: m?.minutes_goal ?? 30, unit: 'phút', color: c.accent, icon: 'timer' },
  ];
  const list = (activities.data ?? []).slice().sort((a, b) => timeToMinutes(a.activity_time) - timeToMinutes(b.activity_time));
  const todayList = list.filter((a) => a.enabled && activityOccursOn(a, new Date(`${date}T12:00:00`)));
  const totalMin = todayList.reduce((s, a) => s + a.duration_min, 0);
  const selected = members.find((x) => x.uid === member);

  return (
    <Page
      title="Vận động"
      subtitle="Theo dõi bước chân, calo và lịch tập luyện của người thân"
      actions={<Button nativeID="activities-new" label="Thêm bài vận động" icon="add" hint="N" disabled={!member} onPress={() => { setEditing(null); setFormOpen(true); }} />}
    >
      <Card padding={16} anim="rise" style={{ gap: 12 }}>
        {members.length === 0 ? (
          <T variant="small" color="textMuted">
            Chưa có thành viên. Hãy mời người thân trước.
          </T>
        ) : (
          <MemberChips members={members} value={member} onChange={(v) => v && setMember(v)} />
        )}
      </Card>

      <Grid>
        <Col flex={2} minWidth={480}>
          <Card anim="rise" delay={2}>
            <CardHeader
              title={`Chỉ số ${date === toISODate() ? 'hôm nay' : `ngày ${date.split('-').reverse().join('/')}`}`}
              subtitle={selected ? selected.name : undefined}
              icon="stats-chart"
              right={
                <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center' }}>
                  <View style={{ width: 160 }}>
                    <DateField id="metrics-date" value={date} max={toISODate()} onChange={(v) => v && setDate(v)} />
                  </View>
                  <Button nativeID="metrics-edit" label="Cập nhật" icon="create-outline" size="sm" variant="soft" disabled={!member} onPress={() => setMetricsOpen(true)} />
                </View>
              }
            />
            {metrics.isLoading ? (
              <SkeletonList rows={1} height={180} />
            ) : (
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-around', gap: 24, paddingVertical: 8 }}>
                {rings.map((r) => {
                  const pct = r.goal ? r.value / r.goal : 0;
                  return (
                    <View key={r.label} style={{ alignItems: 'center', gap: 10 }}>
                      <ProgressRing value={pct} size={150} stroke={14} color={r.color}>
                        <Icon name={r.icon} size={18} color={r.color} />
                        <T variant="h1">{formatNumber(r.value)}</T>
                        <T variant="caption" color="textMuted">
                          / {formatNumber(r.goal)} {r.unit}
                        </T>
                      </ProgressRing>
                      <View style={{ alignItems: 'center' }}>
                        <T variant="bodyStrong">{r.label}</T>
                        <Badge label={pct >= 1 ? 'Đạt mục tiêu 🎉' : `${Math.round(pct * 100)}%`} color={pct >= 1 ? 'success' : 'textMuted'} size="sm" />
                      </View>
                    </View>
                  );
                })}
              </View>
            )}
          </Card>
        </Col>
        <Col minWidth={300}>
          <Card anim="rise" delay={3} style={{ flex: 1 }}>
            <CardHeader title="Kế hoạch trong ngày" subtitle={`${todayList.length} bài · ${totalMin} phút`} icon="today" iconColor="accent" />
            {todayList.length === 0 ? (
              <EmptyState compact icon="walk-outline" title="Không có bài tập hôm nay" />
            ) : (
              <View style={{ gap: 12 }}>
                {todayList.map((a) => {
                  const meta = ACTIVITY_TYPE_META[a.activity_type] ?? ACTIVITY_TYPE_META.other;
                  return (
                    <View key={a.id} style={{ gap: 6 }}>
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                        <Icon name={meta.icon} size={18} color={meta.color} />
                        <T variant="bodyStrong" style={{ flex: 1 }} numberOfLines={1}>
                          {a.name}
                        </T>
                        <T variant="small" color="textMuted">
                          {shortTime(a.activity_time)}
                        </T>
                      </View>
                      <ProgressBar value={totalMin ? a.duration_min / totalMin : 0} color={c[meta.color] as string} height={6} />
                    </View>
                  );
                })}
              </View>
            )}
          </Card>
        </Col>
      </Grid>

      <Card anim="rise" delay={4}>
        <CardHeader title="Danh sách bài vận động" subtitle={`${list.length} bài tập`} icon="barbell" iconColor="info" />
        {activities.isLoading ? (
          <SkeletonList rows={3} height={64} />
        ) : list.length === 0 ? (
          <EmptyState icon="walk-outline" title="Chưa có bài vận động" description="Thêm lịch đi bộ, yoga, đạp xe... để người thân được nhắc mỗi ngày." action={member ? <Button label="Thêm bài vận động" icon="add" onPress={() => { setEditing(null); setFormOpen(true); }} /> : undefined} />
        ) : (
          <Grid gap={12}>
            {list.map((a) => {
              const meta = ACTIVITY_TYPE_META[a.activity_type] ?? ACTIVITY_TYPE_META.other;
              return (
                <View key={a.id} style={{ flexBasis: 300, flexGrow: 1, flexDirection: 'row', gap: 12, alignItems: 'center', padding: 14, borderRadius: 16, borderWidth: 1, borderColor: c.border, opacity: a.enabled ? 1 : 0.55 }}>
                  <View style={{ width: 46, height: 46, borderRadius: 14, alignItems: 'center', justifyContent: 'center', backgroundColor: c[meta.soft] as string }}>
                    <Icon name={meta.icon} size={22} color={meta.color} />
                  </View>
                  <View style={{ flex: 1, minWidth: 0 }}>
                    <T variant="bodyStrong" numberOfLines={1}>
                      {a.name}
                    </T>
                    <T variant="caption" color="textMuted">
                      {shortTime(a.activity_time)} · {a.duration_min} phút · {weekdaysLabel(a.repeat_days)}
                    </T>
                  </View>
                  <Switch size="sm" value={a.enabled} onChange={() => toggle.mutate(a)} label="Bật/tắt" />
                  <IconButton icon="create-outline" label="Sửa" size={32} onPress={() => { setEditing(a); setFormOpen(true); }} />
                  <IconButton icon="trash-outline" label="Xóa" size={32} color={c.danger} onPress={async () => { if (await confirm({ title: 'Xóa bài vận động?', message: a.name, confirmLabel: 'Xóa' })) remove.mutate(a.id); }} />
                </View>
              );
            })}
          </Grid>
        )}
      </Card>

      <ActivityForm visible={formOpen} onClose={() => setFormOpen(false)} editing={editing} memberUid={member} />
      <MetricsForm visible={metricsOpen} onClose={() => setMetricsOpen(false)} metrics={m} memberUid={member} date={date} />
    </Page>
  );
}

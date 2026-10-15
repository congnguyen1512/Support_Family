import React, { useEffect, useMemo, useState } from 'react';
import { View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import {
  Badge,
  BarChart,
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
  Segmented,
  SkeletonList,
  T,
  TextField,
} from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { Col, Grid, Page } from '../../components/layout/Page';
import { healthApi } from '../../api/endpoints';
import { useApiMutation, useFamilyMembers, useHealthLogs, useHealthReport } from '../../api/hooks';
import { usePageShortcuts } from '../../hooks/usePageShortcuts';
import { formatDateTime, toISODate } from '../../utils/format';
import { HEALTH_CATEGORY_META, HEALTH_STATUS_META } from '../../utils/constants';
import type { HealthCategory, HealthLogInput, HealthStatus } from '../../api/types';

type Period = 'today' | 'week' | 'month';
type StatusFilter = 'all' | HealthStatus;

const pad = (n: number) => String(n).padStart(2, '0');
const nowLocal = () => {
  const d = new Date();
  return `${toISODate(d)}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
};

function LogForm({ visible, onClose, memberUid }: { visible: boolean; onClose: () => void; memberUid?: string }) {
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState<HealthCategory>('medicine');
  const [status, setStatus] = useState<HealthStatus>('completed');
  const [detail, setDetail] = useState('');
  const [at, setAt] = useState(nowLocal());
  useEffect(() => {
    if (visible) {
      setTitle('');
      setCategory('medicine');
      setStatus('completed');
      setDetail('');
      setAt(nowLocal());
    }
  }, [visible]);
  const save = useApiMutation((b: HealthLogInput) => healthApi.createLog(b), { invalidate: [['healthLogs'], ['healthReport']], success: 'Đã ghi nhật ký sức khỏe', onSuccess: onClose });
  return (
    <Modal
      visible={visible}
      onClose={onClose}
      title="Ghi nhật ký sức khỏe"
      subtitle="Ghi lại việc uống thuốc, đo chỉ số, khám bệnh..."
      icon="pulse"
      width={600}
      footer={
        <>
          <Button label="Hủy" variant="secondary" onPress={onClose} />
          <Button
            nativeID="health-log-save"
            label="Lưu nhật ký"
            icon="checkmark"
            disabled={!title.trim()}
            loading={save.isPending}
            onPress={() => {
              const scheduled = new Date(at).toISOString();
              save.mutate({ member_uid: memberUid, title: title.trim(), category, status, detail: detail.trim(), scheduled_at: scheduled, completed_at: status === 'completed' || status === 'late' ? new Date().toISOString() : null });
            }}
          />
        </>
      }
    >
      <Field label="Hạng mục">
        <ChoiceCards
          columns={5}
          value={category}
          onChange={setCategory}
          options={(Object.keys(HEALTH_CATEGORY_META) as HealthCategory[]).map((k) => ({ value: k, label: HEALTH_CATEGORY_META[k].label, icon: HEALTH_CATEGORY_META[k].icon }))}
        />
      </Field>
      <Field label="Nội dung" required>
        <TextField nativeID="health-log-title" value={title} onChangeText={setTitle} placeholder="vd: Uống thuốc huyết áp buổi sáng" autoFocus />
      </Field>
      <View style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap' }}>
        <Field label="Thời điểm" style={{ flex: 1, minWidth: 220 }}>
          <DateField id="health-log-time" type="datetime-local" value={at} onChange={setAt} />
        </Field>
        <Field label="Kết quả" style={{ flex: 1, minWidth: 260 }}>
          <Segmented<HealthStatus>
            value={status}
            onChange={setStatus}
            options={(Object.keys(HEALTH_STATUS_META) as HealthStatus[]).map((k) => ({ value: k, label: HEALTH_STATUS_META[k].label }))}
          />
        </Field>
      </View>
      <Field label="Chi tiết" hint="vd: Huyết áp 125/80, đường huyết 6.1 mmol/L">
        <TextField nativeID="health-log-detail" value={detail} onChangeText={setDetail} multiline placeholder="Ghi chú thêm" />
      </Field>
    </Modal>
  );
}

export default function HealthScreen() {
  const c = useTheme();
  const { members } = useFamilyMembers();
  const [member, setMember] = useState<string | undefined>();
  const [period, setPeriod] = useState<Period>('week');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [formOpen, setFormOpen] = useState(false);

  useEffect(() => {
    if (!member && members[0]) setMember(members[0].uid);
  }, [members, member]);
  const { memberParam } = usePageShortcuts({ onNew: (m) => { if (m) setMember(m); setFormOpen(true); } });
  useEffect(() => {
    if (memberParam) setMember(memberParam);
  }, [memberParam]);

  const report = useHealthReport(member, period);
  const logs = useHealthLogs(member);
  const remove = useApiMutation((id: number) => healthApi.removeLog(id), { invalidate: [['healthLogs'], ['healthReport']], success: 'Đã xóa nhật ký' });

  const r = report.data;
  const allLogs = logs.data ?? [];
  const filteredLogs = allLogs.filter((l) => statusFilter === 'all' || l.status === statusFilter);

  const chart = useMemo(() => {
    const days = Array.from({ length: 7 }).map((_, i) => {
      const d = new Date();
      d.setDate(d.getDate() - (6 - i));
      return d;
    });
    return days.map((d) => {
      const key = toISODate(d);
      const dayLogs = allLogs.filter((l) => toISODate(new Date(l.scheduled_at)) === key);
      const ok = dayLogs.filter((l) => l.status === 'completed' || l.status === 'late').length;
      return {
        label: d.toLocaleDateString('vi-VN', { weekday: 'short' }).replace('Th ', 'T'),
        value: dayLogs.length ? Math.round((ok / dayLogs.length) * 100) : 0,
        color: dayLogs.length && ok / dayLogs.length < 0.7 ? c.warning : undefined,
      };
    });
  }, [allLogs, c.warning]);

  const rate = (r?.completion_rate ?? 0) / 100;
  const rateColor = rate >= 0.9 ? c.success : rate >= 0.7 ? c.warning : c.danger;

  return (
    <Page
      title="Báo cáo sức khỏe"
      subtitle="Mức độ tuân thủ lịch uống thuốc, sinh hoạt và nhật ký sức khỏe"
      actions={<Button nativeID="health-new" label="Ghi nhật ký" icon="add" hint="N" disabled={!member} onPress={() => setFormOpen(true)} />}
    >
      <Card padding={16} anim="rise" style={{ flexDirection: 'row', gap: 12, flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between' }}>
        <View style={{ flex: 1, minWidth: 260 }}>
          <MemberChips members={members} value={member} onChange={(v) => v && setMember(v)} />
        </View>
        <Segmented<Period>
          value={period}
          onChange={setPeriod}
          options={[
            { value: 'today', label: 'Hôm nay' },
            { value: 'week', label: '7 ngày' },
            { value: 'month', label: '30 ngày' },
          ]}
        />
      </Card>

      {!member ? (
        <Card>
          <EmptyState icon="pulse-outline" title="Chưa có thành viên" description="Mời người thân để xem báo cáo sức khỏe." />
        </Card>
      ) : (
        <>
          <Grid>
            <Col minWidth={300}>
              <Card anim="rise" delay={1} style={{ flex: 1, alignItems: 'center', gap: 14 }}>
                <CardHeader title="Tỷ lệ hoàn thành" icon="checkmark-done-circle" iconColor="success" style={{ alignSelf: 'stretch' }} />
                {report.isLoading ? (
                  <SkeletonList rows={1} height={170} />
                ) : (
                  <>
                    <ProgressRing value={rate} size={180} stroke={16} color={rateColor}>
                      <T variant="hero" style={{ color: rateColor }}>
                        {r?.completion_rate ?? 0}%
                      </T>
                      <T variant="caption" color="textMuted">
                        {r?.total_reminders ?? 0} lượt nhắc
                      </T>
                    </ProgressRing>
                    <Badge
                      label={rate >= 0.9 ? 'Tuân thủ rất tốt' : rate >= 0.7 ? 'Cần nhắc nhở thêm' : 'Cần quan tâm'}
                      color={rate >= 0.9 ? 'success' : rate >= 0.7 ? 'warning' : 'danger'}
                      icon={rate >= 0.9 ? 'happy-outline' : 'alert-circle-outline'}
                    />
                    {allLogs.length === 0 ? (
                      <T variant="caption" color="textMuted" align="center">
                        Chưa có nhật ký — số liệu đang là ước tính mặc định từ hệ thống.
                      </T>
                    ) : null}
                  </>
                )}
              </Card>
            </Col>
            <Col minWidth={300}>
              <Card anim="rise" delay={2} style={{ flex: 1, gap: 18 }}>
                <CardHeader title="Phân loại" icon="pie-chart" iconColor="info" style={{ marginBottom: 0 }} />
                {[
                  { label: 'Đúng giờ', value: r?.on_time_rate ?? 0, color: c.success, icon: 'checkmark-circle' },
                  { label: 'Trễ giờ', value: r?.late_rate ?? 0, color: c.warning, icon: 'time' },
                  { label: 'Bỏ lỡ', value: r?.missed_rate ?? 0, color: c.danger, icon: 'close-circle' },
                ].map((x) => (
                  <View key={x.label} style={{ gap: 8 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                      <Icon name={x.icon} size={18} color={x.color} />
                      <T variant="bodyStrong" style={{ flex: 1 }}>
                        {x.label}
                      </T>
                      <T variant="h3">{x.value}%</T>
                    </View>
                    <ProgressBar value={x.value / 100} color={x.color} height={10} />
                  </View>
                ))}
              </Card>
            </Col>
            <Col flex={1.4} minWidth={360}>
              <Card anim="rise" delay={3} style={{ flex: 1 }}>
                <CardHeader title="Tuân thủ 7 ngày gần nhất" subtitle="% hoàn thành theo ngày (từ nhật ký)" icon="bar-chart" />
                {logs.isLoading ? <SkeletonList rows={1} height={180} /> : <BarChart data={chart} height={170} highlightLast formatValue={(v) => `${v}%`} />}
              </Card>
            </Col>
          </Grid>

          <Card anim="rise" delay={4}>
            <CardHeader
              title="Nhật ký sức khỏe"
              subtitle={`${allLogs.length} bản ghi`}
              icon="document-text"
              iconColor="accent"
              right={
                <Segmented<StatusFilter>
                  size="sm"
                  value={statusFilter}
                  onChange={setStatusFilter}
                  options={[{ value: 'all', label: 'Tất cả' }, ...(Object.keys(HEALTH_STATUS_META) as HealthStatus[]).map((k) => ({ value: k, label: HEALTH_STATUS_META[k].label, count: allLogs.filter((l) => l.status === k).length }))]}
                />
              }
            />
            {logs.isLoading ? (
              <SkeletonList rows={4} height={56} />
            ) : filteredLogs.length === 0 ? (
              <EmptyState compact icon="document-text-outline" title="Chưa có nhật ký" action={<Button label="Ghi nhật ký" icon="add" size="sm" onPress={() => setFormOpen(true)} />} />
            ) : (
              <View>
                {filteredLogs.map((l, i) => {
                  const cat = HEALTH_CATEGORY_META[l.category] ?? HEALTH_CATEGORY_META.other;
                  const st = HEALTH_STATUS_META[l.status] ?? HEALTH_STATUS_META.pending;
                  return (
                    <View key={l.id} style={{ flexDirection: 'row', gap: 12, alignItems: 'center', paddingVertical: 12, borderTopWidth: i ? 1 : 0, borderTopColor: c.border }}>
                      <View style={{ width: 40, height: 40, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: c[st.soft] as string }}>
                        <Icon name={cat.icon} size={18} color={st.color} />
                      </View>
                      <View style={{ flex: 1, minWidth: 0 }}>
                        <T variant="bodyStrong" numberOfLines={1}>
                          {l.title}
                        </T>
                        <T variant="caption" color="textMuted" numberOfLines={1}>
                          {cat.label} · {formatDateTime(l.scheduled_at)}
                          {l.detail ? ` · ${l.detail}` : ''}
                        </T>
                      </View>
                      <Badge label={st.label} color={st.color} size="sm" dot />
                      <IconButton icon="trash-outline" label="Xóa" size={32} color={c.danger} onPress={async () => { if (await confirm({ title: 'Xóa nhật ký?', message: l.title, confirmLabel: 'Xóa' })) remove.mutate(l.id); }} />
                    </View>
                  );
                })}
              </View>
            )}
          </Card>
        </>
      )}

      <LogForm visible={formOpen} onClose={() => setFormOpen(false)} memberUid={member} />
    </Page>
  );
}

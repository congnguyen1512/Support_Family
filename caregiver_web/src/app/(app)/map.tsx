import React, { useEffect, useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { shadow, transition, web, type WebPressState } from '../../theme/web';
import {
  Avatar,
  Badge,
  Button,
  DateField,
  Divider,
  EmptyState,
  Icon,
  IconButton,
  RangeField,
  SearchInput,
  Segmented,
  SkeletonList,
  StatusDot,
  Switch,
  T,
} from '../../components/ui';
import { LazyFamilyMap } from '../../components/map/LazyMap';
import { presenceColor, presenceLabel } from '../../components/map/presence';
import { useFamilyMembers, useLocationHistory, useSafeZones } from '../../api/hooks';
import { useBreakpoint } from '../../hooks/common';
import { formatDistance, formatTime, haversineMeters, normalizeSearch, relativeTime, toISODate } from '../../utils/format';
import { MEMBER_KIND_META } from '../../utils/constants';

type Mode = 'live' | 'history';

export default function MapScreen() {
  const c = useTheme();
  const router = useRouter();
  const params = useLocalSearchParams<{ uid?: string }>();
  const { isMobile } = useBreakpoint();
  const { members, isLoading, refetch, isFetching } = useFamilyMembers();
  const zones = useSafeZones();
  const [selected, setSelected] = useState<string | null>(params.uid ?? null);
  const [query, setQuery] = useState('');
  const [mode, setMode] = useState<Mode>('live');
  const [showZones, setShowZones] = useState(true);
  const [date, setDate] = useState(toISODate());
  const [playhead, setPlayhead] = useState(0);
  const [playing, setPlaying] = useState(false);
  const [speed, setSpeed] = useState<'1' | '2' | '4'>('2');

  useEffect(() => {
    if (params.uid) setSelected(params.uid);
  }, [params.uid]);

  const member = members.find((m) => m.uid === selected) ?? null;
  const filtered = useMemo(() => {
    const q = normalizeSearch(query);
    return members.filter((m) => !q || normalizeSearch(`${m.name} ${m.relation} ${m.location?.address ?? ''}`).includes(q));
  }, [members, query]);

  const from = useMemo(() => new Date(`${date}T00:00:00`).toISOString(), [date]);
  const to = useMemo(() => new Date(`${date}T23:59:59`).toISOString(), [date]);
  const history = useLocationHistory(mode === 'history' ? selected ?? undefined : undefined, from, to);
  const route = mode === 'history' ? history.data ?? [] : [];

  useEffect(() => {
    setPlayhead(route.length ? route.length - 1 : 0);
    setPlaying(false);
  }, [route.length, selected, date]);

  useEffect(() => {
    if (!playing || route.length < 2) return;
    const t = setInterval(() => {
      setPlayhead((p) => {
        if (p >= route.length - 1) {
          setPlaying(false);
          return p;
        }
        return Math.min(route.length - 1, p + Number(speed));
      });
    }, 160);
    return () => clearInterval(t);
  }, [playing, route.length, speed]);

  const stats = useMemo(() => {
    if (route.length < 2) return { distance: 0, duration: 0 };
    let d = 0;
    for (let i = 1; i < route.length; i++) d += haversineMeters(route[i - 1].latitude, route[i - 1].longitude, route[i].latitude, route[i].longitude);
    const duration = (new Date(route[route.length - 1].created_at).getTime() - new Date(route[0].created_at).getTime()) / 60000;
    return { distance: d, duration };
  }, [route]);

  const current = route[playhead];
  const memberZones = (zones.data ?? []).filter((z) => (member ? z.target_uid === member.uid : true));
  const loc = member?.location;

  const panel = (
    <View style={[styles.panel, { backgroundColor: c.surface, borderColor: c.border, width: isMobile ? '100%' : 360 }, isMobile ? { maxHeight: 360 } : null]}>
      <View style={{ padding: 14, gap: 10 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
          <T variant="h3" style={{ flex: 1 }}>
            Thành viên ({members.length})
          </T>
          <IconButton icon="refresh" label="Làm mới vị trí" variant="secondary" onPress={refetch} />
        </View>
        <SearchInput nativeID="map-search" value={query} onChangeText={setQuery} placeholder="Tìm theo tên, địa chỉ..." />
      </View>
      <Divider />
      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ padding: 8, gap: 2 }}>
        {isLoading ? (
          <SkeletonList rows={5} />
        ) : filtered.length === 0 ? (
          <EmptyState compact icon="people-outline" title="Không tìm thấy thành viên" />
        ) : (
          filtered.map((m) => {
            const active = m.uid === selected;
            const status = presenceColor(m.location?.updated_at);
            return (
              <Pressable
                key={m.uid}
                nativeID={`map-member-${m.uid}`}
                onPress={() => setSelected(active ? null : m.uid)}
                style={(state) => {
                  const { hovered } = state as WebPressState;
                  return [
                    styles.memberItem,
                    { backgroundColor: active ? c.primarySoft : hovered ? c.surfaceHover : 'transparent', borderColor: active ? c.primary : 'transparent' },
                    transition('background-color, border-color', 140),
                    web({ cursor: 'pointer' }),
                  ];
                }}
              >
                <Avatar name={m.name} uri={m.avatar} size={40} status={status} />
                <View style={{ flex: 1, minWidth: 0 }}>
                  <T variant="bodyStrong" numberOfLines={1}>
                    {m.name}
                  </T>
                  <T variant="caption" color="textMuted" numberOfLines={1}>
                    {m.location?.place_name || m.location?.address || presenceLabel(m.location?.updated_at)}
                  </T>
                </View>
                <T variant="caption" color="textMuted">
                  {m.location?.updated_at ? relativeTime(m.location.updated_at) : ''}
                </T>
              </Pressable>
            );
          })
        )}
      </ScrollView>
      <View style={[styles.legend, { borderTopColor: c.border }]}>
        {[
          ['#12B76A', '≤ 10 phút'],
          ['#F59E0B', '≤ 1 giờ'],
          ['#94A3B8', 'Ngoại tuyến'],
        ].map(([color, label]) => (
          <View key={label} style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
            <StatusDot color={color} size={8} />
            <T variant="caption" color="textMuted">
              {label}
            </T>
          </View>
        ))}
      </View>
    </View>
  );

  return (
    <View style={[styles.root, { flexDirection: isMobile ? 'column' : 'row', padding: isMobile ? 12 : 20 }]}>
      {panel}

      <View style={[styles.mapWrap, { borderColor: c.border, backgroundColor: c.surfaceAlt }, shadow(2, c.shadow)]}>
        <LazyFamilyMap
          members={mode === 'history' && member ? [member] : members}
          safeZones={showZones ? memberZones : []}
          selectedUid={selected}
          onSelectMember={setSelected}
          route={route}
          playheadIndex={mode === 'history' ? playhead : undefined}
          focus={mode === 'live' && loc?.latitude != null ? [loc.latitude, loc.longitude!] : null}
          fitKey={mode === 'history' ? `h-${selected}-${date}-${route.length}` : undefined}
        />

        {/* Thanh điều khiển nổi */}
        <View style={[styles.topControls, { pointerEvents: 'box-none' } as object]}>
          <View style={[styles.floating, { backgroundColor: c.elevated, borderColor: c.border }, shadow(3, c.shadow)]}>
            <Segmented<Mode>
              size="sm"
              value={mode}
              onChange={(v) => {
                if (v === 'history' && !selected && members[0]) setSelected(members[0].uid);
                setMode(v);
              }}
              options={[
                { value: 'live', label: 'Trực tiếp', icon: 'radio-outline' },
                { value: 'history', label: 'Lộ trình', icon: 'git-commit-outline' },
              ]}
            />
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, paddingHorizontal: 6 }}>
              <Switch size="sm" value={showZones} onChange={setShowZones} label="Hiện vùng an toàn" />
              <T variant="caption" color="textSoft">
                Vùng an toàn
              </T>
            </View>
            {isFetching ? <Badge label="Đang đồng bộ" color="info" size="sm" dot /> : <Badge label="Tự làm mới 15s" color="success" size="sm" dot />}
          </View>
        </View>

        {member ? (
          <View dataSet={{ anim: 'rise' }} style={[styles.detail, { backgroundColor: c.elevated, borderColor: c.border, width: isMobile ? undefined : 380, left: isMobile ? 12 : undefined }, shadow(4, c.shadow)]}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
              <Avatar name={member.name} uri={member.avatar} size={48} status={presenceColor(loc?.updated_at)} />
              <View style={{ flex: 1, minWidth: 0 }}>
                <T variant="h3" numberOfLines={1}>
                  {member.name}
                </T>
                <View style={{ flexDirection: 'row', gap: 6, marginTop: 2 }}>
                  <Badge label={member.relation} color={MEMBER_KIND_META[member.kind].color} size="sm" />
                  <Badge label={presenceLabel(loc?.updated_at)} color={presenceColor(loc?.updated_at) === '#12B76A' ? 'success' : 'textMuted'} size="sm" dot />
                </View>
              </View>
              <IconButton icon="close" label="Bỏ chọn" onPress={() => setSelected(null)} />
            </View>

            {mode === 'live' ? (
              <View style={{ gap: 8 }}>
                <InfoLine icon="location-outline" text={loc?.address || loc?.place_name || 'Chưa có địa chỉ'} />
                <View style={{ flexDirection: 'row', gap: 16, flexWrap: 'wrap' }}>
                  <InfoLine icon="time-outline" text={loc?.updated_at ? `${formatTime(loc.updated_at)} · ${relativeTime(loc.updated_at)}` : '—'} />
                  {loc?.accuracy != null ? <InfoLine icon="locate-outline" text={`± ${Math.round(loc.accuracy)} m`} /> : null}
                  {loc?.speed != null ? <InfoLine icon="speedometer-outline" text={`${(loc.speed * 3.6).toFixed(1)} km/h`} /> : null}
                </View>
                {loc?.latitude != null ? (
                  <T variant="mono" color="textMuted" style={{ fontSize: 12.5 }}>
                    {loc.latitude.toFixed(6)}, {loc.longitude?.toFixed(6)}
                  </T>
                ) : null}
              </View>
            ) : (
              <View style={{ gap: 10 }}>
                <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center' }}>
                  <View style={{ flex: 1 }}>
                    <DateField id="map-history-date" value={date} max={toISODate()} onChange={(v) => v && setDate(v)} />
                  </View>
                  <IconButton icon="chevron-back" label="Ngày trước" variant="secondary" onPress={() => { const d = new Date(`${date}T00:00:00`); d.setDate(d.getDate() - 1); setDate(toISODate(d)); }} />
                  <IconButton icon="chevron-forward" label="Ngày sau" variant="secondary" onPress={() => { const d = new Date(`${date}T00:00:00`); d.setDate(d.getDate() + 1); if (d <= new Date()) setDate(toISODate(d)); }} />
                </View>
                {history.isLoading ? (
                  <SkeletonList rows={2} height={36} />
                ) : route.length === 0 ? (
                  <T variant="small" color="textMuted">
                    Không có dữ liệu di chuyển trong ngày này.
                  </T>
                ) : (
                  <>
                    <View style={{ flexDirection: 'row', gap: 8 }}>
                      <MiniStat label="Quãng đường" value={formatDistance(stats.distance)} />
                      <MiniStat label="Thời gian" value={`${Math.floor(stats.duration / 60)}g ${Math.round(stats.duration % 60)}p`} />
                      <MiniStat label="Điểm" value={String(route.length)} />
                    </View>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                      <IconButton icon={playing ? 'pause' : 'play'} label={playing ? 'Tạm dừng' : 'Phát lại'} variant="soft" onPress={() => { if (!playing && playhead >= route.length - 1) setPlayhead(0); setPlaying((v) => !v); }} />
                      <View style={{ flex: 1 }}>
                        <RangeField value={playhead} min={0} max={Math.max(0, route.length - 1)} onChange={(v) => { setPlaying(false); setPlayhead(v); }} />
                      </View>
                      <Segmented<'1' | '2' | '4'> size="sm" value={speed} onChange={setSpeed} options={[{ value: '1', label: '1x' }, { value: '2', label: '2x' }, { value: '4', label: '4x' }]} />
                    </View>
                    {current ? (
                      <T variant="caption" color="textMuted" numberOfLines={2}>
                        {formatTime(current.created_at)} · {current.place_name || current.address || `${current.latitude.toFixed(5)}, ${current.longitude.toFixed(5)}`}
                      </T>
                    ) : null}
                  </>
                )}
              </View>
            )}

            <View style={{ flexDirection: 'row', gap: 8, flexWrap: 'wrap' }}>
              <Button nativeID="map-message" label="Nhắn tin" icon="chatbubble-ellipses-outline" size="sm" variant="secondary" onPress={() => router.push(`/messages?peer=${member.uid}` as any)} />
              {member.phone ? <Button nativeID="map-call" label="Gọi" icon="call-outline" size="sm" variant="secondary" onPress={() => window.open(`tel:${member.phone}`)} /> : null}
              {loc?.latitude != null ? (
                <Button nativeID="map-directions" label="Chỉ đường" icon="navigate-outline" size="sm" variant="secondary" onPress={() => window.open(`https://www.google.com/maps/dir/?api=1&destination=${loc.latitude},${loc.longitude}`, '_blank')} />
              ) : null}
              {mode === 'live' ? <Button nativeID="map-history" label="Xem lộ trình" icon="git-commit-outline" size="sm" variant="soft" onPress={() => setMode('history')} /> : null}
            </View>
          </View>
        ) : null}
      </View>
    </View>
  );
}

function InfoLine({ icon, text }: { icon: string; text: string }) {
  return (
    <View style={{ flexDirection: 'row', gap: 6, alignItems: 'flex-start', flexShrink: 1 }}>
      <Icon name={icon} size={14} color="textMuted" style={{ marginTop: 2 }} />
      <T variant="small" color="textSoft" style={{ flexShrink: 1 }}>
        {text}
      </T>
    </View>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  const c = useTheme();
  return (
    <View style={{ flex: 1, padding: 10, borderRadius: 12, backgroundColor: c.surfaceAlt, gap: 2 }}>
      <T variant="caption" color="textMuted">
        {label}
      </T>
      <T variant="bodyStrong">{value}</T>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, gap: 16 },
  panel: { borderRadius: 20, borderWidth: 1, overflow: 'hidden' },
  memberItem: { flexDirection: 'row', alignItems: 'center', gap: 10, padding: 8, borderRadius: 12, borderWidth: 1 },
  legend: { flexDirection: 'row', justifyContent: 'space-around', paddingVertical: 10, borderTopWidth: 1 },
  mapWrap: { flex: 1, minHeight: 420, borderRadius: 20, borderWidth: 1, overflow: 'hidden', position: 'relative' },
  topControls: { position: 'absolute', top: 12, left: 56, right: 12, flexDirection: 'row', zIndex: 500 },
  floating: { flexDirection: 'row', alignItems: 'center', gap: 8, padding: 6, borderRadius: 14, borderWidth: 1, flexWrap: 'wrap' },
  detail: { position: 'absolute', right: 12, bottom: 12, zIndex: 500, padding: 16, borderRadius: 20, borderWidth: 1, gap: 12 },
});

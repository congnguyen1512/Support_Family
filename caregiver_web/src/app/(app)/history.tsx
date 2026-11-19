import React, { useEffect, useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { gradient, shadow, transition, web, type WebPressState } from '../../theme/web';
import {
  Avatar,
  Badge,
  Button,
  Card,
  CardHeader,
  DateField,
  Divider,
  EmptyState,
  Field,
  Icon,
  IconButton,
  Loader,
  MemberChips,
  Modal,
  RangeField,
  SearchInput,
  Segmented,
  SkeletonList,
  StatusDot,
  T,
} from '../../components/ui';
import { Page } from '../../components/layout/Page';
import { LazyFamilyMap } from '../../components/map/LazyMap';
import { useFamilyMembers, useLocationHistory, useSafeZoneEvents, useSafeZones } from '../../api/hooks';
import { useBreakpoint } from '../../hooks/common';
import {
  formatDate,
  formatDateTime,
  formatDistance,
  formatDurationSeconds,
  formatTime,
  haversineMeters,
  normalizeSearch,
  toISODate,
} from '../../utils/format';
import type { SafeZone, SafeZoneEvent } from '../../api/types';

type HistoryMode = 'events' | 'route';
type EventFilter = 'all' | 'enter' | 'leave';

interface TimelineGroup {
  dayLabel: string;
  isToday: boolean;
  isYesterday: boolean;
  events: SafeZoneEvent[];
}

export default function HistoryScreen() {
  const c = useTheme();
  const router = useRouter();
  const params = useLocalSearchParams<{ uid?: string; mode?: string }>();
  const { isMobile, isDesktop } = useBreakpoint();

  const { members, isLoading: membersLoading } = useFamilyMembers();
  const zonesQuery = useSafeZones();
  const allZones = zonesQuery.data ?? [];

  // ── States ────────────────────────────────────────────────────────
  const [selectedMemberId, setSelectedMemberId] = useState<string | null>(params.uid ?? null);
  const [mode, setMode] = useState<HistoryMode>((params.mode as HistoryMode) === 'route' ? 'route' : 'events');

  // Month selector for safe zone events
  const now = new Date();
  const [selectedMonth, setSelectedMonth] = useState(now.getMonth() + 1);
  const [selectedYear, setSelectedYear] = useState(now.getFullYear());
  const [showMonthPicker, setShowMonthPicker] = useState(false);

  // Filters for events
  const [filter, setFilter] = useState<EventFilter>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedEventId, setSelectedEventId] = useState<number | null>(null);

  // States for Route GPS playback
  const [routeDate, setRouteDate] = useState(toISODate());
  const [playhead, setPlayhead] = useState(0);
  const [playing, setPlaying] = useState(false);
  const [playSpeed, setPlaySpeed] = useState<'1' | '2' | '4'>('2');

  // Auto select initial member (care recipients first)
  useEffect(() => {
    if (params.uid) {
      setSelectedMemberId(params.uid);
      return;
    }
    if (!selectedMemberId && members.length > 0) {
      const sorted = [...members].sort((a, b) => {
        const aCare = a.kind === 'child' || a.kind === 'senior' ? 0 : 1;
        const bCare = b.kind === 'child' || b.kind === 'senior' ? 0 : 1;
        return aCare - bCare;
      });
      setSelectedMemberId(sorted[0].uid);
    }
  }, [members, params.uid, selectedMemberId]);

  const currentMember = members.find((m) => m.uid === selectedMemberId) ?? null;

  // ── Safe Zone Events Data ─────────────────────────────────────────
  const fromIso = useMemo(() => {
    return new Date(Date.UTC(selectedYear, selectedMonth - 1, 1, 0, 0, 0)).toISOString();
  }, [selectedYear, selectedMonth]);

  const toIso = useMemo(() => {
    // next month UTC
    return new Date(Date.UTC(selectedYear, selectedMonth, 1, 0, 0, 0)).toISOString();
  }, [selectedYear, selectedMonth]);

  const eventsQuery = useSafeZoneEvents(selectedMemberId ?? undefined, fromIso, toIso);
  const rawEvents = eventsQuery.data ?? [];

  // Filtered events
  const filteredEvents = useMemo(() => {
    const q = normalizeSearch(searchQuery);
    return rawEvents
      .filter((e) => {
        if (filter === 'enter' && e.event_type !== 'enter') return false;
        if (filter === 'leave' && e.event_type !== 'leave') return false;
        if (q) {
          const hay = normalizeSearch(`${e.zone_name} ${e.address ?? ''}`);
          if (!hay.includes(q)) return false;
        }
        return true;
      })
      .sort((a, b) => new Date(b.occurred_at).getTime() - new Date(a.occurred_at).getTime());
  }, [rawEvents, filter, searchQuery]);

  // Counts for tabs
  const enterCount = useMemo(() => rawEvents.filter((e) => e.event_type === 'enter').length, [rawEvents]);
  const leaveCount = useMemo(() => rawEvents.filter((e) => e.event_type === 'leave').length, [rawEvents]);

  // Selected event
  useEffect(() => {
    if (filteredEvents.length > 0) {
      if (!selectedEventId || !filteredEvents.some((e) => e.id === selectedEventId)) {
        setSelectedEventId(filteredEvents[0].id);
      }
    } else {
      setSelectedEventId(null);
    }
  }, [filteredEvents, selectedEventId]);

  const activeEvent = useMemo(
    () => filteredEvents.find((e) => e.id === selectedEventId) ?? filteredEvents[0] ?? null,
    [filteredEvents, selectedEventId],
  );

  // Group events by day
  const timelineGroups = useMemo<TimelineGroup[]>(() => {
    const today = toISODate(now);
    const yesterdayDate = new Date();
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterday = toISODate(yesterdayDate);

    const map = new Map<string, SafeZoneEvent[]>();
    for (const e of filteredEvents) {
      const d = toISODate(new Date(e.occurred_at));
      if (!map.has(d)) map.set(d, []);
      map.get(d)!.push(e);
    }

    const groups: TimelineGroup[] = [];
    map.forEach((evts, dayStr) => {
      const isTod = dayStr === today;
      const isYest = dayStr === yesterday;
      const dateObj = new Date(`${dayStr}T00:00:00`);
      const dd = String(dateObj.getDate()).padStart(2, '0');
      const mm = String(dateObj.getMonth() + 1).padStart(2, '0');
      let label = `${dd}/${mm}/${dateObj.getFullYear()}`;
      if (isTod) label = `HÔM NAY · ${dd}/${mm}`;
      else if (isYest) label = `HÔM QUA · ${dd}/${mm}`;
      groups.push({ dayLabel: label, isToday: isTod, isYesterday: isYest, events: evts });
    });

    return groups;
  }, [filteredEvents]);

  // Safe zones for map display
  const memberZones = useMemo(() => {
    if (!selectedMemberId) return allZones;
    return allZones.filter((z) => z.target_uid === selectedMemberId);
  }, [allZones, selectedMemberId]);

  // Event pin for map
  const activeEventPin = useMemo(() => {
    if (!activeEvent || activeEvent.latitude == null || activeEvent.longitude == null) return null;
    return {
      lat: activeEvent.latitude,
      lng: activeEvent.longitude,
      label: `${activeEvent.event_type === 'enter' ? 'Vào' : 'Rời'}: ${activeEvent.zone_name}`,
      type: activeEvent.event_type,
    };
  }, [activeEvent]);

  // Target safe zone for active event
  const activeEventZones = useMemo<SafeZone[]>(() => {
    if (activeEvent?.zone_latitude != null && activeEvent?.zone_longitude != null && activeEvent?.zone_radius_meters != null) {
      return [
        {
          id: activeEvent.safe_zone_id ?? 999999,
          owner_uid: activeEvent.owner_uid ?? '',
          target_uid: activeEvent.member_uid,
          name: activeEvent.zone_name,
          center_latitude: activeEvent.zone_latitude,
          center_longitude: activeEvent.zone_longitude,
          radius_meters: activeEvent.zone_radius_meters,
          is_active: true,
          created_at: activeEvent.occurred_at,
          updated_at: activeEvent.occurred_at,
        },
      ];
    }
    return memberZones;
  }, [activeEvent, memberZones]);

  // ── GPS Route Data ────────────────────────────────────────────────
  const routeFrom = useMemo(() => new Date(`${routeDate}T00:00:00`).toISOString(), [routeDate]);
  const routeTo = useMemo(() => new Date(`${routeDate}T23:59:59`).toISOString(), [routeDate]);
  const routeQuery = useLocationHistory(mode === 'route' ? selectedMemberId ?? undefined : undefined, routeFrom, routeTo);
  const routePoints = mode === 'route' ? routeQuery.data ?? [] : [];

  useEffect(() => {
    setPlayhead(routePoints.length ? routePoints.length - 1 : 0);
    setPlaying(false);
  }, [routePoints.length, selectedMemberId, routeDate]);

  useEffect(() => {
    if (!playing || routePoints.length < 2) return;
    const t = setInterval(() => {
      setPlayhead((p) => {
        if (p >= routePoints.length - 1) {
          setPlaying(false);
          return p;
        }
        return Math.min(routePoints.length - 1, p + Number(playSpeed));
      });
    }, 180);
    return () => clearInterval(t);
  }, [playing, routePoints.length, playSpeed]);

  const routeStats = useMemo(() => {
    if (routePoints.length < 2) return { distance: 0, durationMinutes: 0, avgSpeed: 0 };
    let d = 0;
    for (let i = 1; i < routePoints.length; i++) {
      d += haversineMeters(routePoints[i - 1].latitude, routePoints[i - 1].longitude, routePoints[i].latitude, routePoints[i].longitude);
    }
    const t0 = new Date(routePoints[0].created_at).getTime();
    const tEnd = new Date(routePoints[routePoints.length - 1].created_at).getTime();
    const durationMinutes = Math.max(1, Math.round((tEnd - t0) / 60000));
    const avgSpeed = durationMinutes > 0 ? (d / 1000) / (durationMinutes / 60) : 0;
    return { distance: d, durationMinutes, avgSpeed };
  }, [routePoints]);

  const currentRoutePoint = routePoints[playhead];

  // Month navigation helpers
  const isCurrentMonth = selectedYear === now.getFullYear() && selectedMonth === now.getMonth() + 1;
  const prevMonth = () => {
    if (selectedMonth === 1) {
      setSelectedMonth(12);
      setSelectedYear((y) => y - 1);
    } else {
      setSelectedMonth((m) => m - 1);
    }
  };
  const nextMonth = () => {
    if (isCurrentMonth) return;
    if (selectedMonth === 12) {
      setSelectedMonth(1);
      setSelectedYear((y) => y + 1);
    } else {
      setSelectedMonth((m) => m + 1);
    }
  };
  const jumpCurrentMonth = () => {
    setSelectedMonth(now.getMonth() + 1);
    setSelectedYear(now.getFullYear());
  };

  return (
    <Page
      title="Lịch sử di chuyển"
      subtitle="Theo dõi nhật ký vào / rời vùng an toàn và lộ trình GPS chi tiết theo thời gian"
      actions={
        <View style={{ flexDirection: 'row', gap: 8, alignItems: 'center' }}>
          <Segmented
            value={mode}
            onChange={(v) => setMode(v as HistoryMode)}
            options={[
              { value: 'events', label: 'Vùng an toàn', icon: 'shield-checkmark-outline' },
              { value: 'route', label: 'Lộ trình GPS', icon: 'map-outline' },
            ]}
          />
          <Button
            label="Bản đồ trực tiếp"
            icon="navigate-outline"
            variant="secondary"
            onPress={() => router.push(selectedMemberId ? `/map?uid=${selectedMemberId}` : '/map')}
          />
        </View>
      }
    >
      {/* ── Member selector bar ────────────────────────────────────────── */}
      <Card style={{ padding: 14, gap: 10 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 10 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Icon name="people-outline" size={18} color="textMuted" />
            <T variant="bodyStrong">Chọn thành viên cần xem:</T>
          </View>
          {currentMember?.location?.address ? (
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6, flexShrink: 1 }}>
              <Icon name="location-outline" size={14} color="primary" />
              <T variant="caption" color="textMuted" numberOfLines={1} style={{ maxWidth: 360 }}>
                Hiện tại: {currentMember.location.address}
              </T>
            </View>
          ) : null}
        </View>
        <MemberChips
          members={members}
          value={selectedMemberId ?? undefined}
          onChange={(uid) => setSelectedMemberId(uid ?? null)}
        />
      </Card>

      {/* ── Mode 1: Safe Zone Events (Vào / Rời vùng) ─────────────────── */}
      {mode === 'events' ? (
        <View style={{ gap: 16 }}>
          {/* Controls bar: Month picker + Filter tabs + Search */}
          <Card style={{ padding: 14, gap: 12 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 12 }}>
              {/* Month selector */}
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                <IconButton
                  icon="chevron-back"
                  size={36}
                  variant="secondary"
                  label="Tháng trước"
                  onPress={prevMonth}
                />
                <Pressable
                  onPress={() => setShowMonthPicker(true)}
                  style={(state) => {
                    const { hovered } = state as WebPressState;
                    return [
                      styles.monthBtn,
                      { backgroundColor: hovered ? c.surfaceHover : c.surfaceAlt, borderColor: c.border },
                      web({ cursor: 'pointer' }),
                    ];
                  }}
                >
                  <Icon name="calendar-outline" size={17} color="primary" />
                  <T variant="bodyStrong" style={{ fontWeight: '700' }}>
                    Tháng {String(selectedMonth).padStart(2, '0')}, {selectedYear}
                  </T>
                  <Icon name="chevron-down" size={14} color="textMuted" />
                </Pressable>
                <IconButton
                  icon="chevron-forward"
                  size={36}
                  variant="secondary"
                  disabled={isCurrentMonth}
                  label="Tháng sau"
                  onPress={nextMonth}
                />
                {!isCurrentMonth ? (
                  <Button label="Hôm nay" size="sm" variant="ghost" onPress={jumpCurrentMonth} />
                ) : null}
              </View>

              {/* Filter tabs */}
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
                <Segmented
                  value={filter}
                  onChange={(v) => setFilter(v as EventFilter)}
                  options={[
                    { value: 'all', label: 'Tất cả', count: rawEvents.length },
                    { value: 'leave', label: 'Rời vùng', count: leaveCount },
                    { value: 'enter', label: 'Vào vùng', count: enterCount },
                  ]}
                />
                <IconButton
                  icon="refresh-outline"
                  size={36}
                  variant="secondary"
                  loading={eventsQuery.isFetching}
                  label="Tải lại sự kiện"
                  onPress={() => eventsQuery.refetch()}
                />
              </View>
            </View>

            {/* Search input */}
            <View style={{ maxWidth: 420 }}>
              <SearchInput
                placeholder="Tìm theo tên vùng hoặc địa chỉ..."
                value={searchQuery}
                onChangeText={setSearchQuery}
              />
            </View>
          </Card>

          {/* Main content: Split screen on Desktop, Stack on Mobile */}
          <View style={[styles.splitWrap, isDesktop ? { flexDirection: 'row' } : { flexDirection: 'column' }]}>
            {/* Left side: Timeline list */}
            <View style={{ flex: isDesktop ? 1.15 : undefined, gap: 14 }}>
              {eventsQuery.isLoading ? (
                <Card style={{ padding: 20 }}>
                  <SkeletonList rows={5} />
                </Card>
              ) : timelineGroups.length === 0 ? (
                <Card style={{ padding: 40 }}>
                  <EmptyState
                    icon="time-outline"
                    title={rawEvents.length === 0 ? 'Chưa có lượt vào / rời vùng nào' : 'Không có sự kiện phù hợp'}
                    description={
                      rawEvents.length === 0
                        ? `Trong tháng ${selectedMonth}/${selectedYear}, hệ thống chưa ghi nhận lượt vào hoặc rời vùng an toàn nào của ${currentMember?.name ?? 'thành viên'}.`
                        : 'Hãy thử chọn bộ lọc "Tất cả" hoặc xóa từ khóa tìm kiếm.'
                    }
                    action={
                      rawEvents.length === 0 ? (
                        <Button
                          label="Cài đặt vùng an toàn"
                          icon="shield-checkmark-outline"
                          variant="secondary"
                          onPress={() => router.push(selectedMemberId ? `/safe-zones?uid=${selectedMemberId}` : '/safe-zones')}
                        />
                      ) : undefined
                    }
                  />
                </Card>
              ) : (
                timelineGroups.map((group) => (
                  <View key={group.dayLabel} style={{ gap: 10 }}>
                    {/* Day badge */}
                    <View style={styles.dayHeader}>
                      <View style={[styles.dayBadge, { backgroundColor: group.isToday ? c.primary : c.surfaceAlt, borderColor: c.border }]}>
                        <Icon
                          name={group.isToday ? 'today' : 'calendar-outline'}
                          size={13}
                          color={group.isToday ? '#fff' : c.textMuted}
                        />
                        <T
                          variant="caption"
                          style={{
                            color: group.isToday ? '#fff' : c.textSoft,
                            fontWeight: '700',
                            letterSpacing: 0.5,
                          }}
                        >
                          {group.dayLabel}
                        </T>
                      </View>
                      <View style={[styles.dayLine, { backgroundColor: c.border }]} />
                    </View>

                    {/* Events of day */}
                    {group.events.map((e) => {
                      const isEnter = e.event_type === 'enter';
                      const isSelected = e.id === selectedEventId;
                      const tint = isEnter ? '#12B76A' : '#EF4444';
                      const tintSoft = isEnter ? c.successSoft : c.dangerSoft;

                      return (
                        <Pressable
                          key={e.id}
                          onPress={() => setSelectedEventId(e.id)}
                          style={(state) => {
                            const { hovered } = state as WebPressState;
                            return [
                              styles.eventCard,
                              {
                                backgroundColor: isSelected ? c.surfaceAlt : c.surface,
                                borderColor: isSelected ? tint : hovered ? c.borderStrong : c.border,
                              },
                              shadow(isSelected ? 3 : 1, c.shadow),
                              transition('border-color', 150),
                              web({ cursor: 'pointer' }),
                            ];
                          }}
                        >
                          <View style={{ flexDirection: 'row', gap: 14, alignItems: 'flex-start' }}>
                            {/* Icon pill */}
                            <View style={[styles.eventIconWrap, { backgroundColor: tintSoft }]}>
                              <Icon
                                name={isEnter ? 'arrow-down-circle' : 'arrow-up-circle'}
                                size={22}
                                color={tint}
                              />
                            </View>

                            {/* Details */}
                            <View style={{ flex: 1, gap: 5 }}>
                              <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 6 }}>
                                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                                  <T variant="h3" style={{ fontSize: 16.5 }}>
                                    {isEnter ? 'Vào vùng' : 'Rời vùng'}{' '}
                                    <T variant="h3" style={{ color: c.primary, fontSize: 16.5 }}>
                                      {e.zone_name}
                                    </T>
                                  </T>
                                  <Badge
                                    label={isEnter ? 'VÀO' : 'RỜI'}
                                    color={isEnter ? 'success' : 'danger'}
                                    size="sm"
                                  />
                                </View>
                                <T variant="caption" color="textMuted" style={{ fontWeight: '600', fontSize: 13 }}>
                                  {formatTime(e.occurred_at)}
                                </T>
                              </View>

                              {/* Duration / Status info */}
                              {isEnter ? (
                                e.is_ongoing ? (
                                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                                    <StatusDot color="#12B76A" pulse />
                                    <T variant="bodyStrong" style={{ color: '#12B76A', fontSize: 13.5 }}>
                                      Đang ở trong vùng ({formatDurationSeconds(e.stay_duration_seconds)})
                                    </T>
                                  </View>
                                ) : e.stay_duration_seconds != null ? (
                                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                                    <Icon name="hourglass-outline" size={14} color="textMuted" />
                                    <T variant="small" color="textSoft">
                                      Thời gian ở lại: <T variant="bodyStrong">{formatDurationSeconds(e.stay_duration_seconds)}</T>
                                    </T>
                                  </View>
                                ) : null
                              ) : (
                                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                                  <Icon name="exit-outline" size={14} color="danger" />
                                  <T variant="small" color="danger">
                                    Đã di chuyển ra ngoài ranh giới vùng
                                  </T>
                                </View>
                              )}

                              {/* Address / coordinate */}
                              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                                <Icon name="location-outline" size={14} color="textMuted" />
                                <T variant="caption" color="textMuted" numberOfLines={1} style={{ flex: 1 }}>
                                  {e.address ?? `${e.latitude?.toFixed(5) ?? 0}, ${e.longitude?.toFixed(5) ?? 0}`}
                                </T>
                                {e.distance_meters != null ? (
                                  <T variant="caption" color="textMuted" style={{ fontStyle: 'italic' }}>
                                    Cách tâm {Math.round(e.distance_meters)} m
                                  </T>
                                ) : null}
                              </View>
                            </View>

                            {/* View on map trigger */}
                            <IconButton
                              icon={isSelected ? 'radio-button-on' : 'chevron-forward'}
                              size={32}
                              variant={isSelected ? 'soft' : 'ghost'}
                              label="Xem chi tiết trên bản đồ"
                              onPress={() => setSelectedEventId(e.id)}
                            />
                          </View>
                        </Pressable>
                      );
                    })}
                  </View>
                ))
              )}
            </View>

            {/* Right side: Interactive Map Preview */}
            <View style={{ flex: isDesktop ? 1 : undefined, minHeight: 460 }}>
              <Card style={{ flex: 1, padding: 0, overflow: 'hidden', minHeight: 460, position: 'relative' }}>
                <LazyFamilyMap
                  members={members}
                  safeZones={activeEventZones}
                  selectedUid={selectedMemberId ?? undefined}
                  eventPin={activeEventPin}
                  focus={
                    activeEvent?.latitude != null && activeEvent?.longitude != null
                      ? [activeEvent.latitude, activeEvent.longitude]
                      : null
                  }
                  fitKey={`event-${activeEvent?.id ?? 'none'}`}
                  showZoneLabels
                />

                {/* Floating summary of inspected event at bottom */}
                {activeEvent ? (
                  <View style={[styles.mapOverlayCard, { backgroundColor: c.surface, borderColor: c.border }, shadow(3, c.shadow)]}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, flex: 1 }}>
                      <View
                        style={[
                          styles.eventIconWrap,
                          {
                            width: 38,
                            height: 38,
                            backgroundColor: activeEvent.event_type === 'enter' ? c.successSoft : c.dangerSoft,
                          },
                        ]}
                      >
                        <Icon
                          name={activeEvent.event_type === 'enter' ? 'arrow-down' : 'arrow-up'}
                          size={18}
                          color={activeEvent.event_type === 'enter' ? '#12B76A' : '#EF4444'}
                        />
                      </View>
                      <View style={{ flex: 1 }}>
                        <T variant="bodyStrong">
                          {activeEvent.event_type === 'enter' ? 'Vào' : 'Rời'}: {activeEvent.zone_name}
                        </T>
                        <T variant="caption" color="textMuted" numberOfLines={1}>
                          {formatDateTime(activeEvent.occurred_at)}
                          {activeEvent.stay_duration_seconds ? ` · Ở lại ${formatDurationSeconds(activeEvent.stay_duration_seconds)}` : ''}
                        </T>
                      </View>
                    </View>
                    <Button
                      label="Bản đồ lớn"
                      size="sm"
                      icon="open-outline"
                      variant="secondary"
                      onPress={() => router.push(`/map?uid=${activeEvent.member_uid}`)}
                    />
                  </View>
                ) : null}
              </Card>
            </View>
          </View>
        </View>
      ) : (
        /* ── Mode 2: GPS Route Playback ────────────────────────────────── */
        <View style={{ gap: 16 }}>
          {/* Route filter & summary */}
          <Card style={{ padding: 16, gap: 14 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 12 }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12, flexWrap: 'wrap' }}>
                <T variant="bodyStrong">Chọn ngày xem lộ trình:</T>
                <View style={{ width: 170 }}>
                  <DateField value={routeDate} onChange={setRouteDate} />
                </View>
                <IconButton
                  icon="refresh-outline"
                  size={36}
                  variant="secondary"
                  loading={routeQuery.isFetching}
                  label="Tải lại lộ trình"
                  onPress={() => routeQuery.refetch()}
                />
              </View>

              {/* Stats badges */}
              <View style={{ flexDirection: 'row', gap: 14, flexWrap: 'wrap' }}>
                <View style={[styles.statChip, { backgroundColor: c.surfaceAlt, borderColor: c.border }]}>
                  <Icon name="footsteps-outline" size={16} color="primary" />
                  <T variant="caption" color="textMuted">Quãng đường:</T>
                  <T variant="bodyStrong">{(routeStats.distance / 1000).toFixed(2)} km</T>
                </View>
                <View style={[styles.statChip, { backgroundColor: c.surfaceAlt, borderColor: c.border }]}>
                  <Icon name="time-outline" size={16} color="info" />
                  <T variant="caption" color="textMuted">Thời gian:</T>
                  <T variant="bodyStrong">{routeStats.durationMinutes} phút</T>
                </View>
                <View style={[styles.statChip, { backgroundColor: c.surfaceAlt, borderColor: c.border }]}>
                  <Icon name="pin-outline" size={16} color="accent" />
                  <T variant="caption" color="textMuted">Điểm toạ độ:</T>
                  <T variant="bodyStrong">{routePoints.length}</T>
                </View>
              </View>
            </View>

            {/* Playback slider bar */}
            {routePoints.length > 1 ? (
              <View style={[styles.playbackCard, { backgroundColor: c.surfaceAlt, borderColor: c.border }]}>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                  <IconButton
                    icon={playing ? 'pause' : 'play'}
                    variant="soft"
                    size={40}
                    label={playing ? 'Tạm dừng' : 'Phát lộ trình'}
                    onPress={() => {
                      if (playhead >= routePoints.length - 1) setPlayhead(0);
                      setPlaying((p) => !p);
                    }}
                  />
                  <View style={{ flex: 1 }}>
                    <RangeField
                      min={0}
                      max={routePoints.length - 1}
                      step={1}
                      value={playhead}
                      onChange={(v) => {
                        setPlayhead(v);
                        setPlaying(false);
                      }}
                    />
                  </View>
                  <Segmented
                    value={playSpeed}
                    onChange={(s) => setPlaySpeed(s as any)}
                    options={[
                      { value: '1', label: '1x' },
                      { value: '2', label: '2x' },
                      { value: '4', label: '4x' },
                    ]}
                  />
                </View>

                {currentRoutePoint ? (
                  <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 8, paddingTop: 4 }}>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                      <Icon name="time-outline" size={14} color="textMuted" />
                      <T variant="bodyStrong" style={{ color: c.primary }}>
                        {formatTime(currentRoutePoint.created_at)}
                      </T>
                      {currentRoutePoint.speed != null ? (
                        <T variant="caption" color="textMuted">
                          · {(currentRoutePoint.speed * 3.6).toFixed(1)} km/h
                        </T>
                      ) : null}
                    </View>
                    <T variant="caption" color="textMuted" numberOfLines={1} style={{ maxWidth: 450 }}>
                      {currentRoutePoint.address ?? `${currentRoutePoint.latitude.toFixed(5)}, ${currentRoutePoint.longitude.toFixed(5)}`}
                    </T>
                  </View>
                ) : null}
              </View>
            ) : null}
          </Card>

          {/* Route Map */}
          <Card style={{ height: 560, padding: 0, overflow: 'hidden' }}>
            {routePoints.length === 0 ? (
              <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', padding: 30 }}>
                <EmptyState
                  icon="map-outline"
                  title="Không có lộ trình GPS trong ngày này"
                  description={`Ngày ${formatDate(routeDate)} chưa ghi nhận dữ liệu định vị nào từ điện thoại của ${currentMember?.name ?? 'thành viên'}.`}
                />
              </View>
            ) : (
              <LazyFamilyMap
                members={members}
                safeZones={memberZones}
                selectedUid={selectedMemberId ?? undefined}
                route={routePoints}
                playheadIndex={playhead}
                fitKey={`route-${routeDate}-${routePoints.length}`}
              />
            )}
          </Card>
        </View>
      )}

      {/* ── Month Picker Modal ────────────────────────────────────────── */}
      <Modal
        visible={showMonthPicker}
        onClose={() => setShowMonthPicker(false)}
        title="Chọn tháng xem lịch sử"
        icon="calendar-outline"
        width={420}
        footer={
          <Button label="Đóng" variant="secondary" onPress={() => setShowMonthPicker(false)} />
        }
      >
        <View style={{ gap: 16 }}>
          {/* Year row */}
          <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 16 }}>
            <IconButton
              icon="chevron-back"
              size={36}
              variant="secondary"
              label="Năm trước"
              onPress={() => setSelectedYear((y) => y - 1)}
            />
            <T variant="h2" style={{ fontWeight: '800' }}>
              Năm {selectedYear}
            </T>
            <IconButton
              icon="chevron-forward"
              size={36}
              variant="secondary"
              disabled={selectedYear >= now.getFullYear()}
              label="Năm sau"
              onPress={() => setSelectedYear((y) => Math.min(now.getFullYear(), y + 1))}
            />
          </View>

          {/* 12 months grid */}
          <View style={styles.monthGrid}>
            {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => {
              const isSelected = m === selectedMonth;
              const isFuture = selectedYear === now.getFullYear() && m > now.getMonth() + 1;

              return (
                <Pressable
                  key={m}
                  disabled={isFuture}
                  onPress={() => {
                    setSelectedMonth(m);
                    setShowMonthPicker(false);
                  }}
                  style={(state) => {
                    const { hovered } = state as WebPressState;
                    return [
                      styles.monthCell,
                      {
                        backgroundColor: isSelected ? c.primary : hovered ? c.surfaceHover : c.surfaceAlt,
                        borderColor: isSelected ? c.primary : c.border,
                        opacity: isFuture ? 0.35 : 1,
                      },
                      web({ cursor: isFuture ? 'not-allowed' : 'pointer' }),
                    ];
                  }}
                >
                  <T
                    variant="bodyStrong"
                    style={{
                      color: isSelected ? '#fff' : c.text,
                      fontWeight: isSelected ? '700' : '500',
                    }}
                  >
                    Th {String(m).padStart(2, '0')}
                  </T>
                </Pressable>
              );
            })}
          </View>
        </View>
      </Modal>
    </Page>
  );
}

const styles = StyleSheet.create({
  monthBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 14,
    height: 38,
  },
  splitWrap: {
    gap: 16,
  },
  dayHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginTop: 6,
    marginBottom: 4,
  },
  dayBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 10,
    paddingVertical: 4,
  },
  dayLine: {
    flex: 1,
    height: 1,
  },
  eventCard: {
    borderWidth: 1,
    borderRadius: 16,
    padding: 14,
  },
  eventIconWrap: {
    width: 44,
    height: 44,
    borderRadius: 13,
    alignItems: 'center',
    justifyContent: 'center',
  },
  mapOverlayCard: {
    position: 'absolute',
    left: 14,
    right: 14,
    bottom: 14,
    padding: 12,
    borderRadius: 14,
    borderWidth: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
    zIndex: 1000,
  },
  statChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    borderWidth: 1,
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 6,
  },
  playbackCard: {
    borderWidth: 1,
    borderRadius: 14,
    padding: 12,
    gap: 8,
  },
  monthGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    justifyContent: 'center',
  },
  monthCell: {
    width: '22%',
    height: 44,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

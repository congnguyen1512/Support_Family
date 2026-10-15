import React, { useEffect, useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { useTheme } from '../../theme/ThemeProvider';
import { shadow, transition, web, type WebPressState } from '../../theme/web';
import {
  Avatar,
  Badge,
  Button,
  Divider,
  EmptyState,
  Field,
  Icon,
  IconButton,
  Loader,
  MemberChips,
  RangeField,
  SearchInput,
  SelectField,
  SkeletonList,
  Switch,
  T,
  TextField,
} from '../../components/ui';
import { confirm } from '../../components/ui/Overlay';
import { LazyFamilyMap } from '../../components/map/LazyMap';
import { DEFAULT_CENTER } from '../../components/map/presence';
import { safeZoneApi } from '../../api/endpoints';
import { qk, useApiMutation, useFamilyMembers, useSafeZones } from '../../api/hooks';
import { usePageShortcuts } from '../../hooks/usePageShortcuts';
import { useBreakpoint, useDebounce } from '../../hooks/common';
import { formatDistance, haversineMeters, normalizeSearch } from '../../utils/format';
import type { SafeZone, SafeZoneInput } from '../../api/types';

interface Draft {
  id?: number;
  target_uid: string;
  name: string;
  lat: number;
  lng: number;
  radius: number;
  is_active: boolean;
}

interface Place {
  display_name: string;
  lat: string;
  lon: string;
}

const ZONE_PRESETS = ['Nhà', 'Trường học', 'Công ty', 'Bệnh viện', 'Công viên', 'Nhà ông bà'];

export default function SafeZonesScreen() {
  const c = useTheme();
  const { isMobile } = useBreakpoint();
  const { members } = useFamilyMembers();
  const { data, isLoading } = useSafeZones();
  const [memberFilter, setMemberFilter] = useState<string | undefined>();
  const [query, setQuery] = useState('');
  const [draft, setDraft] = useState<Draft | null>(null);
  const [focusZone, setFocusZone] = useState<number | null>(null);
  const [placeQuery, setPlaceQuery] = useState('');
  const pq = useDebounce(placeQuery.trim(), 500);
  const [places, setPlaces] = useState<Place[]>([]);
  const [searching, setSearching] = useState(false);

  const startNew = (memberUid?: string) => {
    const m = members.find((x) => x.uid === (memberUid ?? memberFilter)) ?? members[0];
    const lat = m?.location?.latitude ?? DEFAULT_CENTER[0];
    const lng = m?.location?.longitude ?? DEFAULT_CENTER[1];
    setDraft({ target_uid: m?.uid ?? '', name: 'Nhà', lat, lng, radius: 200, is_active: true });
    setPlaceQuery('');
  };
  usePageShortcuts({ onNew: startNew, searchId: 'zones-search' });

  const startEdit = (z: SafeZone) => {
    setDraft({ id: z.id, target_uid: z.target_uid, name: z.name, lat: z.center_latitude, lng: z.center_longitude, radius: z.radius_meters, is_active: z.is_active });
    setPlaceQuery('');
  };

  useEffect(() => {
    if (pq.length < 3) {
      setPlaces([]);
      return;
    }
    const ctl = new AbortController();
    setSearching(true);
    fetch(`https://nominatim.openstreetmap.org/search?format=json&limit=6&countrycodes=vn&accept-language=vi&q=${encodeURIComponent(pq)}`, { signal: ctl.signal })
      .then((r) => r.json())
      .then((r: Place[]) => setPlaces(r))
      .catch(() => undefined)
      .finally(() => setSearching(false));
    return () => ctl.abort();
  }, [pq]);

  const save = useApiMutation(
    (d: Draft) => {
      const body: SafeZoneInput = { target_uid: d.target_uid, name: d.name.trim(), center_latitude: d.lat, center_longitude: d.lng, radius_meters: Math.round(d.radius), is_active: d.is_active };
      return d.id ? safeZoneApi.update(d.id, body) : safeZoneApi.create(body);
    },
    { invalidate: [qk.safeZones], success: (_, d) => (d.id ? 'Đã cập nhật vùng an toàn' : 'Đã tạo vùng an toàn'), onSuccess: () => setDraft(null) },
  );
  const toggle = useApiMutation((z: SafeZone) => safeZoneApi.update(z.id, { is_active: !z.is_active }), {
    invalidate: [qk.safeZones],
    success: (_, z) => (z.is_active ? `Đã tắt "${z.name}"` : `Đã bật "${z.name}"`),
  });
  const remove = useApiMutation((id: number) => safeZoneApi.remove(id), { invalidate: [qk.safeZones], success: 'Đã xóa vùng an toàn' });

  const zones = useMemo(() => {
    const q = normalizeSearch(query);
    return (data ?? []).filter((z) => (!memberFilter || z.target_uid === memberFilter) && (!q || normalizeSearch(z.name).includes(q)));
  }, [data, memberFilter, query]);

  const memberOf = (uid: string) => members.find((m) => m.uid === uid);
  const focused = zones.find((z) => z.id === focusZone);

  const insideNow = (z: SafeZone) => {
    const loc = memberOf(z.target_uid)?.location;
    if (loc?.latitude == null || loc.longitude == null) return null;
    return haversineMeters(loc.latitude, loc.longitude, z.center_latitude, z.center_longitude) <= z.radius_meters;
  };

  const draftMember = draft ? memberOf(draft.target_uid) : undefined;

  const panel = draft ? (
    <ScrollView style={{ flex: 1 }} contentContainerStyle={{ padding: 16, gap: 14 }} keyboardShouldPersistTaps="handled">
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
        <IconButton icon="arrow-back" label="Quay lại" variant="secondary" onPress={() => setDraft(null)} />
        <View style={{ flex: 1 }}>
          <T variant="h3">{draft.id ? 'Sửa vùng an toàn' : 'Vùng an toàn mới'}</T>
          <T variant="caption" color="textMuted">
            Nhấn lên bản đồ để đặt tâm vùng
          </T>
        </View>
      </View>
      <Field label="Thành viên" required>
        <SelectField id="zone-member" value={draft.target_uid} placeholder="Chọn thành viên" onChange={(v) => setDraft({ ...draft, target_uid: v })} options={members.map((m) => ({ value: m.uid, label: `${m.name} (${m.relation})` }))} />
      </Field>
      <Field label="Tên vùng" required>
        <TextField nativeID="zone-name" value={draft.name} onChangeText={(v) => setDraft({ ...draft, name: v })} placeholder="vd: Nhà, Trường học" icon="bookmark-outline" />
      </Field>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
        {ZONE_PRESETS.map((p) => (
          <Button key={p} label={p} size="sm" variant={draft.name === p ? 'soft' : 'secondary'} onPress={() => setDraft({ ...draft, name: p })} />
        ))}
      </View>
      <Field label="Tìm địa chỉ" hint="Gõ địa chỉ để di chuyển tâm vùng (OpenStreetMap)">
        <SearchInput nativeID="zone-place-search" value={placeQuery} onChangeText={setPlaceQuery} placeholder="vd: 268 Lý Thường Kiệt, Quận 10" />
      </Field>
      {searching ? <Loader /> : null}
      {places.length > 0 ? (
        <View style={{ borderWidth: 1, borderColor: c.border, borderRadius: 12, overflow: 'hidden' }}>
          {places.map((p, i) => (
            <Pressable
              key={`${p.lat}-${p.lon}-${i}`}
              onPress={() => {
                setDraft({ ...draft, lat: Number(p.lat), lng: Number(p.lon) });
                setPlaces([]);
                setPlaceQuery('');
              }}
              style={(state) => {
                const { hovered } = state as WebPressState;
                return [{ flexDirection: 'row', gap: 8, padding: 10, borderTopWidth: i ? 1 : 0, borderTopColor: c.border, backgroundColor: hovered ? c.surfaceHover : c.surface }, web({ cursor: 'pointer' })];
              }}
            >
              <Icon name="location-outline" size={15} color="primary" style={{ marginTop: 2 }} />
              <T variant="small" style={{ flex: 1 }} numberOfLines={2}>
                {p.display_name}
              </T>
            </Pressable>
          ))}
        </View>
      ) : null}
      {draftMember?.location?.latitude != null ? (
        <Button
          label={`Dùng vị trí hiện tại của ${draftMember.name}`}
          icon="locate-outline"
          size="sm"
          variant="soft"
          onPress={() => setDraft({ ...draft, lat: draftMember.location!.latitude!, lng: draftMember.location!.longitude! })}
        />
      ) : null}
      <Field label="Bán kính" right={<Badge label={formatDistance(draft.radius)} color="accent" size="sm" />}>
        <RangeField value={draft.radius} min={50} max={3000} step={10} onChange={(v) => setDraft({ ...draft, radius: v })} />
        <View style={{ flexDirection: 'row', gap: 6, flexWrap: 'wrap' }}>
          {[100, 200, 500, 1000, 2000].map((r) => (
            <Button key={r} label={formatDistance(r)} size="sm" variant={draft.radius === r ? 'soft' : 'ghost'} onPress={() => setDraft({ ...draft, radius: r })} />
          ))}
        </View>
      </Field>
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10, padding: 12, borderRadius: 12, backgroundColor: c.surfaceAlt }}>
        <Switch value={draft.is_active} onChange={(v) => setDraft({ ...draft, is_active: v })} label="Kích hoạt" />
        <View style={{ flex: 1 }}>
          <T variant="bodyStrong">Cảnh báo ra / vào vùng</T>
          <T variant="caption" color="textMuted">
            Nhận thông báo khi thành viên rời khỏi hoặc trở về vùng
          </T>
        </View>
      </View>
      <T variant="mono" color="textMuted" style={{ fontSize: 12.5 }}>
        Tâm: {draft.lat.toFixed(6)}, {draft.lng.toFixed(6)}
      </T>
      <View style={{ flexDirection: 'row', gap: 8 }}>
        <Button label="Hủy" variant="secondary" onPress={() => setDraft(null)} style={{ flex: 1 }} full />
        <Button
          nativeID="zone-save"
          label={draft.id ? 'Lưu thay đổi' : 'Tạo vùng'}
          icon="checkmark"
          disabled={!draft.target_uid || !draft.name.trim()}
          loading={save.isPending}
          onPress={() => save.mutate(draft)}
          style={{ flex: 1 }}
          full
        />
      </View>
    </ScrollView>
  ) : (
    <>
      <View style={{ padding: 14, gap: 10 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
          <View style={{ flex: 1 }}>
            <T variant="h3">Vùng an toàn ({data?.length ?? 0})</T>
            <T variant="caption" color="textMuted">
              {(data ?? []).filter((z) => z.is_active).length} vùng đang bật cảnh báo
            </T>
          </View>
          <Button nativeID="zones-new" label="Thêm" icon="add" size="sm" hint="N" disabled={!members.length} onPress={() => startNew()} />
        </View>
        <SearchInput nativeID="zones-search" value={query} onChangeText={setQuery} placeholder="Tìm vùng..." />
        <MemberChips members={members} value={memberFilter} onChange={setMemberFilter} allowAll />
      </View>
      <Divider />
      <ScrollView style={{ flex: 1 }} contentContainerStyle={{ padding: 10, gap: 8 }}>
        {isLoading ? (
          <SkeletonList rows={4} height={76} />
        ) : zones.length === 0 ? (
          <EmptyState compact icon="shield-outline" title="Chưa có vùng an toàn" description="Tạo vùng cho nhà, trường học... để nhận cảnh báo khi người thân ra/vào." action={members.length ? <Button label="Tạo vùng" icon="add" size="sm" onPress={() => startNew()} /> : undefined} />
        ) : (
          zones.map((z) => {
            const m = memberOf(z.target_uid);
            const inside = insideNow(z);
            const active = focusZone === z.id;
            return (
              <Pressable
                key={z.id}
                nativeID={`zone-${z.id}`}
                onPress={() => setFocusZone(active ? null : z.id)}
                style={(state) => {
                  const { hovered } = state as WebPressState;
                  return [
                    { padding: 12, borderRadius: 14, borderWidth: 1, gap: 8, opacity: z.is_active ? 1 : 0.6 },
                    { borderColor: active ? c.primary : c.border, backgroundColor: active ? c.primarySoft : hovered ? c.surfaceHover : c.surface },
                    transition('background-color, border-color', 140),
                    web({ cursor: 'pointer' }),
                  ];
                }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
                  <View style={{ width: 38, height: 38, borderRadius: 12, alignItems: 'center', justifyContent: 'center', backgroundColor: z.is_active ? c.primarySoft : c.surfaceAlt }}>
                    <Icon name={z.is_active ? 'shield-checkmark' : 'shield-outline'} size={19} color={z.is_active ? 'primary' : 'textMuted'} />
                  </View>
                  <View style={{ flex: 1, minWidth: 0 }}>
                    <T variant="bodyStrong" numberOfLines={1}>
                      {z.name}
                    </T>
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                      <Avatar name={m?.name} uri={m?.avatar} size={16} />
                      <T variant="caption" color="textMuted" numberOfLines={1}>
                        {m?.name ?? 'Thành viên'} · {formatDistance(z.radius_meters)}
                      </T>
                    </View>
                  </View>
                  <Switch size="sm" value={z.is_active} onChange={() => toggle.mutate(z)} label="Bật/tắt vùng" />
                </View>
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                  {inside === null ? (
                    <Badge label="Chưa rõ vị trí" color="textMuted" size="sm" />
                  ) : inside ? (
                    <Badge label="Đang ở trong vùng" color="success" size="sm" dot />
                  ) : (
                    <Badge label="Đang ở ngoài vùng" color="warning" size="sm" dot />
                  )}
                  <View style={{ flex: 1 }} />
                  <IconButton icon="create-outline" label="Sửa" size={30} onPress={() => startEdit(z)} />
                  <IconButton
                    icon="trash-outline"
                    label="Xóa"
                    size={30}
                    color={c.danger}
                    onPress={async () => {
                      if (await confirm({ title: 'Xóa vùng an toàn?', message: `"${z.name}" của ${m?.name ?? 'thành viên'} sẽ bị xóa.`, confirmLabel: 'Xóa' })) remove.mutate(z.id);
                    }}
                  />
                </View>
              </Pressable>
            );
          })
        )}
      </ScrollView>
    </>
  );

  return (
    <View style={[styles.root, { flexDirection: isMobile ? 'column' : 'row', padding: isMobile ? 12 : 20 }]}>
      <View style={[styles.panel, { backgroundColor: c.surface, borderColor: c.border, width: isMobile ? '100%' : 380 }, isMobile ? { maxHeight: 460 } : null]}>{panel}</View>
      <View style={[styles.mapWrap, { borderColor: draft ? c.accent : c.border }, shadow(2, c.shadow)]}>
        <LazyFamilyMap
          members={draft ? members.filter((m) => m.uid === draft.target_uid) : members.filter((m) => !memberFilter || m.uid === memberFilter)}
          safeZones={draft ? (data ?? []).filter((z) => z.id !== draft.id && z.target_uid === draft.target_uid) : zones}
          editZone={draft ? { lat: draft.lat, lng: draft.lng, radius: draft.radius } : null}
          onMapClick={draft ? (lat, lng) => setDraft((d) => (d ? { ...d, lat, lng } : d)) : undefined}
          focus={draft ? [draft.lat, draft.lng] : focused ? [focused.center_latitude, focused.center_longitude] : null}
          fitKey={draft ? `draft-${draft.id ?? 'new'}` : undefined}
        />
        {draft ? (
          <View style={[styles.hint, { backgroundColor: c.accent }, shadow(3, 'rgba(124,92,255,0.4)')]}>
            <Icon name="hand-left-outline" size={15} color="#fff" />
            <T variant="small" style={{ color: '#fff', fontWeight: '600' }}>
              Nhấn vào bản đồ để đặt tâm vùng an toàn
            </T>
          </View>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, gap: 16 },
  panel: { borderRadius: 20, borderWidth: 1, overflow: 'hidden' },
  mapWrap: { flex: 1, minHeight: 420, borderRadius: 20, borderWidth: 1.5, overflow: 'hidden', position: 'relative' },
  hint: { position: 'absolute', top: 12, alignSelf: 'center', left: '50%', transform: [{ translateX: -150 }], width: 300, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, paddingVertical: 8, borderRadius: 999, zIndex: 500 },
});

import 'leaflet/dist/leaflet.css';
import React, { useEffect, useMemo, useRef } from 'react';
import L from 'leaflet';
import { Circle, CircleMarker, MapContainer, Marker, Polyline, TileLayer, Tooltip, useMap, useMapEvents } from 'react-leaflet';
import type { FamilyMember, LocationPoint, SafeZone } from '../../api/types';
import { useTheme } from '../../theme/ThemeProvider';
import { colorFor } from '../ui/Display';
import { initials } from '../../utils/format';
import { DEFAULT_CENTER, presenceColor } from './presence';

export { DEFAULT_CENTER, presenceColor };

function escapeHtml(s: string) {
  return s.replace(/[&<>"']/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch]!);
}

function memberIcon(m: FamilyMember, selected: boolean) {
  const color = colorFor(m.name);
  const status = presenceColor(m.location?.updated_at);
  const hasImg = Boolean(m.avatar && m.avatar.startsWith('http'));
  const avatar = hasImg
    ? `<div class="fg-marker__avatar" style="background-image:url('${escapeHtml(m.avatar!)}')"></div>`
    : `<div class="fg-marker__avatar" style="background:${color};color:#fff">${escapeHtml(initials(m.name))}</div>`;
  return L.divIcon({
    className: '',
    iconSize: [48, 58],
    iconAnchor: [24, 56],
    tooltipAnchor: [0, -50],
    html: `<div class="fg-marker ${selected ? 'fg-marker--selected' : ''}">
      <div class="fg-marker__pin" style="background:${selected ? '#00ACB2' : color}">${avatar}</div>
      <div class="fg-marker__status" style="background:${status}"></div>
    </div>`,
  });
}

const alertIcon = L.divIcon({
  className: '',
  iconSize: [44, 44],
  iconAnchor: [22, 22],
  html: `<div class="fg-alert-marker"><div class="fg-pulse"></div><div class="fg-alert-marker__core">!</div></div>`,
});

const playheadIcon = L.divIcon({
  className: '',
  iconSize: [26, 26],
  iconAnchor: [13, 13],
  html: `<div style="position:relative;width:26px;height:26px"><div class="fg-pulse" style="background:rgba(0,172,178,.5)"></div><div class="fg-dot" style="position:absolute;left:5px;top:5px;background:#00ACB2"></div></div>`,
});

const centerIcon = L.divIcon({
  className: '',
  iconSize: [22, 22],
  iconAnchor: [11, 11],
  html: `<div class="fg-dot" style="width:22px;height:22px;background:#7C5CFF"></div>`,
});

/* ── Helpers bên trong map ─────────────────────────────────── */
function AutoResize() {
  const map = useMap();
  useEffect(() => {
    const el = map.getContainer();
    const ro = new ResizeObserver(() => map.invalidateSize());
    ro.observe(el);
    const t = setTimeout(() => map.invalidateSize(), 200);
    return () => {
      ro.disconnect();
      clearTimeout(t);
    };
  }, [map]);
  return null;
}

function FitBounds({ points, fitKey, maxZoom = 16 }: { points: [number, number][]; fitKey: string; maxZoom?: number }) {
  const map = useMap();
  const last = useRef<string>('');
  useEffect(() => {
    if (!points.length || last.current === fitKey) return;
    last.current = fitKey;
    if (points.length === 1) {
      map.setView(points[0], Math.min(maxZoom, 16), { animate: true });
    } else {
      map.fitBounds(L.latLngBounds(points), { padding: [60, 60], maxZoom, animate: true });
    }
  }, [fitKey, points, map, maxZoom]);
  return null;
}

function FlyTo({ target }: { target?: [number, number] | null }) {
  const map = useMap();
  const key = target ? `${target[0].toFixed(5)},${target[1].toFixed(5)}` : '';
  useEffect(() => {
    if (target) map.flyTo(target, Math.max(map.getZoom(), 16), { duration: 0.8 });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key]);
  return null;
}

function ClickCapture({ onClick }: { onClick?: (lat: number, lng: number) => void }) {
  useMapEvents({
    click(e) {
      onClick?.(e.latlng.lat, e.latlng.lng);
    },
  });
  return null;
}

/* ── Component chính ───────────────────────────────────────── */
export interface FamilyMapProps {
  members?: FamilyMember[];
  safeZones?: SafeZone[];
  selectedUid?: string | null;
  onSelectMember?: (uid: string) => void;
  route?: LocationPoint[];
  playheadIndex?: number;
  alerts?: { id: number; lat: number; lng: number; label: string }[];
  editZone?: { lat: number; lng: number; radius: number } | null;
  onMapClick?: (lat: number, lng: number) => void;
  focus?: [number, number] | null;
  fitKey?: string;
  showZoneLabels?: boolean;
  scrollWheelZoom?: boolean;
  zoomControl?: boolean;
}

export default function FamilyMap({
  members = [],
  safeZones = [],
  selectedUid,
  onSelectMember,
  route,
  playheadIndex,
  alerts = [],
  editZone,
  onMapClick,
  focus,
  fitKey,
  showZoneLabels = true,
  scrollWheelZoom = true,
  zoomControl = true,
}: FamilyMapProps) {
  const c = useTheme();
  const located = useMemo(
    () => members.filter((m) => m.location?.latitude != null && m.location?.longitude != null),
    [members],
  );

  const points = useMemo<[number, number][]>(() => {
    if (editZone) return [[editZone.lat, editZone.lng]];
    if (route && route.length) return route.map((p) => [p.latitude, p.longitude]);
    const pts: [number, number][] = located.map((m) => [m.location!.latitude!, m.location!.longitude!]);
    alerts.forEach((a) => pts.push([a.lat, a.lng]));
    safeZones.forEach((z) => pts.push([z.center_latitude, z.center_longitude]));
    return pts;
  }, [located, alerts, safeZones, route, editZone]);

  const autoKey = fitKey ?? `${located.length}-${safeZones.length}-${alerts.length}-${route?.length ?? 0}`;
  const playhead = route && playheadIndex != null ? route[Math.min(playheadIndex, route.length - 1)] : null;
  const memberNameByUid = useMemo(() => new Map(members.map((m) => [m.uid, m.name])), [members]);

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative', borderRadius: 'inherit', overflow: 'hidden' }}>
      <MapContainer
        center={points[0] ?? DEFAULT_CENTER}
        zoom={13}
        style={{ width: '100%', height: '100%', background: c.surfaceAlt }}
        scrollWheelZoom={scrollWheelZoom}
        zoomControl={zoomControl}
        attributionControl
      >
        <TileLayer
          url={c.mapTiles}
          className="fg-tiles"
          maxZoom={19}
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        />
        <AutoResize />
        <FitBounds points={points} fitKey={autoKey} />
        <FlyTo target={focus} />
        {onMapClick ? <ClickCapture onClick={onMapClick} /> : null}

        {safeZones.map((z) => (
          <Circle
            key={`zone-${z.id}`}
            center={[z.center_latitude, z.center_longitude]}
            radius={z.radius_meters}
            pathOptions={{
              color: z.is_active ? '#00ACB2' : '#94A3B8',
              weight: 2,
              dashArray: z.is_active ? undefined : '6 6',
              fillColor: z.is_active ? '#00ACB2' : '#94A3B8',
              fillOpacity: 0.1,
            }}
          >
            {showZoneLabels ? (
              <Tooltip className="fg-tooltip" direction="top" sticky>
                {`${z.name} · ${z.radius_meters} m${memberNameByUid.get(z.target_uid) ? ` · ${memberNameByUid.get(z.target_uid)}` : ''}`}
              </Tooltip>
            ) : null}
          </Circle>
        ))}

        {editZone ? (
          <>
            <Circle
              center={[editZone.lat, editZone.lng]}
              radius={editZone.radius}
              pathOptions={{ color: '#7C5CFF', weight: 2.5, fillColor: '#7C5CFF', fillOpacity: 0.14 }}
            />
            <Marker position={[editZone.lat, editZone.lng]} icon={centerIcon} />
          </>
        ) : null}

        {route && route.length > 1 ? (
          <>
            <Polyline positions={route.map((p) => [p.latitude, p.longitude])} pathOptions={{ color: '#00ACB2', weight: 5, opacity: 0.85, lineCap: 'round' }} />
            <CircleMarker center={[route[0].latitude, route[0].longitude]} radius={7} pathOptions={{ color: '#fff', weight: 3, fillColor: '#12B76A', fillOpacity: 1 }}>
              <Tooltip className="fg-tooltip" direction="top">Điểm bắt đầu</Tooltip>
            </CircleMarker>
            <CircleMarker
              center={[route[route.length - 1].latitude, route[route.length - 1].longitude]}
              radius={7}
              pathOptions={{ color: '#fff', weight: 3, fillColor: '#EF4444', fillOpacity: 1 }}
            >
              <Tooltip className="fg-tooltip" direction="top">Điểm cuối</Tooltip>
            </CircleMarker>
          </>
        ) : null}
        {playhead ? <Marker position={[playhead.latitude, playhead.longitude]} icon={playheadIcon} zIndexOffset={1000} /> : null}

        {located.map((m) => (
          <Marker
            key={`m-${m.uid}`}
            position={[m.location!.latitude!, m.location!.longitude!]}
            icon={memberIcon(m, m.uid === selectedUid)}
            zIndexOffset={m.uid === selectedUid ? 900 : 0}
            eventHandlers={{ click: () => onSelectMember?.(m.uid) }}
          >
            <Tooltip className="fg-tooltip" direction="top">
              {m.name}
            </Tooltip>
          </Marker>
        ))}

        {alerts.map((a) => (
          <Marker key={`a-${a.id}`} position={[a.lat, a.lng]} icon={alertIcon} zIndexOffset={2000}>
            <Tooltip className="fg-tooltip" direction="top" permanent>
              {a.label}
            </Tooltip>
          </Marker>
        ))}
      </MapContainer>
    </div>
  );
}

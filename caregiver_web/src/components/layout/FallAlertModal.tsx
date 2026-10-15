import React, { useMemo } from 'react';
import { Modal as RNModal, StyleSheet, View } from 'react-native';
import { useRouter } from 'expo-router';
import { useTheme } from '../../theme/ThemeProvider';
import { gradient, shadow, web } from '../../theme/web';
import { Avatar, Button, Icon, T } from '../ui';
import { useUiStore } from '../../store/ui';
import { useFamilyMembers } from '../../api/hooks';
import type { AppNotification } from '../../api/types';
import { formatDateTime, normalizeSearch, relativeTime } from '../../utils/format';
import { prettifyNotificationText } from '../../utils/constants';
import { LazyFamilyMap } from '../map/LazyMap';

/**
 * Popup khẩn cấp khi có cảnh báo té ngã chưa được xác nhận.
 * Hiển thị vị trí té ngã trên bản đồ + thao tác nhanh: xác nhận, xem bản đồ, nhắn tin, gọi điện.
 */
export function FallAlertModal({ alerts }: { alerts: AppNotification[] }) {
  const c = useTheme();
  const router = useRouter();
  const acknowledge = useUiStore((s) => s.acknowledgeAlert);
  const { members } = useFamilyMembers();
  const alert = alerts[0];

  const member = useMemo(() => {
    if (!alert) return undefined;
    const sender = normalizeSearch(alert.sender_name);
    const text = normalizeSearch(`${alert.title} ${alert.content}`);
    return members.find((m) => {
      const n = normalizeSearch(m.name);
      return (sender && n === sender) || (n.length > 1 && text.includes(n));
    });
  }, [alert, members]);

  if (!alert) return null;

  const hasPoint = alert.fall_latitude != null && alert.fall_longitude != null;
  const point = hasPoint ? { id: alert.id, lat: alert.fall_latitude!, lng: alert.fall_longitude!, label: member?.name ?? alert.sender_name ?? 'Té ngã' } : null;
  const who = member?.name ?? alert.sender_name ?? 'Người thân';

  const close = () => acknowledge(alert.id);

  return (
    <RNModal transparent visible animationType="none" onRequestClose={close}>
      <View style={[styles.overlay, { backgroundColor: 'rgba(40, 6, 6, 0.55)' }, web({ backdropFilter: 'blur(3px)' })]}>
        <View
          dataSet={{ anim: 'pop' }}
          style={[styles.sheet, { backgroundColor: c.elevated, borderColor: c.danger }, shadow(4, 'rgba(239,68,68,0.35)')]}
        >
          <View style={[styles.header, gradient('#EF4444', '#B91C1C', 120)]}>
            <View dataSet={{ anim: 'alarm' }} style={styles.siren}>
              <Icon name="warning" size={30} color="#fff" />
            </View>
            <View style={{ flex: 1, gap: 2 }}>
              <T variant="label" style={{ color: 'rgba(255,255,255,0.8)' }}>
                Cảnh báo khẩn cấp
              </T>
              <T variant="h1" style={{ color: '#fff' }}>
                Phát hiện té ngã — {who}
              </T>
              <T variant="small" style={{ color: 'rgba(255,255,255,0.85)' }}>
                {formatDateTime(alert.created_at)} · {relativeTime(alert.created_at)}
              </T>
            </View>
            {alerts.length > 1 ? (
              <View style={styles.more}>
                <T variant="caption" style={{ color: '#B91C1C', fontWeight: '800' }}>
                  +{alerts.length - 1} cảnh báo
                </T>
              </View>
            ) : null}
          </View>

          <View style={styles.body}>
            <View style={{ flexDirection: 'row', gap: 12, alignItems: 'center' }}>
              <Avatar name={who} uri={member?.avatar} size={48} ring={c.danger} />
              <View style={{ flex: 1 }}>
                <T variant="bodyStrong">{prettifyNotificationText(alert.title)}</T>
                <T variant="small" color="textMuted">
                  {prettifyNotificationText(alert.content)}
                </T>
              </View>
            </View>

            <View style={[styles.mapBox, { borderColor: c.border, backgroundColor: c.surfaceAlt }]}>
              {point ? (
                <LazyFamilyMap alerts={[point]} members={member ? [member] : []} fitKey={`fall-${alert.id}`} scrollWheelZoom={false} />
              ) : (
                <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                  <Icon name="location-outline" size={28} color="textMuted" />
                  <T variant="small" color="textMuted">
                    Không có tọa độ té ngã kèm theo
                  </T>
                </View>
              )}
            </View>

            {point ? (
              <T variant="caption" color="textMuted">
                Tọa độ: {point.lat.toFixed(6)}, {point.lng.toFixed(6)}
              </T>
            ) : null}
          </View>

          <View style={[styles.footer, { borderTopColor: c.border, backgroundColor: c.surfaceAlt }]}>
            {member?.phone ? (
              <Button
                nativeID="fall-call"
                label={`Gọi ${member.phone}`}
                icon="call"
                variant="secondary"
                onPress={() => window.open(`tel:${member.phone}`)}
              />
            ) : null}
            {point ? (
              <Button
                nativeID="fall-directions"
                label="Chỉ đường"
                icon="navigate"
                variant="secondary"
                onPress={() => window.open(`https://www.google.com/maps/dir/?api=1&destination=${point.lat},${point.lng}`, '_blank')}
              />
            ) : null}
            {member ? (
              <Button
                nativeID="fall-message"
                label="Nhắn tin"
                icon="chatbubble-ellipses"
                variant="secondary"
                onPress={() => {
                  close();
                  router.push(`/messages?peer=${member.uid}` as any);
                }}
              />
            ) : null}
            <View style={{ flex: 1 }} />
            <Button
              nativeID="fall-acknowledge"
              label="Tôi đã nắm thông tin"
              icon="checkmark-done"
              variant="danger"
              onPress={() => {
                close();
                if (member) router.push(`/map?uid=${member.uid}` as any);
              }}
            />
          </View>
        </View>
      </View>
    </RNModal>
  );
}

const styles = StyleSheet.create({
  overlay: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 20 },
  sheet: { width: 720, maxWidth: '100%', borderRadius: 28, borderWidth: 2, overflow: 'hidden' },
  header: { flexDirection: 'row', alignItems: 'center', gap: 16, padding: 22 },
  siren: { width: 60, height: 60, borderRadius: 30, backgroundColor: 'rgba(255,255,255,0.18)', alignItems: 'center', justifyContent: 'center' },
  more: { backgroundColor: '#fff', borderRadius: 999, paddingHorizontal: 10, paddingVertical: 4 },
  body: { padding: 22, gap: 14 },
  mapBox: { height: 300, borderRadius: 18, borderWidth: 1, overflow: 'hidden' },
  footer: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, alignItems: 'center', paddingHorizontal: 22, paddingVertical: 14, borderTopWidth: 1 },
});

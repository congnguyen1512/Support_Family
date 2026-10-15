import { supabaseAdmin } from '../../config/supabase';
import { PushDeliveryService } from '../notifications/push-delivery.service';
import {
  CreateSafeZoneInput,
  ListSafeZoneEventsQuery,
  SafeZoneEventRecord,
  SafeZoneEventType,
  SafeZoneRecord,
  UpdateSafeZoneInput,
} from './safe-zones.types';

type UserRole = 'nguoichamsoc' | 'nguoiduocchamsoc' | null;

interface SafeZoneStateRecord {
  id: number;
  safe_zone_id: number;
  uid: string;
  is_inside: boolean;
  last_checked_at: string;
  last_notified_at: string | null;
}

const DEFAULT_EVENTS_LIMIT = 500;

// Vung dem chong nhieu GPS: da o trong vung thi phai ra xa hon
// (radius + buffer) moi tinh la roi vung, tranh bat/tat lien tuc o mep vung.
const HYSTERESIS_RATIO = 0.1;
const HYSTERESIS_MIN_METERS = 10;
const HYSTERESIS_MAX_METERS = 50;

export class SafeZonesService {
  private readonly pushDeliveryService = new PushDeliveryService();

  async createSafeZone(ownerUid: string, input: CreateSafeZoneInput) {
    await this.ensureCaregiver(ownerUid);
    await this.ensureConfirmedRelationship(ownerUid, input.target_uid);

    const { data, error } = await supabaseAdmin
      .from('safe_zones')
      .insert({
        owner_uid: ownerUid,
        target_uid: input.target_uid,
        name: input.name.trim(),
        center_latitude: input.center_latitude,
        center_longitude: input.center_longitude,
        radius_meters: input.radius_meters,
        is_active: input.is_active ?? true,
      })
      .select('*')
      .single();

    if (error || !data) {
      throw new Error(error?.message || 'Khong tao duoc safe zone');
    }

    return data as SafeZoneRecord;
  }

  async listSafeZones(uid: string) {
    const role = await this.getUserRole(uid);

    let query = supabaseAdmin
      .from('safe_zones')
      .select('*')
      .order('updated_at', { ascending: false });

    if (role === 'nguoichamsoc') {
      // Vung an toan dung chung trong gia dinh: nguoi cham soc thay ca vung do
      // minh tao lan vung do nguoi cham soc khac tao cho thanh vien gia dinh.
      const familyUids = Array.from(await this.getConfirmedFamilyLinks(uid)).map(
        ([memberUid]) => memberUid,
      );
      query = query.or(
        `owner_uid.eq.${uid},target_uid.in.(${[uid, ...familyUids].join(',')})`,
      );
    } else {
      query = query.eq('target_uid', uid);
    }

    const { data, error } = await query;
    if (error) {
      throw new Error(error.message || 'Khong lay duoc safe zones');
    }

    return (data ?? []) as SafeZoneRecord[];
  }

  async updateSafeZone(ownerUid: string, id: number, input: UpdateSafeZoneInput) {
    const existing = await this.getManageableSafeZone(ownerUid, id);

    const updatePayload: Record<string, unknown> = {
      updated_at: new Date().toISOString(),
    };

    if (input.name != null) {
      updatePayload.name = input.name.trim();
    }
    if (input.center_latitude != null) {
      updatePayload.center_latitude = input.center_latitude;
    }
    if (input.center_longitude != null) {
      updatePayload.center_longitude = input.center_longitude;
    }
    if (input.radius_meters != null) {
      updatePayload.radius_meters = input.radius_meters;
    }
    if (input.is_active != null) {
      updatePayload.is_active = input.is_active;
    }

    const { data, error } = await supabaseAdmin
      .from('safe_zones')
      .update(updatePayload)
      .eq('id', existing.id)
      .select('*')
      .single();

    if (error || !data) {
      throw new Error(error?.message || 'Khong cap nhat duoc safe zone');
    }

    // Tat vung: dong khoang thoi gian dang o trong vung va reset trang thai,
    // de khi bat lai se bat dau theo doi tu dau (khong sinh su kien sai).
    if (existing.is_active && input.is_active === false) {
      await this.closeOpenStays(existing.id, new Date().toISOString());
      await supabaseAdmin.from('safe_zone_states').delete().eq('safe_zone_id', existing.id);
    }

    return data as SafeZoneRecord;
  }

  async deleteSafeZone(ownerUid: string, id: number) {
    const existing = await this.getManageableSafeZone(ownerUid, id);

    // Dong cac luot "dang o trong vung" truoc khi xoa (FK se set NULL).
    await this.closeOpenStays(existing.id, new Date().toISOString());

    const { data, error } = await supabaseAdmin
      .from('safe_zones')
      .delete()
      .eq('id', existing.id)
      .select('*')
      .single();

    if (error || !data) {
      throw new Error(error?.message || 'Khong xoa duoc safe zone');
    }

    return data as SafeZoneRecord;
  }

  async checkLocationForUser(
    uid: string,
    latitude: number,
    longitude: number,
    address?: string | null,
  ) {
    const { data: zones, error } = await supabaseAdmin
      .from('safe_zones')
      .select('*')
      .eq('target_uid', uid)
      .eq('is_active', true);

    if (error) {
      throw new Error(error.message || 'Khong kiem tra duoc safe zone');
    }

    if (!zones || zones.length == 0) {
      return;
    }

    const normalizedAddress = address?.toString().trim() || null;
    let memberName: string | null = null;
    let familyCaregivers: Map<string, number> | null = null;

    for (const rawZone of zones) {
      const zone = rawZone as SafeZoneRecord;
      const distance = this.calculateDistanceMeters(
        latitude,
        longitude,
        zone.center_latitude,
        zone.center_longitude,
      );

      const { data: existingState, error: stateError } = await supabaseAdmin
        .from('safe_zone_states')
        .select('*')
        .eq('safe_zone_id', zone.id)
        .eq('uid', uid)
        .maybeSingle();

      if (stateError) {
        throw new Error(stateError.message || 'Khong doc duoc safe zone state');
      }

      const nowIso = new Date().toISOString();
      const eventContext = {
        zone,
        uid,
        latitude,
        longitude,
        distance,
        address: normalizedAddress,
        occurredAt: nowIso,
      };

      if (!existingState) {
        const isInside = distance <= zone.radius_meters;
        const { error: insertStateError } = await supabaseAdmin
          .from('safe_zone_states')
          .insert({
            safe_zone_id: zone.id,
            uid,
            is_inside: isInside,
            last_checked_at: nowIso,
          });

        if (insertStateError) {
          // Mot request khac vua tao state (unique safe_zone_id+uid) -> bo qua.
          continue;
        }

        // Lan dau theo doi ma dang o trong vung: ghi nhan luot "vao vung".
        if (isInside) {
          await this.recordZoneEvent('enter', eventContext);
        }

        continue;
      }

      const state = existingState as SafeZoneStateRecord;
      const isInside = this.resolveIsInside(state.is_inside, distance, zone.radius_meters);

      if (state.is_inside === isInside) {
        const { error: refreshStateError } = await supabaseAdmin
          .from('safe_zone_states')
          .update({
            is_inside: isInside,
            last_checked_at: nowIso,
          })
          .eq('id', state.id);

        if (refreshStateError) {
          throw new Error(refreshStateError.message || 'Khong cap nhat duoc safe zone state');
        }

        continue;
      }

      // Khoa lac quan: chi request nao doi duoc is_inside tu gia tri cu moi
      // duoc ghi su kien + gui thong bao -> tranh trung lap khi GPS gui don dap.
      const { data: transitioned, error: updateStateError } = await supabaseAdmin
        .from('safe_zone_states')
        .update({
          is_inside: isInside,
          last_checked_at: nowIso,
          last_notified_at: nowIso,
        })
        .eq('id', state.id)
        .eq('is_inside', state.is_inside)
        .select('id');

      if (updateStateError) {
        throw new Error(updateStateError.message || 'Khong cap nhat duoc safe zone state');
      }

      if (!transitioned || transitioned.length === 0) {
        continue;
      }

      await this.recordZoneEvent(isInside ? 'enter' : 'leave', eventContext);

      memberName ??= await this.getUserDisplayName(uid);
      familyCaregivers ??= await this.getFamilyCaregivers(uid);
      const timeLabel = new Date(nowIso).toLocaleTimeString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false,
      });
      const title = isInside ? 'Đã vào vùng an toàn' : 'Cảnh báo rời vùng an toàn';
      const content = isInside
        ? `${memberName} đã vào vùng an toàn "${zone.name}" lúc ${timeLabel}.`
        : `${memberName} vừa rời khỏi vùng an toàn "${zone.name}" lúc ${timeLabel}` +
          (normalizedAddress ? `, gần ${normalizedAddress}` : '') +
          '. Hãy kiểm tra vị trí hiện tại.';

      // Gui cho moi nguoi cham soc trong gia dinh (va nguoi tao vung).
      const recipients = new Map(familyCaregivers);
      if (!recipients.has(zone.owner_uid)) {
        recipients.set(
          zone.owner_uid,
          (await this.findRelationshipId(zone.owner_uid, zone.target_uid)) ?? 0,
        );
      }

      for (const [recipientUid, relationshipId] of recipients) {
        const { data: notification, error: notificationError } = await supabaseAdmin
          .from('notification')
          .insert({
            title,
            content,
            // Thong bao thong tin (khong can xac nhan) -> 'done', tranh hien nut
            // Xac nhan/Huy cua loi moi ket noi tren man hinh thong bao.
            processing: 'done',
            uid: recipientUid,
            relationship_id: relationshipId > 0 ? relationshipId : null,
          })
          .select('*')
          .single();

        if (notificationError) {
          console.error('[safe-zones] Khong tao duoc notification safe zone', notificationError);
          continue;
        }

        try {
          const notificationId = notification?.id;
          await this.pushDeliveryService.sendToUser({
            uid: recipientUid,
            title,
            body: content,
            // Cung tag voi thong bao du phong tren app -> Android gop lam 1, khong trung.
            androidTag: notificationId != null ? `fg_notification_${notificationId}` : undefined,
            data: {
              type: isInside ? 'safe_zone_entered' : 'safe_zone_exited',
              notification_id: notificationId != null ? String(notificationId) : '',
              safe_zone_id: String(zone.id),
              target_uid: uid,
            },
          });
        } catch (error) {
          console.error('Khong the gui push safe zone', error);
        }
      }
    }
  }

  async listEvents(requesterUid: string, query: ListSafeZoneEventsQuery) {
    const memberUid = query.member_uid;

    if (requesterUid !== memberUid) {
      const relationshipId = await this.findRelationshipId(requesterUid, memberUid);
      if (relationshipId == null) {
        throw new SafeZoneAccessError('Ban khong co quyen xem lich su cua thanh vien nay');
      }
    }

    let eventsQuery = supabaseAdmin
      .from('safe_zone_events')
      .select('*')
      .eq('uid', memberUid)
      .order('occurred_at', { ascending: false })
      .order('id', { ascending: false })
      .limit(query.limit ?? DEFAULT_EVENTS_LIMIT);

    if (query.from) {
      eventsQuery = eventsQuery.gte('occurred_at', new Date(query.from).toISOString());
    }
    if (query.to) {
      eventsQuery = eventsQuery.lt('occurred_at', new Date(query.to).toISOString());
    }
    if (query.type) {
      eventsQuery = eventsQuery.eq('event_type', query.type);
    }

    const { data, error } = await eventsQuery;
    if (error) {
      throw new Error(error.message || 'Khong lay duoc lich su di chuyen');
    }

    const events = (data ?? []) as SafeZoneEventRecord[];

    // Vung con ton tai + dang bat => luot "vao vung" chua ket thuc la dang dien ra.
    const zoneIds = Array.from(
      new Set(events.map((e) => e.safe_zone_id).filter((id): id is number => id != null)),
    );
    const activeZoneIds = new Set<number>();
    if (zoneIds.length > 0) {
      const { data: zoneRows, error: zoneError } = await supabaseAdmin
        .from('safe_zones')
        .select('id, is_active')
        .in('id', zoneIds);

      if (zoneError) {
        throw new Error(zoneError.message || 'Khong lay duoc thong tin vung an toan');
      }

      for (const row of zoneRows ?? []) {
        if (row.is_active) activeZoneIds.add(row.id as number);
      }
    }

    const nowMs = Date.now();
    return events.map((event) => {
      const startedMs = event.stay_started_at ? Date.parse(event.stay_started_at) : NaN;
      const endedMs = event.stay_ended_at ? Date.parse(event.stay_ended_at) : NaN;
      const isOngoing =
        event.event_type === 'enter' &&
        event.stay_ended_at == null &&
        event.safe_zone_id != null &&
        activeZoneIds.has(event.safe_zone_id);

      let staySeconds: number | null = null;
      if (!Number.isNaN(startedMs) && !Number.isNaN(endedMs)) {
        staySeconds = Math.max(0, Math.round((endedMs - startedMs) / 1000));
      } else if (isOngoing && !Number.isNaN(startedMs)) {
        staySeconds = Math.max(0, Math.round((nowMs - startedMs) / 1000));
      }

      return {
        id: event.id,
        safe_zone_id: event.safe_zone_id,
        member_uid: event.uid,
        owner_uid: event.owner_uid,
        event_type: event.event_type,
        zone_name: event.zone_name,
        zone_latitude: event.zone_latitude,
        zone_longitude: event.zone_longitude,
        zone_radius_meters: event.zone_radius_meters,
        latitude: event.latitude,
        longitude: event.longitude,
        distance_meters: event.distance_meters,
        address: event.address,
        occurred_at: event.occurred_at,
        stay_started_at: event.stay_started_at,
        stay_ended_at: event.stay_ended_at,
        stay_duration_seconds: staySeconds,
        is_ongoing: isOngoing,
      };
    });
  }

  private resolveIsInside(wasInside: boolean, distance: number, radius: number) {
    if (!wasInside) {
      return distance <= radius;
    }
    const buffer = Math.min(
      Math.max(radius * HYSTERESIS_RATIO, HYSTERESIS_MIN_METERS),
      HYSTERESIS_MAX_METERS,
    );
    return distance <= radius + buffer;
  }

  private async recordZoneEvent(
    type: SafeZoneEventType,
    ctx: {
      zone: SafeZoneRecord;
      uid: string;
      latitude: number;
      longitude: number;
      distance: number;
      address: string | null;
      occurredAt: string;
    },
  ) {
    // Ghi lich su khong duoc lam hong luong cap nhat vi tri / thong bao.
    try {
      let stayStartedAt: string | null = ctx.occurredAt;
      let stayEndedAt: string | null = null;

      if (type === 'leave') {
        const { data: openEnter } = await supabaseAdmin
          .from('safe_zone_events')
          .select('id, occurred_at')
          .eq('safe_zone_id', ctx.zone.id)
          .eq('uid', ctx.uid)
          .eq('event_type', 'enter')
          .is('stay_ended_at', null)
          .order('occurred_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        stayStartedAt = (openEnter?.occurred_at as string | undefined) ?? null;
        stayEndedAt = ctx.occurredAt;
        await this.closeOpenStays(ctx.zone.id, ctx.occurredAt, ctx.uid);
      }

      const { error } = await supabaseAdmin.from('safe_zone_events').insert({
        safe_zone_id: ctx.zone.id,
        uid: ctx.uid,
        owner_uid: ctx.zone.owner_uid,
        event_type: type,
        zone_name: ctx.zone.name,
        zone_latitude: ctx.zone.center_latitude,
        zone_longitude: ctx.zone.center_longitude,
        zone_radius_meters: ctx.zone.radius_meters,
        latitude: ctx.latitude,
        longitude: ctx.longitude,
        distance_meters: Math.round(ctx.distance * 10) / 10,
        address: ctx.address,
        occurred_at: ctx.occurredAt,
        stay_started_at: stayStartedAt,
        stay_ended_at: stayEndedAt,
      });

      if (error) {
        console.error('[safe-zones] Khong ghi duoc lich su vao/roi vung', error);
      }
    } catch (error) {
      console.error('[safe-zones] Loi khi ghi lich su vao/roi vung', error);
    }
  }

  private async closeOpenStays(zoneId: number, endedAtIso: string, uid?: string) {
    let query = supabaseAdmin
      .from('safe_zone_events')
      .update({ stay_ended_at: endedAtIso })
      .eq('safe_zone_id', zoneId)
      .eq('event_type', 'enter')
      .is('stay_ended_at', null);

    if (uid) {
      query = query.eq('uid', uid);
    }

    const { error } = await query;
    if (error) {
      console.error('[safe-zones] Khong dong duoc luot o trong vung', error);
    }
  }

  calculateDistanceMeters(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ) {
    const toRad = (value: number) => (value * Math.PI) / 180;
    const earthRadius = 6371000;

    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(toRad(lat1)) *
        Math.cos(toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadius * c;
  }

  private async ensureCaregiver(uid: string) {
    const role = await this.getUserRole(uid);
    if (role !== 'nguoichamsoc') {
      throw new Error('Chi nguoi cham soc moi duoc tao vung an toan');
    }
  }

  private async getUserRole(uid: string): Promise<UserRole> {
    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select('role')
      .eq('uid', uid)
      .maybeSingle();

    if (error) {
      throw new Error(error.message || 'Khong lay duoc role nguoi dung');
    }

    return (data?.role as UserRole | undefined) ?? null;
  }

  private async ensureConfirmedRelationship(ownerUid: string, targetUid: string) {
    const relationshipId = await this.findRelationshipId(ownerUid, targetUid);
    if (relationshipId == null) {
      throw new Error('Hai nguoi dung chua co quan he da xac nhan');
    }
  }

  async findRelationshipId(ownerUid: string, targetUid: string) {
    const { data, error } = await supabaseAdmin
      .from('relationship')
      .select('id')
      .or(
        `and(uid.eq.${ownerUid},relation_id.eq.${targetUid},processing.eq.xacnhan),and(uid.eq.${targetUid},relation_id.eq.${ownerUid},processing.eq.xacnhan)`,
      )
      .order('id', { ascending: true })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw new Error(error.message || 'Khong lay duoc relationship');
    }

    return typeof data?.id === 'number' ? data.id : null;
  }

  /**
   * Cac thanh vien co quan he da xac nhan voi [uid] (ca 2 chieu).
   * Tra ve Map<memberUid, relationshipId>.
   */
  private async getConfirmedFamilyLinks(uid: string) {
    const { data, error } = await supabaseAdmin
      .from('relationship')
      .select('id, uid, relation_id')
      .or(`uid.eq.${uid},relation_id.eq.${uid}`)
      .eq('processing', 'xacnhan')
      .order('id', { ascending: true });

    if (error) {
      throw new Error(error.message || 'Khong lay duoc danh sach gia dinh');
    }

    const links = new Map<string, number>();
    for (const row of data ?? []) {
      const otherUid = (row.uid === uid ? row.relation_id : row.uid) as string | null;
      if (otherUid && otherUid !== uid && !links.has(otherUid)) {
        links.set(otherUid, row.id as number);
      }
    }
    return links;
  }

  /** Nguoi cham soc trong gia dinh cua [targetUid]: Map<caregiverUid, relationshipId>. */
  private async getFamilyCaregivers(targetUid: string) {
    const links = await this.getConfirmedFamilyLinks(targetUid);
    const caregivers = new Map<string, number>();
    if (links.size === 0) {
      return caregivers;
    }

    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select('uid, role')
      .in('uid', Array.from(links.keys()));

    if (error) {
      throw new Error(error.message || 'Khong lay duoc nguoi cham soc');
    }

    for (const row of data ?? []) {
      if (row.role === 'nguoichamsoc') {
        caregivers.set(row.uid as string, links.get(row.uid as string)!);
      }
    }
    return caregivers;
  }

  /**
   * Vung an toan ma [uid] duoc phep quan ly: do minh tao, hoac la nguoi cham soc
   * co quan he da xac nhan voi thanh vien duoc bao ve (quan ly chung trong gia dinh).
   */
  private async getManageableSafeZone(uid: string, id: number) {
    const { data, error } = await supabaseAdmin
      .from('safe_zones')
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw new Error(error.message || 'Khong tim thay safe zone');
    }

    if (!data) {
      throw new Error('Khong tim thay safe zone');
    }

    const zone = data as SafeZoneRecord;
    if (zone.owner_uid === uid) {
      return zone;
    }

    const role = await this.getUserRole(uid);
    const relationshipId =
      role === 'nguoichamsoc' ? await this.findRelationshipId(uid, zone.target_uid) : null;
    if (relationshipId == null) {
      throw new Error('Ban khong co quyen sua safe zone nay');
    }

    return zone;
  }

  private async getUserDisplayName(uid: string) {
    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select('name, email')
      .eq('uid', uid)
      .maybeSingle();

    if (error) {
      throw new Error(error.message || 'Khong lay duoc ten nguoi dung');
    }

    const name = data?.name?.toString().trim();
    if (name) {
      return name;
    }

    const email = data?.email?.toString().trim();
    return email || 'Thanh vien gia dinh';
  }
}

export class SafeZoneAccessError extends Error {}

export const safeZonesService = new SafeZonesService();

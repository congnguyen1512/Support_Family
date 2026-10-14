import { supabaseAdmin } from '../../config/supabase';
import { safeZonesService } from '../safe-zones/safe-zones.service';
import { UpdateMyLocationInput, UserLocationRecord } from './locations.types';

export class LocationsService {
  async updateMyLocation(uid: string, input: UpdateMyLocationInput) {
    const updatedAt = input.timestamp ?? new Date().toISOString();
    console.log('[locations] updateMyLocation request', {
      uid,
      latitude: input.latitude,
      longitude: input.longitude,
      accuracy: input.accuracy ?? null,
      speed: input.speed ?? null,
      address: input.address ?? null,
      updatedAt,
    });

    const { data, error } = await supabaseAdmin
      .from('user_locations')
      .upsert(
        {
          uid,
          latitude: input.latitude,
          longitude: input.longitude,
          accuracy: input.accuracy ?? null,
          speed: input.speed ?? null,
          address: input.address ?? null,
          street: input.street ?? null,
          ward: input.ward ?? null,
          district: input.district ?? null,
          city: input.city ?? null,
          country: input.country ?? null,
          place_name: input.place_name ?? null,
          updated_at: updatedAt,
        },
        {
          onConflict: 'uid',
        },
      )
      .select('*')
      .single();

    if (error || !data) {
      throw new Error(error?.message || 'Khong cap nhat duoc vi tri');
    }

    console.log('[locations] user_locations upserted', {
      uid: data.uid,
      latitude: data.latitude,
      longitude: data.longitude,
      updated_at: data.updated_at,
      address: data.address ?? null,
    });

    await supabaseAdmin.from('location_history').insert({
      uid,
      latitude: input.latitude,
      longitude: input.longitude,
      accuracy: input.accuracy ?? null,
      speed: input.speed ?? null,
      address: input.address ?? null,
      street: input.street ?? null,
      ward: input.ward ?? null,
      district: input.district ?? null,
      city: input.city ?? null,
      country: input.country ?? null,
      place_name: input.place_name ?? null,
      created_at: updatedAt,
    });

    await safeZonesService.checkLocationForUser(uid, input.latitude, input.longitude);

    return data as UserLocationRecord;
  }

  async getMyLocation(uid: string) {
    const { data, error } = await supabaseAdmin
      .from('user_locations')
      .select('*')
      .eq('uid', uid)
      .maybeSingle();

    if (error) {
      throw new Error(error.message || 'Khong lay duoc vi tri hien tai');
    }

    return (data as UserLocationRecord | null) ?? null;
  }

  async getFamilyLocations(currentUid: string) {
    const { data: relationships, error: relationshipError } = await supabaseAdmin
      .from('relationship')
      .select('uid, relation_id, relation_type, reverse_relation_type, processing')
      .or(`uid.eq.${currentUid},relation_id.eq.${currentUid}`)
      .eq('processing', 'xacnhan');

    if (relationshipError) {
      throw new Error(relationshipError.message || 'Khong lay duoc danh sach gia dinh');
    }

    const familyIds = new Set<string>();
    for (const relationship of relationships ?? []) {
      if (relationship.uid === currentUid) {
        familyIds.add(relationship.relation_id);
      } else if (relationship.relation_id === currentUid) {
        familyIds.add(relationship.uid);
      }
    }

    if (familyIds.size === 0) {
      return [];
    }

    const ids = Array.from(familyIds);

    const { data: users, error: userError } = await supabaseAdmin
      .from('user_info')
      .select('uid, name, email, phone, role, user_type, avata')
      .in('uid', ids);

    if (userError) {
      throw new Error(userError.message || 'Khong lay duoc thong tin thanh vien');
    }

    const { data: locations, error: locationError } = await supabaseAdmin
      .from('user_locations')
      .select('*')
      .in('uid', ids);

    if (locationError) {
      throw new Error(locationError.message || 'Khong lay duoc vi tri thanh vien');
    }

    const locationMap = new Map<string, UserLocationRecord>();
    for (const location of locations ?? []) {
      locationMap.set(location.uid, location as UserLocationRecord);
    }

    return (users ?? []).map((user) => {
      const location = locationMap.get(user.uid);
      return {
        uid: user.uid,
        name: user.name ?? user.email ?? 'Thanh vien',
        role: user.role ?? null,
        user_type: user.user_type ?? null,
        avata: user.avata ?? null,
        phone: user.phone ?? null,
        email: user.email ?? null,
        latitude: location?.latitude ?? null,
        longitude: location?.longitude ?? null,
        accuracy: location?.accuracy ?? null,
        speed: location?.speed ?? null,
        address: location?.address ?? null,
        street: location?.street ?? null,
        ward: location?.ward ?? null,
        district: location?.district ?? null,
        city: location?.city ?? null,
        country: location?.country ?? null,
        place_name: location?.place_name ?? null,
        updated_at: location?.updated_at ?? null,
      };
    });
  }
}

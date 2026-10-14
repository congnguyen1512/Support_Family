import { supabaseAdmin } from '../../config/supabase';

const profileSelect =
  'uid, name, email, phone, birthday, sex, address, role, avata, created_at';
const avatarBucketName = 'avatars';
const maxAvatarBytes = 5 * 1024 * 1024;

type UploadAvatarPayload = {
  fileName: string;
  mimeType?: string;
  base64Data: string;
};

class RequestError extends Error {
  constructor(
    message: string,
    readonly statusCode: number,
  ) {
    super(message);
  }
}

function normalizeBase64(raw: string): string {
  const trimmed = raw.trim();
  const commaIndex = trimmed.indexOf(',');
  if (trimmed.startsWith('data:') && commaIndex >= 0) {
    return trimmed.slice(commaIndex + 1);
  }
  return trimmed;
}

function inferExtension(fileName: string, mimeType?: string): string {
  const fileExtension = fileName.split('.').pop()?.trim().toLowerCase();
  if (fileExtension && ['jpg', 'jpeg', 'png', 'webp', 'gif'].includes(fileExtension)) {
    return fileExtension === 'jpeg' ? 'jpg' : fileExtension;
  }

  switch ((mimeType ?? '').toLowerCase()) {
    case 'image/png':
      return 'png';
    case 'image/webp':
      return 'webp';
    case 'image/gif':
      return 'gif';
    case 'image/jpg':
    case 'image/jpeg':
    default:
      return 'jpg';
  }
}

function resolveMimeType(fileName: string, mimeType?: string): string {
  const normalizedMime = mimeType?.trim().toLowerCase();
  if (
    normalizedMime &&
    ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'].includes(normalizedMime)
  ) {
    return normalizedMime === 'image/jpg' ? 'image/jpeg' : normalizedMime;
  }

  switch (inferExtension(fileName, mimeType)) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'gif':
      return 'image/gif';
    case 'jpg':
    default:
      return 'image/jpeg';
  }
}

function extractStoragePath(publicUrl?: string | null): string | null {
  const trimmed = publicUrl?.trim();
  if (!trimmed) {
    return null;
  }

  const marker = `/storage/v1/object/public/${avatarBucketName}/`;
  const markerIndex = trimmed.indexOf(marker);
  if (markerIndex < 0) {
    return null;
  }

  const path = trimmed.slice(markerIndex + marker.length).split('?')[0];
  return path.trim() || null;
}

export class UsersService {
  async getMe(uid: string) {
    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select(profileSelect)
      .eq('uid', uid)
      .single();

    if (error) throw error;
    return data;
  }

  async updateMe(uid: string, payload: Record<string, any>) {
    const { email, ...profileData } = payload;

    if (email) {
      const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(uid, {
        email,
      });

      if (authError) throw authError;
    }

    const updateData: Record<string, any> = { ...profileData };
    if (email) updateData.email = email;

    const { data, error } = await supabaseAdmin
      .from('user_info')
      .update(updateData)
      .eq('uid', uid)
      .select(profileSelect)
      .single();

    if (error) throw error;
    return data;
  }

  async uploadAvatar(uid: string, payload: UploadAvatarPayload) {
    const normalizedBase64 = normalizeBase64(payload.base64Data);
    let imageBuffer: Buffer;

    try {
      imageBuffer = Buffer.from(normalizedBase64, 'base64');
    } catch {
      throw new RequestError('Ảnh tải lên không đúng định dạng base64', 400);
    }

    if (!imageBuffer.length) {
      throw new RequestError('Ảnh tải lên đang rỗng', 400);
    }

    if (imageBuffer.length > maxAvatarBytes) {
      throw new RequestError('Ảnh đại diện phải nhỏ hơn 5MB', 400);
    }

    const extension = inferExtension(payload.fileName, payload.mimeType);
    const contentType = resolveMimeType(payload.fileName, payload.mimeType);
    const filePath =
      `${uid}/${Date.now()}-${Math.random().toString(36).slice(2, 10)}.${extension}`;

    const { data: currentProfile, error: currentProfileError } = await supabaseAdmin
      .from('user_info')
      .select('avata')
      .eq('uid', uid)
      .single();

    if (currentProfileError) {
      throw currentProfileError;
    }

    const { error: uploadError } = await supabaseAdmin.storage
      .from(avatarBucketName)
      .upload(filePath, imageBuffer, {
        contentType,
        upsert: false,
      });

    if (uploadError) {
      throw uploadError;
    }

    const publicUrl = supabaseAdmin.storage
      .from(avatarBucketName)
      .getPublicUrl(filePath).data.publicUrl;

    const { data, error } = await supabaseAdmin
      .from('user_info')
      .update({ avata: publicUrl })
      .eq('uid', uid)
      .select(profileSelect)
      .single();

    if (error) {
      await supabaseAdmin.storage.from(avatarBucketName).remove([filePath]);
      throw error;
    }

    const oldPath = extractStoragePath(currentProfile?.avata);
    if (oldPath && oldPath !== filePath) {
      await supabaseAdmin.storage.from(avatarBucketName).remove([oldPath]);
    }

    return data;
  }

  async searchUsers(currentUid: string, q: string) {
    const keyword = q.trim();

    const { data, error } = await supabaseAdmin
      .from('user_info')
      .select('uid, name, email, phone, role, avata')
      .neq('uid', currentUid)
      .or(`email.ilike.%${keyword}%,phone.ilike.%${keyword}%`)
      .limit(20);

    if (error) throw error;

    const { data: relationships } = await supabaseAdmin
      .from('relationship')
      .select('uid, relation_id, processing')
      .or(`uid.eq.${currentUid},relation_id.eq.${currentUid}`)
      .not('processing', 'in', '(daxoa,huy)');

    const blockedIds = new Set<string>();
    for (const item of relationships ?? []) {
      if (item.uid === currentUid) blockedIds.add(item.relation_id);
      if (item.relation_id === currentUid) blockedIds.add(item.uid);
    }

    return (data ?? []).filter((item) => !blockedIds.has(item.uid));
  }
}
